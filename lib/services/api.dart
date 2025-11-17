// lib/services/api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl =
    "https://script.google.com/macros/s/AKfycbyWlWe-DFlIfTVo0a3SdGjurhXuthPErAV3obG-Z1WhQHWkrSU4uggUbmQm9NJd0iZz/exec";

class Api {

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final uri = Uri.parse(
        "$baseUrl?action=login&login=$login&password=$password");

    print("🔵 LOGIN URL: $uri");

    final res = await http.get(uri);

    print("🟢 LOGIN STATUS: ${res.statusCode}");
    print("🟢 LOGIN BODY: ${res.body}");

    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on FormatException catch (e) {
      return {
        'ok': false,
        'error': 'non_json_from_server',
        'detail': e.toString(),
        'raw': res.body,
      };
    }
  }

  // --------------- GET SHOPS ----------------
  static Future<List<dynamic>> getShops(String userId) async {
    final uri = Uri.parse("$baseUrl?action=get_shops&user_id=$userId");

    print("🔵 SHOPS URL: $uri");

    final res = await http.get(uri);

    print("🟢 SHOPS BODY: ${res.body}");

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map) return [];
      if (decoded["ok"] != true) return [];
      return decoded["shops"] ?? [];
    } on FormatException catch (e) {
      print("❌ SHOPS JSON ERROR: $e");
      return [];
    }
  }

  // ---------------- GET LOGS -------------------
  static Future<List<dynamic>> getLogs(String userId) async {
    final uri = Uri.parse("$baseUrl?action=get_logs&user_id=$userId");

    print("🔵 LOGS URL: $uri");

    final res = await http.get(uri);

    print("🟢 LOGS BODY: ${res.body}");

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map) return [];
      if (decoded["ok"] != true) return [];
      return decoded["logs"] ?? [];
    } on FormatException catch (e) {
      print("❌ LOGS JSON ERROR: $e");
      return [];
    }
  }

  // ---------------- LOG CHECKIN (NEW) ----------------
  static Future<Map<String, dynamic>> logCheckin({
    required String userId,
    required String shopId,
    required String shopName,
    required String salesman,
    required double lat,
    required double lng,
    required double distanceM,
    required String result,
  }) async {

    final uri = Uri.parse("$baseUrl?action=log_checkin");

    final body = jsonEncode({
      "user_id": userId,
      "shop_id": shopId,
      "shop_name": shopName,
      "salesman": salesman,
      "lat": lat,
      "lng": lng,
      "distance_m": distanceM,
      "result": result,
    });

    print("📤 SENDING LOG => $body");

    final res = await http.post(
      uri,
      body: body,
      headers: {"Content-Type": "application/json"},
    );

    print("🟢 CHECKIN RESPONSE: ${res.body}");

    try {
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {
        "ok": false,
        "error": "non_json",
        "raw": res.body,
      };
    }
  }
}
