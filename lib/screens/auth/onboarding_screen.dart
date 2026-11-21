import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/baghbani_logo.dart';
import '../../widgets/primary_button.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  int _index = 0;

  final _slides = const [
    _OnboardData(
      icon: Icons.satellite_alt_rounded,
      title: 'Smart farming,\npowered by AI',
      body:
          'Get crop and tree recommendations from satellite analysis, plan plantations and connect with nurseries and farmers.',
      accent: AppColors.primary,
    ),
    _OnboardData(
      icon: Icons.local_florist_rounded,
      title: 'Plant care\nfor your home',
      body:
          'Discover beautiful plants tailored for your space, receive personalized watering guidance and assess plant health with ease.',
      accent: AppColors.gardenAccent,
    ),
    _OnboardData(
      icon: Icons.groups_rounded,
      title: 'Connect with\nfarmers & nurseries',
      body:
          'Find reputable nearby nurseries, explore verified local growers, hire skilled agricultural assistance, or offer land for cultivation.',
      accent: AppColors.communityAccent,
    ),
  ];

  void _finish() => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
  );

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, i) {
                  final data = _slides[i];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Concentric Figma-style circular illustration
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data.accent.withValues(alpha: 0.08),
                            ),
                          ),
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data.accent.withValues(alpha: 0.15),
                            ),
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: i == 0
                                  ? const BaghbaniLogo(size: 46)
                                  : Icon(data.icon, size: 48, color: data.accent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 44),
                      Text(
                        data.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 27,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        data.body,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.55,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            // Page Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: i == _index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: _index == _slides.length - 1 ? 'Get started' : 'Next',
              onPressed: () => _index == _slides.length - 1
                  ? _finish()
                  : _page.nextPage(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _OnboardData {
  const _OnboardData({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });
  final IconData icon;
  final String title;
  final String body;
  final Color accent;
}
