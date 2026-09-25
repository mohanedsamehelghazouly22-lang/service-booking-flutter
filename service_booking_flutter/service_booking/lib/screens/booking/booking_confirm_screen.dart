import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/booking_repository.dart';
import '../../models/booking.dart';
import '../../state/booking_flow_provider.dart';
import '../../state/session_provider.dart';
import '../auth/auth_screen.dart';
import '../home/root_shell.dart';

/// This is the ONE point in the whole guest flow where auth is required.
/// Every prior screen (service, location, date, slot) works for guests.
class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({super.key});

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _submitting = false;
  String? _error;
  BookingModel? _result;

  Future<void> _confirm() async {
    final session = context.read<SessionProvider>();
    final flow = context.read<BookingFlowProvider>();

    if (!session.isSignedIn) {
      // Preserve the selection, send them to sign in, and come straight
      // back here once authenticated.
      flow.resumeAfterAuth = true;
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
      if (signedIn != true) return;
      if (!mounted) return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final booking = await context.read<BookingRepository>().createBooking(flow.slot!.id);
      setState(() => _result = booking);
    } on BookingException catch (e) {
      setState(() => _error = e.friendlyMessage);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<BookingFlowProvider>();

    if (_result != null) {
      return _ConfirmationSummary(booking: _result!, flow: flow);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Confirm booking')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppRadii.card)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Service', flow.service?.name ?? ''),
                  const Divider(color: Colors.white12, height: 28),
                  _row('Location', flow.location?.name ?? ''),
                  const Divider(color: Colors.white12, height: 28),
                  _row('Date', DateFormat('EEEE, MMM d, yyyy').format(flow.date!)),
                  const Divider(color: Colors.white12, height: 28),
                  _row('Time', flow.slot?.displayTime ?? ''),
                  const Divider(color: Colors.white12, height: 28),
                  _row(
                    'Confirmation',
                    flow.location?.isInstant == true
                        ? 'Instant — confirmed immediately'
                        : 'Pending — provider confirms within 4 hours',
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _submitting ? null : _confirm,
              child: _submitting
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirm booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: AppColors.textMutedOnCard, fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _ConfirmationSummary extends StatelessWidget {
  final BookingModel booking;
  final BookingFlowProvider flow;
  const _ConfirmationSummary({required this.booking, required this.flow});

  @override
  Widget build(BuildContext context) {
    final instant = booking.status == 'confirmed';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                instant ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: instant ? AppColors.success : AppColors.warning,
                size: 72,
              ),
              const SizedBox(height: 20),
              Text(
                instant ? 'Booking confirmed!' : 'Booking requested',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                instant
                    ? 'Your appointment is locked in.'
                    : 'The provider has 4 hours to confirm. You\'ll be notified either way.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppRadii.card)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row('Service', flow.service?.name ?? ''),
                    const SizedBox(height: 12),
                    _row('Location', flow.location?.name ?? ''),
                    const SizedBox(height: 12),
                    _row('Date', DateFormat('EEEE, MMM d, yyyy').format(flow.date!)),
                    const SizedBox(height: 12),
                    _row('Time', flow.slot?.displayTime ?? ''),
                    const SizedBox(height: 12),
                    _row('Status', booking.status[0].toUpperCase() + booking.status.substring(1)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<BookingFlowProvider>().reset();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const RootShell()),
                      (route) => false,
                    );
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(color: AppColors.textMutedOnCard, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
