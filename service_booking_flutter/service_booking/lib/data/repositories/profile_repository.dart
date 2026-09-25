import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';

class ProfileRepository {
  final SupabaseClient _client;
  ProfileRepository(this._client);

  Future<ProfileModel?> fetchCurrentProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final row = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (row == null) return null;
    return ProfileModel.fromMap(row);
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? governorate,
    String? city,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Not signed in');
    final updates = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (fullName != null) updates['full_name'] = fullName;
    if (email != null) updates['email'] = email;
    if (dateOfBirth != null) {
      updates['date_of_birth'] =
          '${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}';
    }
    if (gender != null) updates['gender'] = gender;
    if (governorate != null) updates['governorate'] = governorate;
    if (city != null) updates['city'] = city;
    await _client.from('profiles').update(updates).eq('id', uid);
  }
}
