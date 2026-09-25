class BookingModel {
  final String id;
  final String? customerId;
  final String? providerId;
  final String? serviceId;
  final String? slotId;
  final String? locationId;
  final String status; // pending|confirmed|expired|cancelled|completed
  final String bookingType; // pending|instant
  final DateTime? pendingExpiresAt;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Joined display fields (populated when fetched with relations)
  final String? serviceName;
  final String? locationName;
  final DateTime? slotDate;
  final String? slotStartTime;

  BookingModel({
    required this.id,
    this.customerId,
    this.providerId,
    this.serviceId,
    this.slotId,
    this.locationId,
    required this.status,
    required this.bookingType,
    this.pendingExpiresAt,
    required this.createdAt,
    this.cancelledAt,
    this.cancellationReason,
    this.serviceName,
    this.locationName,
    this.slotDate,
    this.slotStartTime,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCancellable => status == 'pending' || status == 'confirmed';

  DateTime? get appointmentStart {
    if (slotDate == null || slotStartTime == null) return null;
    final parts = slotStartTime!.split(':');
    return DateTime(
      slotDate!.year,
      slotDate!.month,
      slotDate!.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  bool get withinCancellationWindow {
    final start = appointmentStart;
    if (start == null) return true;
    return start.difference(DateTime.now()).inMinutes > 180;
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final service = map['services'] as Map<String, dynamic>?;
    final location = map['locations'] as Map<String, dynamic>?;
    final slot = map['availability_slots'] as Map<String, dynamic>?;
    return BookingModel(
      id: map['id'] as String,
      customerId: map['customer_id'] as String?,
      providerId: map['provider_id'] as String?,
      serviceId: map['service_id'] as String?,
      slotId: map['slot_id'] as String?,
      locationId: map['location_id'] as String?,
      status: map['status'] as String,
      bookingType: map['booking_type'] as String? ?? 'pending',
      pendingExpiresAt: map['pending_expires_at'] != null
          ? DateTime.parse(map['pending_expires_at'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      cancellationReason: map['cancellation_reason'] as String?,
      serviceName: service?['name'] as String?,
      locationName: location?['name'] as String?,
      slotDate: slot?['slot_date'] != null ? DateTime.parse(slot!['slot_date'] as String) : null,
      slotStartTime: slot?['start_time'] as String?,
    );
  }
}
