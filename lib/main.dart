import 'package:flutter/material.dart';
import 'core/app.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthController(AuthService());
  await auth.restore();
  runApp(BaghbaniApp(auth: auth));
}
