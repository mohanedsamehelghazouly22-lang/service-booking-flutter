import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/booking_repository.dart';
import '../../models/booking.dart';
import '../../widgets/status_badge.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<List<BookingModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<BookingRepository>().fetchMyBookings();
  }

  void _reload() {
    setState(() {
      _future = context.read<BookingRepository>().fetchMyBookings();
    });
  }

  Future<void> _cancel(BookingModel booking) async {
    if (!booking.withinCancellationWindow) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cancellation is only allowed more than 3 hours before the appointment.')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this booking?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel booking')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await context.read<BookingRepository>().cancelBooking(booking.id, reason: 'Cancelled by customer');
      _reload();
    } on BookingException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.friendlyMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Bookings')),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<List<BookingModel>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snap.hasError) {
              return Center(child: Text('Could not load bookings: ${snap.error}'));
            }
            final bookings = snap.data ?? [];
            if (bookings.isEmpty) {
              return ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: Text('No bookings yet.', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookings.length,
              itemBuilder: (context, i) {
                final b = bookings[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppRadii.tile)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(b.serviceName ?? 'Service',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                          ),
                          StatusBadge(status: b.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(b.locationName ?? '', style: const TextStyle(color: AppColors.textMutedOnCard)),
                      const SizedBox(height: 10),
                      if (b.appointmentStart != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMutedOnCard),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('EEE, MMM d · h:mm a').format(b.appointmentStart!),
                              style: const TextStyle(color: AppColors.textMutedOnCard, fontSize: 13),
                            ),
                          ],
                        ),
                      if (b.isPending && b.pendingExpiresAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Provider must confirm by ${DateFormat('MMM d, h:mm a').format(b.pendingExpiresAt!)}',
                          style: const TextStyle(color: AppColors.warning, fontSize: 12),
                        ),
                      ],
                      if (b.isCancellable) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _cancel(b),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white24),
                              minimumSize: const Size.fromHeight(42),
                            ),
                            child: const Text('Cancel booking'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
