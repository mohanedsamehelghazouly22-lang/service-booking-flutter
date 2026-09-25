/// Real Supabase project credentials for the "booking-app" project.
///
/// This is the PUBLISHABLE (anon-equivalent) key — safe to ship in the
/// client. It has no elevated privileges; every write path is gated by
/// Row Level Security and the SECURITY DEFINER RPC functions
/// (create_booking / confirm_booking / cancel_booking / reschedule_booking)
/// already deployed on the project. NEVER put a service-role key here.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://lybbdqwgfjekrqhhgdkf.supabase.co';

  static const String publishableKey =
      'sb_publishable_2J95CnOji4M7eU2BInHEXQ_wHw1kkhb';

  /// Fill in from Google Cloud Console (OAuth client for Web application
  /// type, used by Supabase for the Google provider) if you want native
  /// Google Sign-In on Android instead of the browser-redirect flow.
  static const String googleWebClientId = 'REPLACE_WITH_YOUR_WEB_CLIENT_ID';
}
