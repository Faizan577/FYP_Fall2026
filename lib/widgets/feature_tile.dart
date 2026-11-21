import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class FeatureRowTile extends StatelessWidget {
  const FeatureRowTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.tint = AppColors.soft,
    this.iconColor = AppColors.dark,
    this.subtitle,
    this.showDivider = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color tint;
  final Color iconColor;
  final String? subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Figma icon tile: 44x44, rounded 12px with section tint
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.muted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
      if (showDivider)
        const Divider(
          color: AppColors.border,
          height: 1,
          thickness: 1,
        ),
    ],
  );
}
