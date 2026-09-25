import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'state/booking_flow_provider.dart';
import 'state/session_provider.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.publishableKey,
  );

  runApp(const ServiceBookingApp());
}

class ServiceBookingApp extends StatelessWidget {
  const ServiceBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;

    return MultiProvider(
      providers: [
        Provider<SupabaseClient>.value(value: client),
        Provider<CatalogRepository>(create: (_) => CatalogRepository(client)),
        Provider<BookingRepository>(create: (_) => BookingRepository(client)),
        Provider<AuthRepository>(create: (_) => AuthRepository(client)),
        Provider<ProfileRepository>(create: (_) => ProfileRepository(client)),
        ChangeNotifierProvider<BookingFlowProvider>(create: (_) => BookingFlowProvider()),
        ChangeNotifierProxyProvider0<SessionProvider>(
          create: (ctx) => SessionProvider(
            authRepository: ctx.read<AuthRepository>(),
            profileRepository: ctx.read<ProfileRepository>(),
          ),
          update: (ctx, session) => session!,
        ),
      ],
      child: MaterialApp(
        title: 'Service Booking',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
