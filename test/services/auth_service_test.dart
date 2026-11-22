import 'dart:convert';
import 'dart:io';

import 'package:baghbani/models/user_profile.dart';
import 'package:baghbani/services/auth_database.dart';
import 'package:baghbani/services/auth_service.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  late Directory directory;
  late String databasePath;
  late AuthService service;

  AuthService createService() => AuthService(
        database: AuthDatabase(
          factory: databaseFactoryFfi,
          path: databasePath,
        ),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('baghbani-auth-test');
    databasePath = p.join(directory.path, 'users.sqlite');
    service = createService();
  });

  tearDown(() async {
    await service.close();
    await directory.delete(recursive: true);
  });

  const profile = UserProfile(
    name: 'Rahmeen',
    email: 'rahmeen12@gmail.com',
    phone: '5550100',
    location: 'Lahore',
  );

  test('persists accounts in SQLite and restores the session after restart',
      () async {
    expect(await service.register(profile, 'password123'), isTrue);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('baghbani.user_id');
    expect(userId, isNotNull);
    expect(prefs.getBool('baghbani.signed_in'), isTrue);

    final database = await databaseFactoryFfi.openDatabase(databasePath);
    final columns = await database.rawQuery('PRAGMA table_info(users)');
    expect(
      columns.map((column) => column['name']),
      containsAll([
        'id',
        'name',
        'email',
        'password_hash',
        'phone',
        'location',
        'created_at',
      ]),
    );
    final row = (await database.query('users')).single;
    expect(row['password_hash'], isNot('password123'));
    expect(row['created_at'], isNotEmpty);
    await database.close();

    await service.close();
    service = createService();
    final controller = AuthController(service);
    await controller.restore();
    expect(controller.isAuthenticated, isTrue);
    expect(controller.profile?.email, profile.email);
    controller.dispose();

    await service.signOut();
    await service.close();
    service = createService();

    expect(await service.restoreProfile(), isNull);
    expect(await service.signIn('RAHMEEN12@GMAIL.COM', 'password123'), isTrue);
    expect((await service.restoreProfile())?.email, profile.email);
    expect(prefs.getInt('baghbani.user_id'), userId);
    expect(prefs.getBool('baghbani.signed_in'), isTrue);
  });

  test('rejects duplicate email addresses without replacing the account',
      () async {
    expect(await service.register(profile, 'password123'), isTrue);
    expect(
      await service.register(
        profile.copyWith(name: 'Different User'),
        'another-password',
      ),
      isFalse,
    );
    expect(await service.signIn(profile.email, 'password123'), isTrue);
    expect(await service.signIn(profile.email, 'another-password'), isFalse);
  });

  test('migrates existing SharedPreferences accounts into SQLite', () async {
    final legacyPrefs = await SharedPreferences.getInstance();
    await legacyPrefs.setString(
      'baghbani.profile',
      jsonEncode(profile.toJson()),
    );
    await legacyPrefs.setString(
      'baghbani.password_hash',
      sha256.convert(utf8.encode('password123')).toString(),
    );
    await legacyPrefs.setBool('baghbani.signed_in', true);

    final restored = await service.restoreProfile();

    expect(restored?.email, profile.email);
    expect(legacyPrefs.getInt('baghbani.user_id'), isNotNull);
    expect(legacyPrefs.getString('baghbani.profile'), isNull);
    expect(await service.signIn(profile.email, 'password123'), isTrue);
  });

  test('sign out clears the persistent session but keeps the account',
      () async {
    await service.register(profile, 'password123');

    await service.signOut();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('baghbani.signed_in'), isFalse);
    expect(prefs.getInt('baghbani.user_id'), isNull);
    expect(await service.signIn(profile.email, 'password123'), isTrue);
  });
}
