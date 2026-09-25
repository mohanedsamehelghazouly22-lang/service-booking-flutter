import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../models/availability_slot.dart';
import '../../state/booking_flow_provider.dart';
import 'booking_confirm_screen.dart';

class SlotSelectScreen extends StatefulWidget {
  const SlotSelectScreen({super.key});

  @override
  State<SlotSelectScreen> createState() => _SlotSelectScreenState();
}

class _SlotSelectScreenState extends State<SlotSelectScreen> {
  late Future<List<AvailabilitySlot>> _slotsFuture;

  @override
  void initState() {
    super.initState();
    final flow = context.read<BookingFlowProvider>();
    _slotsFuture = context.read<CatalogRepository>().fetchSlots(
          serviceId: flow.service!.id,
          locationId: flow.location!.id,
          date: flow.date!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<BookingFlowProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(DateFormat('EEEE, MMM d').format(flow.date!))),
      body: FutureBuilder<List<AvailabilitySlot>>(
        future: _slotsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snap.hasError) {
            return Center(child: Text('Could not load time slots: ${snap.error}'));
          }
          final slots = snap.data ?? [];
          if (slots.isEmpty) {
            return const Center(
              child: Text('No open time slots on this date.', style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, i) {
              final slot = slots[i];
              final selected = flow.slot?.id == slot.id;
              return GestureDetector(
                onTap: () {
                  context.read<BookingFlowProvider>().selectSlot(slot);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BookingConfirmScreen()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadii.button),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    slot.displayTime,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
