import 'package:flutter/material.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/help/help_guide_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';

abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const help = '/help';
  static const notifications = '/notifications';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final Widget? screen = switch (settings.name) {
      welcome => const WelcomeScreen(),
      onboarding => const OnboardingScreen(),
      login => const LoginScreen(),
      signup => const SignupScreen(),
      forgotPassword => const ForgotPasswordScreen(),
      dashboard => const DashboardScreen(),
      profile => const ProfileScreen(),
      editProfile => const EditProfileScreen(),
      help => const HelpGuideScreen(),
      notifications => const NotificationsScreen(),
      _ => null,
    };
    if (screen == null) return null;
    return MaterialPageRoute<void>(builder: (_) => screen, settings: settings);
  }
}
