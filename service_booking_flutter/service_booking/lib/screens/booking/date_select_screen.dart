import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../state/booking_flow_provider.dart';
import 'slot_select_screen.dart';

class DateSelectScreen extends StatefulWidget {
  const DateSelectScreen({super.key});

  @override
  State<DateSelectScreen> createState() => _DateSelectScreenState();
}

class _DateSelectScreenState extends State<DateSelectScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _availableDates = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final flow = context.read<BookingFlowProvider>();
    final repo = context.read<CatalogRepository>();
    final now = DateTime.now();
    final dates = await repo.fetchDatesWithAvailability(
      serviceId: flow.service!.id,
      locationId: flow.location!.id,
      from: DateTime(now.year, now.month, now.day),
      to: DateTime(now.year, now.month, now.day).add(const Duration(days: 60)),
    );
    if (!mounted) return;
    setState(() {
      _availableDates = dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
      _loading = false;
    });
  }

  bool _hasAvailability(DateTime day) =>
      _availableDates.contains(DateTime(day.year, day.month, day.day));

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<BookingFlowProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Choose a date')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _SelectionSummary(flow: flow),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 60)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                  enabledDayPredicate: _hasAvailability,
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    context.read<BookingFlowProvider>().selectDate(selected);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SlotSelectScreen()),
                    );
                  },
                  calendarStyle: CalendarStyle(
                    disabledTextStyle: const TextStyle(color: AppColors.textMuted),
                    selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    todayDecoration:
                        BoxDecoration(color: AppColors.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                    markerDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  ),
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                ),
              ),
            if (!_loading && _availableDates.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  'No availability in the next 60 days for this service and location.',
                  style: TextStyle(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  final BookingFlowProvider flow;
  const _SelectionSummary({required this.flow});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppRadii.tile)),
      child: Row(
        children: [
          const Icon(Icons.design_services_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${flow.service?.name ?? ''} · ${flow.location?.name ?? ''}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
