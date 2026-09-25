import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking.dart';

/// Booking writes NEVER touch `bookings` or `availability_slots` directly —
/// they go entirely through the server-side RPC functions your project
/// already has deployed. This is what makes the 4-hour pending expiry and
/// the 3-hour cancellation cutoff impossible to bypass from the client.
class BookingException implements Exception {
  final String code;
  BookingException(this.code);

  String get friendlyMessage {
    switch (code) {
      case 'AUTH_REQUIRED':
        return 'Please sign in to continue.';
      case 'SLOT_UNAVAILABLE':
        return 'That time slot was just taken. Please pick another.';
      case 'SLOT_IN_PAST':
        return 'That time slot has already passed.';
      case 'LOCATION_UNAVAILABLE':
        return 'This location is currently unavailable.';
      case 'BOOKING_NOT_FOUND':
        return 'Booking not found.';
      case 'BOOKING_NOT_PENDING':
        return 'This booking can no longer be confirmed.';
      case 'BOOKING_EXPIRED':
        return 'This booking has expired and the slot was released.';
      case 'BOOKING_NOT_CANCELLABLE':
        return 'This booking can no longer be cancelled.';
      case 'BOOKING_NOT_RESCHEDULABLE':
        return 'This booking can no longer be rescheduled.';
      case 'CANCELLATION_WINDOW_CLOSED':
        return 'Cancellation is only allowed more than 3 hours before the appointment.';
      case 'RESCHEDULE_WINDOW_CLOSED':
        return 'Rescheduling is only allowed more than 3 hours before the appointment.';
      case 'SLOT_LOCATION_MISMATCH':
        return 'The new slot must be for the same service and location.';
      case 'NOT_AUTHORIZED':
        return 'You are not authorized to do that.';
      default:
        return 'Something went wrong ($code). Please try again.';
    }
  }

  @override
  String toString() => code;
}

class BookingRepository {
  final SupabaseClient _client;
  BookingRepository(this._client);

  BookingException _wrap(Object e) {
    if (e is PostgrestException) {
      // Postgres RAISE EXCEPTION 'CODE' arrives in `message`.
      return BookingException(e.message);
    }
    return BookingException('UNKNOWN');
  }

  Future<BookingModel> createBooking(String slotId) async {
    try {
      final row = await _client.rpc('create_booking', params: {'p_slot_id': slotId});
      return BookingModel.fromMap(row as Map<String, dynamic>);
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<BookingModel> confirmBooking(String bookingId) async {
    try {
      final row = await _client.rpc('confirm_booking', params: {'p_booking_id': bookingId});
      return BookingModel.fromMap(row as Map<String, dynamic>);
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final row = await _client.rpc('cancel_booking', params: {
        'p_booking_id': bookingId,
        'p_reason': reason,
      });
      return BookingModel.fromMap(row as Map<String, dynamic>);
    } catch (e) {
      throw _wrap(e);
    }
  }

  Future<BookingModel> rescheduleBooking(String bookingId, String newSlotId) async {
    try {
      final row = await _client.rpc('reschedule_booking', params: {
        'p_booking_id': bookingId,
        'p_new_slot_id': newSlotId,
      });
      return BookingModel.fromMap(row as Map<String, dynamic>);
    } catch (e) {
      throw _wrap(e);
    }
  }

  /// "My Bookings" — RLS already scopes this to bookings the caller owns
  /// (as customer or provider) or all of them if they're super_user.
  Future<List<BookingModel>> fetchMyBookings() async {
    final rows = await _client
        .from('bookings')
        .select(
          '*, services(name), locations(name), availability_slots(slot_date, start_time)',
        )
        .order('created_at', ascending: false);
    return (rows as List).map((e) => BookingModel.fromMap(e)).toList();
  }

  Stream<List<Map<String, dynamic>>> watchMyBookings(String userId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
  }
}
