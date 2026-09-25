import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth is only required at the moment of booking (guest browsing is fully
/// allowed before this). Supports:
///  - Google Sign-In, via Supabase's OAuth flow (browser redirect — works
///    uniformly on Android and Windows without extra native SDK wiring).
///  - Phone number + OTP, via Supabase's built-in phone auth.
class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;
  bool get isSignedIn => currentUser != null;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Opens the system browser / webview for Google OAuth. On success the
  /// deep link (see android/app/.../AndroidManifest.xml and the Windows
  /// custom-scheme registration) routes back into the app and
  /// onAuthStateChange fires automatically.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.servicebooking.app://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Step 1 of phone auth: send an OTP to [phone] (E.164 format, e.g.
  /// +201234567890).
  Future<void> sendPhoneOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Step 2: verify the 6-digit code the user received via SMS.
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) {
    return _client.auth.verifyOTP(
      phone: phone,
      token: otp,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
