import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _currentUserEmail;
  String? _currentUserName;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _currentUserEmail = prefs.getString('currentUserEmail');
    _currentUserName = prefs.getString('currentUserName');
    notifyListeners();
  }

  Future<void> login(String email, String name) async {
    _isAuthenticated = true;
    _currentUserEmail = email;
    _currentUserName = name;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('currentUserEmail', email);
    await prefs.setString('currentUserName', name);

    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUserEmail = null;
    _currentUserName = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('currentUserEmail');
    await prefs.remove('currentUserName');

    notifyListeners();
  }
}
