import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_scope.dart';
import '../../widgets/baghbani_logo.dart';
import '../../widgets/primary_button.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo from Figma (node 3:367)
              const BaghbaniLogo(size: 46),
              const SizedBox(height: 14),
              const Text(
                'Welcome to BaghBani',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Smart farming and gardening, all in one place.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              // 2x2 Feature Grid matching Figma (node 3:372 & 3:387)
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  physics: const NeverScrollableScrollPhysics(),
                  children: const [
                    _FeatureCard(
                      title: 'Smart Farming',
                      subtitle: 'Crop & tree advice',
                      icon: Icons.agriculture_rounded,
                    ),
                    _FeatureCard(
                      title: 'Plant Care',
                      subtitle: 'Plants for your home',
                      icon: Icons.local_florist_rounded,
                    ),
                    _FeatureCard(
                      title: 'Marketplace',
                      subtitle: 'Buy from nurseries',
                      icon: Icons.storefront_rounded,
                    ),
                    _FeatureCard(
                      title: 'Community',
                      subtitle: 'Farmers & land',
                      icon: Icons.handshake_rounded,
                    ),
                  ],
                ),
              ),

              // CTA Buttons
              PrimaryButton(
                label: 'Log in',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Create account',
                outlined: true,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const SignupScreen()),
                ),
              ),
              const SizedBox(height: 14),

              // Continue as Guest (Figma node 3:407)
              Center(
                child: TextButton(
                  onPressed: () async {
                    await AuthScope.of(context).continueAsGuest();
                    if (!context.mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (_) => const DashboardScreen(),
                      ),
                      (_) => false,
                    );
                  },
                  child: const Text(
                    'Continue as Guest',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
