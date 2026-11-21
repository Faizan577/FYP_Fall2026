import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/primary_button.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.feature});
  final String feature;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(
      backgroundColor: AppColors.cream,
      elevation: 0,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.soft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: AppColors.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              feature,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This module is currently in development and will be connected to the AI recommendations engine in the next phase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Back to Dashboard',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    ),
  );
}
