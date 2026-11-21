import 'package:flutter/material.dart';
import '../providers/auth_scope.dart';
import '../routes/app_routes.dart';
import '../screens/auth/splash_screen.dart';
import '../services/auth_service.dart';
import 'theme/app_theme.dart';

class BaghbaniApp extends StatelessWidget {
  const BaghbaniApp({super.key, required this.auth});
  final AuthController auth;

  @override
  Widget build(BuildContext context) => AuthScope(
    controller: auth,
    child: MaterialApp(
      title: 'Baghbani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
          onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const SplashScreen(),
    ),
  );
}
