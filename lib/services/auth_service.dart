import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthService {
  static const _profileKey = 'baghbani.profile';
  static const _passwordKey = 'baghbani.password_hash';
  static const _signedInKey = 'baghbani.signed_in';
  static const _guestKey = 'baghbani.is_guest';

  Future<UserProfile?> restoreProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(_guestKey) ?? false;
    if (isGuest) {
      return UserProfile.guest;
    }
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> register(UserProfile profile, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    await prefs.setString(_passwordKey, _hash(password));
    await prefs.setBool(_signedInKey, true);
    await prefs.setBool(_guestKey, false);
  }

  Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return false;
    final profile = UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    if (profile.email.toLowerCase() != email.trim().toLowerCase()) {
      return false;
    }
    final expected = prefs.getString(_passwordKey);
    if (expected == null || expected != _hash(password)) return false;
    await prefs.setBool(_signedInKey, true);
    await prefs.setBool(_guestKey, false);
    return true;
  }

  Future<void> setGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, true);
    await prefs.setBool(_guestKey, true);
  }

  Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    await prefs.setBool(_guestKey, false);
  }

  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_signedInKey) ?? false;
  }

  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, false);
    await prefs.setBool(_guestKey, false);
  }

  Future<bool> sendPasswordReset(String email) async {
    final profile = await restoreProfile();
    return profile != null &&
        profile.email.toLowerCase() == email.trim().toLowerCase();
  }

  Future<bool> resetPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final profile = await restoreProfile();
    if (profile == null ||
        profile.email.toLowerCase() != email.trim().toLowerCase()) {
      return false;
    }
    await prefs.setString(_passwordKey, _hash(password));
    await prefs.setBool(_signedInKey, false);
    await prefs.setBool(_guestKey, false);
    return true;
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
}

class AuthController extends ChangeNotifier {
  AuthController(this._service);
  final AuthService _service;
  UserProfile? profile;
  bool isAuthenticated = false;
  bool isGuest = false;
  bool isLoading = false;

  Future<void> restore() async {
    profile = await _service.restoreProfile();
    isAuthenticated = profile != null && await _service.isSignedIn();
    isGuest = await _service.isGuest();
    notifyListeners();
  }

  Future<bool> register(UserProfile user, String password) async {
    isLoading = true;
    notifyListeners();
    await _service.register(user, password);
    profile = user;
    isAuthenticated = true;
    isGuest = false;
    isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();
    final success = await _service.signIn(email, password);
    if (success) {
      profile = await _service.restoreProfile();
      isAuthenticated = true;
      isGuest = false;
    }
    isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> continueAsGuest() async {
    isLoading = true;
    notifyListeners();
    await _service.setGuestMode();
    profile = UserProfile.guest;
    isAuthenticated = true;
    isGuest = true;
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile user) async {
    await _service.updateProfile(user);
    profile = user;
    isGuest = false;
    notifyListeners();
  }

  Future<bool> sendPasswordReset(String email) =>
      _service.sendPasswordReset(email);
  Future<bool> resetPassword(String email, String password) =>
      _service.resetPassword(email, password);

  Future<void> signOut() async {
    await _service.signOut();
    profile = null;
    isAuthenticated = false;
    isGuest = false;
    notifyListeners();
  }
}
