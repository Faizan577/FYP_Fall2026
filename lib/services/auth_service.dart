import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'auth_database.dart';

class AuthService {
  AuthService({AuthDatabase? database})
      : _database = database ?? AuthDatabase();

  static const _legacyProfileKey = 'baghbani.profile';
  static const _legacyPasswordKey = 'baghbani.password_hash';
  static const _legacyMigrationKey = 'baghbani.sqlite_migration_complete';
  static const _loggedInKey = 'baghbani.signed_in';
  static const _guestKey = 'baghbani.is_guest';
  static const _userIdKey = 'baghbani.user_id';

  final AuthDatabase _database;

  Future<UserProfile?> restoreProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyCredentials(prefs);
    if (!(prefs.getBool(_loggedInKey) ?? false)) return null;
    if (prefs.getBool(_guestKey) ?? false) return UserProfile.guest;

    final userId = prefs.getInt(_userIdKey);
    if (userId == null) {
      await _clearSession(prefs);
      return null;
    }
    final user = await _database.findById(userId);
    if (user == null) {
      await _clearSession(prefs);
      return null;
    }
    return user.profile;
  }

  Future<bool> register(UserProfile profile, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyCredentials(prefs);
    final userId = await _database.insertUser(profile, _hash(password));
    if (userId == 0) return false;
    await _saveSession(prefs, userId);
    return true;
  }

  Future<bool> signIn(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyCredentials(prefs);
    final user = await _database.findByEmail(email);
    if (user == null || user.passwordHash != _hash(password)) return false;
    await _saveSession(prefs, user.id);
    return true;
  }

  Future<void> setGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyCredentials(prefs);
    await prefs.remove(_userIdKey);
    await prefs.setBool(_guestKey, true);
    await prefs.setBool(_loggedInKey, true);
  }

  Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    if (!(prefs.getBool(_loggedInKey) ?? false) ||
        (prefs.getBool(_guestKey) ?? false) ||
        userId == null) {
      throw StateError('A signed-in user is required to update the profile.');
    }
    await _database.updateUser(userId, profile);
  }

  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await _clearSession(prefs);
  }

  Future<bool> sendPasswordReset(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyCredentials(prefs);
    return await _database.findByEmail(email) != null;
  }

  Future<bool> resetPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyCredentials(prefs);
    final user = await _database.findByEmail(email);
    if (user == null) return false;
    await _database.updatePassword(user.id, _hash(password));
    await _clearSession(prefs);
    return true;
  }

  Future<void> close() => _database.close();

  Future<void> _migrateLegacyCredentials(SharedPreferences prefs) async {
    if (prefs.getBool(_legacyMigrationKey) ?? false) return;

    final rawProfile = prefs.getString(_legacyProfileKey);
    final passwordHash = prefs.getString(_legacyPasswordKey);
    if (rawProfile != null && passwordHash != null) {
      final profile =
          UserProfile.fromJson(jsonDecode(rawProfile) as Map<String, dynamic>);
      final insertedId = await _database.insertUser(profile, passwordHash);
      if ((prefs.getBool(_loggedInKey) ?? false) &&
          !(prefs.getBool(_guestKey) ?? false)) {
        final user = insertedId == 0
            ? await _database.findByEmail(profile.email)
            : await _database.findById(insertedId);
        if (user != null) {
          await prefs.setInt(_userIdKey, user.id);
        } else {
          await prefs.setBool(_loggedInKey, false);
        }
      }
    }
    await prefs.remove(_legacyProfileKey);
    await prefs.remove(_legacyPasswordKey);
    await prefs.setBool(_legacyMigrationKey, true);
  }

  Future<void> _saveSession(SharedPreferences prefs, int userId) async {
    await prefs.setInt(_userIdKey, userId);
    await prefs.setBool(_guestKey, false);
    await prefs.setBool(_loggedInKey, true);
  }

  Future<void> _clearSession(SharedPreferences prefs) async {
    await prefs.setBool(_loggedInKey, false);
    await prefs.setBool(_guestKey, false);
    await prefs.remove(_userIdKey);
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
    isLoading = true;
    notifyListeners();
    try {
      profile = await _service.restoreProfile();
      isAuthenticated = profile != null;
      isGuest = profile?.isGuest ?? false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(UserProfile user, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await _service.register(user, password);
      if (!success) return false;
      profile = user.copyWith(isGuest: false);
      isAuthenticated = true;
      isGuest = false;
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      final success = await _service.signIn(email, password);
      if (success) {
        profile = await _service.restoreProfile();
        isAuthenticated = profile != null;
        isGuest = false;
      }
      return success;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.setGuestMode();
      profile = UserProfile.guest;
      isAuthenticated = true;
      isGuest = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(UserProfile user) async {
    await _service.updateProfile(user);
    profile = user.copyWith(isGuest: false);
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
