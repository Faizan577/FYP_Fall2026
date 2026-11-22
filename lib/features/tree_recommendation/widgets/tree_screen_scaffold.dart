import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class TreeScreenScaffold extends StatelessWidget {
  const TreeScreenScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SafeArea(
          top: false,
          child: child,
        ),
        backgroundColor: AppColors.cream,
      );
}

class TreeInfoCard extends StatelessWidget {
  const TreeInfoCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: child,
      );
}
