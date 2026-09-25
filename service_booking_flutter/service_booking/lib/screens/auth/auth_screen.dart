import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/session_provider.dart';
import 'otp_verify_screen.dart';

/// Pops with `true` if the user ends up signed in, `false`/null otherwise —
/// callers (like BookingConfirmScreen) use this to resume what they were
/// doing.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  bool _sendingOtp = false;
  bool _googleLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _googleLoading = true;
      _error = null;
    });
    try {
      await context.read<AuthRepository>().signInWithGoogle();
      // signInWithOAuth redirects out of the app; when the deep link
      // returns, onAuthStateChange fires and SessionProvider updates.
      // We poll briefly for the session to land, since control returns
      // to this widget once the external browser closes.
      await _waitForSignIn();
    } catch (e) {
      setState(() => _error = 'Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _waitForSignIn() async {
    final session = context.read<SessionProvider>();
    for (var i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (session.isSignedIn) {
        await session.refresh();
        if (mounted) Navigator.of(context).pop(true);
        return;
      }
    }
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !phone.startsWith('+')) {
      setState(() => _error = 'Enter your phone number in international format, e.g. +201234567890');
      return;
    }
    setState(() {
      _sendingOtp = true;
      _error = null;
    });
    try {
      await context.read<AuthRepository>().sendPhoneOtp(phone);
      if (!mounted) return;
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => OtpVerifyScreen(phone: phone)),
      );
      if (signedIn == true && mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = 'Could not send the code. Please check the number and try again.');
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text('Sign in to continue', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Your selections are saved — sign in and you\'ll be right back where you left off.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _googleLoading ? null : _signInWithGoogle,
                icon: _googleLoading
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.g_mobiledata_rounded, size: 26),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.textMuted)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: AppColors.textMuted)),
                  ),
                  Expanded(child: Divider(color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '+20 1XX XXX XXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: _sendingOtp ? null : _sendOtp,
                child: _sendingOtp
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                      )
                    : const Text('Send code'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
