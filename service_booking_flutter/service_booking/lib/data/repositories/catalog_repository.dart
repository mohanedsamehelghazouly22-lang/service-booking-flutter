import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/category.dart';
import '../../models/service.dart';
import '../../models/location.dart';
import '../../models/availability_slot.dart';

/// Everything here is readable by guests (no auth.uid() required) —
/// RLS on services/locations/categories/availability_slots is public-read.
class CatalogRepository {
  final SupabaseClient _client;
  CatalogRepository(this._client);

  Future<List<Category>> fetchCategories() async {
    final rows = await _client.from('categories').select().order('name');
    return (rows as List).map((e) => Category.fromMap(e)).toList();
  }

  Future<List<ServiceModel>> fetchServices({String? categoryId}) async {
    var query = _client
        .from('services')
        .select('*, service_images(image_url, sort_order)')
        .eq('active', true);
    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    final rows = await query.order('name');
    return (rows as List).map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<ServiceModel> fetchServiceById(String id) async {
    final row = await _client
        .from('services')
        .select('*, service_images(image_url, sort_order)')
        .eq('id', id)
        .single();
    return ServiceModel.fromMap(row);
  }

  /// Locations offering a given service, via the service_locations join table.
  Future<List<LocationModel>> fetchLocationsForService(String serviceId) async {
    final rows = await _client
        .from('service_locations')
        .select('locations(*)')
        .eq('service_id', serviceId);
    return (rows as List)
        .map((e) => LocationModel.fromMap(e['locations'] as Map<String, dynamic>))
        .where((l) => l.active)
        .toList();
  }

  /// Available slots for a service at a location on a given date.
  Future<List<AvailabilitySlot>> fetchSlots({
    required String serviceId,
    required String locationId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final rows = await _client
        .from('availability_slots')
        .select()
        .eq('service_id', serviceId)
        .eq('location_id', locationId)
        .eq('slot_date', dateStr)
        .eq('status', 'available')
        .order('start_time');
    return (rows as List).map((e) => AvailabilitySlot.fromMap(e)).toList();
  }

  /// Which dates in [from, to] have at least one open slot — used to mark
  /// the date picker instead of forcing the customer to guess.
  Future<Set<DateTime>> fetchDatesWithAvailability({
    required String serviceId,
    required String locationId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromStr = _fmt(from);
    final toStr = _fmt(to);
    final rows = await _client
        .from('availability_slots')
        .select('slot_date')
        .eq('service_id', serviceId)
        .eq('location_id', locationId)
        .eq('status', 'available')
        .gte('slot_date', fromStr)
        .lte('slot_date', toStr);
    return (rows as List)
        .map((e) => DateTime.parse(e['slot_date'] as String))
        .toSet();
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
