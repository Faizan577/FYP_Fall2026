import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'core/app.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    sqflite.databaseFactory = databaseFactoryFfiWeb;
  }
  final auth = AuthController(AuthService());
  await auth.restore();
  runApp(BaghbaniApp(auth: auth));
}
