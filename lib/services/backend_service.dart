import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';

class BackendService {
  final _baseUrl = AppConfig.backendUrl;

  Future<Map<String, String>> _headers() async {
    final session = Supabase.instance.client.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session?.accessToken ?? ''}',
    };
  }

  // Scout
  Future<Map<String, dynamic>> registerScout(String name, String phone, String? territory) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/scouts/register'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'phone': phone, 'territory': territory}),
    );
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/scouts/me'), headers: await _headers());
    return jsonDecode(res.body);
  }

  // Credits
  Future<int> getBalance() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/credits/balance'), headers: await _headers());
    final data = jsonDecode(res.body);
    return data['balance'] ?? 0;
  }

  Future<List<dynamic>> getTransactionHistory() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/credits/history'), headers: await _headers());
    return jsonDecode(res.body);
  }

  // Unlock
  Future<Map<String, dynamic>> unlockProfile(String profileId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/unlocks'),
      headers: await _headers(),
      body: jsonEncode({'profile_id': profileId}),
    );
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> getMyUnlocks() async {
    final res = await http.get(Uri.parse('$_baseUrl/api/unlocks/my'), headers: await _headers());
    return jsonDecode(res.body);
  }

  // Profile upload
  Future<Map<String, dynamic>> uploadProfile(Map<String, dynamic> profileData) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/profiles/upload'),
      headers: await _headers(),
      body: jsonEncode(profileData),
    );
    return jsonDecode(res.body);
  }

  // Report
  Future<Map<String, dynamic>> reportProfile(String profileId) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/api/profiles/report/$profileId'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }
}
