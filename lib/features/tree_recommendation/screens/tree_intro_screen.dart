import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../navigation/protected_feature_navigation.dart';
import '../../../screens/auth/login_screen.dart';
import '../../../widgets/primary_button.dart';
import '../widgets/tree_screen_scaffold.dart';
import 'location_screen.dart';

class TreeIntroScreen extends StatelessWidget {
  const TreeIntroScreen({super.key});

  @override
  Widget build(BuildContext context) => TreeScreenScaffold(
        title: 'Tree Recommendation',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: AppColors.farmTint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.park_rounded,
                  color: AppColors.farmAccent, size: 86),
            ),
            const SizedBox(height: 22),
            const Text(
              'Find the right trees for your land',
              style: TextStyle(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark),
            ),
            const SizedBox(height: 10),
            const Text(
              'We compare real NASA climate observations with the tree suitability dataset to find trees that fit your local conditions.',
              style:
                  TextStyle(fontSize: 14, height: 1.5, color: AppColors.muted),
            ),
            const SizedBox(height: 22),
            const TreeInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Requirement(
                      icon: Icons.location_on_outlined,
                      text: 'Select or search for your land location'),
                  SizedBox(height: 14),
                  _Requirement(
                      icon: Icons.thermostat_outlined,
                      text: 'Temperature and annual rainfall from NASA POWER'),
                  SizedBox(height: 14),
                  _Requirement(
                      icon: Icons.science_outlined,
                      text: 'Optional soil pH and irrigation availability'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Get started',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => ProtectedFeatureNavigation.open(
                context,
                destination: (_) => const LocationScreen(),
                loginScreenBuilder: (destination) =>
                    LoginScreen(onAuthenticated: destination),
              ),
            ),
          ],
        ),
      );
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 21, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.dark, height: 1.35))),
        ],
      );
}
