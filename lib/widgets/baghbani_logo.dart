import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BaghbaniLogo extends StatelessWidget {
  const BaghbaniLogo({
    super.key,
    this.size = 48,
    this.showText = false,
    this.lightText = false,
  });

  final double size;
  final bool showText;
  final bool lightText;

  @override
  Widget build(BuildContext context) {
    // Exact dual-leaf geometry from Figma (nodes 3:367 - 3:369)
    // Left petal: #245C43 with rounded top-left and bottom-right
    // Right petal: #4CAF68 with rounded bottom-left and top-right
    final width = size * (43.2 / 46.8);
    final height = size;

    final logoGraphic = SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Left dark petal
          Positioned(
            left: 0,
            top: height * (12.6 / 46.8),
            width: width * (21.6 / 43.2),
            height: height * (34.2 / 46.8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(height * (21.6 / 46.8)),
                  bottomRight: Radius.circular(height * (21.6 / 46.8)),
                ),
              ),
            ),
          ),
          // Right bright petal
          Positioned(
            left: width * (19.8 / 43.2),
            top: 0,
            width: width * (23.4 / 43.2),
            height: height * (43.2 / 46.8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF68),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(height * (23.4 / 46.8)),
                  topRight: Radius.circular(height * (23.4 / 46.8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!showText) return logoGraphic;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoGraphic,
        SizedBox(width: size * 0.25),
        Text(
          'BaghBani',
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: lightText ? Colors.white : AppColors.primary,
          ),
        ),
      ],
    );
  }
}
