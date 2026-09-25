class AvailabilitySlot {
  final String id;
  final String? providerId;
  final String? locationId;
  final String? serviceId;
  final DateTime slotDate;
  final String startTime; // 'HH:mm:ss'
  final String endTime;
  final String status; // 'available' | 'booked'

  AvailabilitySlot({
    required this.id,
    this.providerId,
    this.locationId,
    this.serviceId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  bool get isAvailable => status == 'available';

  String get displayTime {
    final parts = startTime.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  factory AvailabilitySlot.fromMap(Map<String, dynamic> map) => AvailabilitySlot(
        id: map['id'] as String,
        providerId: map['provider_id'] as String?,
        locationId: map['location_id'] as String?,
        serviceId: map['service_id'] as String?,
        slotDate: DateTime.parse(map['slot_date'] as String),
        startTime: map['start_time'] as String,
        endTime: map['end_time'] as String,
        status: map['status'] as String,
      );
}
