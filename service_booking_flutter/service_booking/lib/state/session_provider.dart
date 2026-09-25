import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../models/profile.dart';

class SessionProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  ProfileModel? profile;
  bool loading = true;
  StreamSubscription<AuthState>? _sub;

  SessionProvider({required this.authRepository, required this.profileRepository}) {
    _init();
  }

  bool get isSignedIn => authRepository.isSignedIn;

  Future<void> _init() async {
    await _refreshProfile();
    loading = false;
    notifyListeners();
    _sub = authRepository.onAuthStateChange.listen((_) async {
      await _refreshProfile();
      notifyListeners();
    });
  }

  Future<void> _refreshProfile() async {
    try {
      profile = await profileRepository.fetchCurrentProfile();
    } catch (_) {
      profile = null;
    }
  }

  Future<void> refresh() async {
    await _refreshProfile();
    notifyListeners();
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    profile = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
