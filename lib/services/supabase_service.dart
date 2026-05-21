import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import '../models/profile.dart';
import '../models/match_filter.dart';
import '../models/scout.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth
  Future<void> signInWithOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp(String phone, String token) async {
    return await _client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  // Scout
  Future<Scout?> getScout(String id) async {
    final res = await _client.from('scouts').select().eq('id', id).maybeSingle();
    return res != null ? Scout.fromJson(res) : null;
  }

  Future<void> createScout(Scout scout) async {
    await _client.from('scouts').insert(scout.toJson());
  }

  // Profiles
  Future<void> uploadProfile(Profile profile) async {
    await _client.from('profiles').insert(profile.toJson());
  }

  Future<List<Profile>> searchProfiles(MatchFilter filter, {int page = 0}) async {
    var query = _client.from('profiles').select().eq('status', 'Active');

    if (filter.gender != null) query = query.eq('gender', filter.gender!);
    if (filter.religion != null) query = query.eq('religion', filter.religion!);
    if (filter.caste != null) query = query.eq('caste', filter.caste!);
    if (filter.subCaste != null) query = query.eq('sub_caste', filter.subCaste!);
    if (filter.manglik != null) query = query.eq('manglik', filter.manglik!);
    if (filter.education != null) query = query.eq('education', filter.education!);
    if (filter.profession != null) query = query.eq('profession', filter.profession!);
    if (filter.income != null) query = query.eq('income', filter.income!);
    if (filter.diet != null) query = query.eq('diet', filter.diet!);
    if (filter.maritalStatus != null) query = query.eq('marital_status', filter.maritalStatus!);
    if (filter.familyType != null) query = query.eq('family_type', filter.familyType!);
    if (filter.city != null) query = query.eq('city', filter.city!);
    if (filter.state != null) query = query.eq('state', filter.state!);
    if (filter.complexion != null) query = query.eq('complexion', filter.complexion!);
    if (filter.bodyType != null) query = query.eq('body_type', filter.bodyType!);
    if (filter.ageMin != null) query = query.gte('age', filter.ageMin!);
    if (filter.ageMax != null) query = query.lte('age', filter.ageMax!);
    if (filter.heightMin != null) query = query.gte('height', filter.heightMin!);
    if (filter.heightMax != null) query = query.lte('height', filter.heightMax!);

    final offset = page * 20;
    final res = await query
        .order(filter.sortBy, ascending: filter.ascending)
        .range(offset, offset + 19);

    return (res as List).map((e) => Profile.fromJson(e)).toList();
  }

  // Unlock
  Future<bool> hasUnlocked(String scoutId, String profileId) async {
    final res = await _client
        .from('unlocks')
        .select()
        .eq('scout_id', scoutId)
        .eq('profile_id', profileId)
        .maybeSingle();
    return res != null;
  }

  Future<Profile?> getProfile(String id) async {
    final res = await _client.from('profiles').select().eq('id', id).maybeSingle();
    return res != null ? Profile.fromJson(res) : null;
  }

  // Image upload
  Future<String> uploadImage(String path, Uint8List bytes) async {
    await _client.storage.from('profile-photos').uploadBinary(path, bytes);
    return _client.storage.from('profile-photos').getPublicUrl(path);
  }
}
