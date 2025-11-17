// lib/services/auth_service.dart
import 'dart:convert'; // for jsonEncode / jsonDecode
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class UserModel {
  final String id;
  final String name;
  final String role;
  final String segment;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.segment,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      role: map['role'].toString().toLowerCase(),
      segment: map['segment'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'segment': segment,
    };
  }
}

class AuthService extends ChangeNotifier {
  UserModel? user;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthService() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('aa_user');

    if (userJson != null) {
      try {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        user = UserModel.fromMap(map);
      } catch (e) {
        if (kDebugMode) {
          print('Failed to restore user: $e');
        }
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String login, String password) async {
    final data = await Api.login(login: login, password: password);

    if (data["ok"] != true) return false;

    final u = data["user"];

    user = UserModel(
      id: u["id"].toString(),
      name: u["name"] ?? '',
      role: u["role"].toString().toLowerCase(),
      segment: u["segment"] ?? '',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('aa_user', jsonEncode(user!.toMap()));

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('aa_user');
    notifyListeners();
  }
}
