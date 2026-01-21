import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileNotifier extends ChangeNotifier {
  static const _kName = 'user_name';
  static const _kEmail = 'user_email';
  static const _kPhone = 'user_phone';
  static const _kLoggedIn = 'user_logged_in';

  String _name = 'Người dùng';
  String _email = '';
  String _phone = '';
  bool _loggedIn = false;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  bool get isLoggedIn => _loggedIn;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_kName) ?? 'Người dùng';
    _email = prefs.getString(_kEmail) ?? '';
    _phone = prefs.getString(_kPhone) ?? '';
    _loggedIn = prefs.getBool(_kLoggedIn) ?? false;
    notifyListeners();
  }

  Future<void> setLoggedIn({
    required String email,
    String? name,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = true;

    if (name != null && name.trim().isNotEmpty) _name = name.trim();
    if (phone != null) _phone = phone.trim();
    _email = email.trim();

    await prefs.setBool(_kLoggedIn, true);
    await prefs.setString(_kName, _name);
    await prefs.setString(_kEmail, _email);
    await prefs.setString(_kPhone, _phone);

    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _name = name.trim();
    _email = email.trim();
    _phone = phone.trim();

    await prefs.setString(_kName, _name);
    await prefs.setString(_kEmail, _email);
    await prefs.setString(_kPhone, _phone);

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn = false;

    // Xóa cờ đăng nhập, giữ lại info cũng được — nhưng bạn muốn logout sạch thì xóa hết:
    await prefs.remove(_kLoggedIn);
    await prefs.remove(_kName);
    await prefs.remove(_kEmail);
    await prefs.remove(_kPhone);

    _name = 'Người dùng';
    _email = '';
    _phone = '';

    notifyListeners();
  }
}
