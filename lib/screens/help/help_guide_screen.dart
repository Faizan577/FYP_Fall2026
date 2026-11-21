import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class HelpGuideScreen extends StatelessWidget {
  const HelpGuideScreen({super.key});

  static const _guides = <_Guide>[
    _Guide(
      'How Baghbani Works',
      Icons.eco_rounded,
      'Baghbani combines smart satellite land analysis, personalized crop & tree planning, direct nursery shopping, and grower community collaboration into a single, seamless platform. Simply select any service from your home dashboard to begin.',
      AppColors.primary,
      AppColors.soft,
    ),
    _Guide(
      'Crop Recommendation Guide',
      Icons.agriculture_rounded,
      'Our AI analyzes your soil texture, historical seasonal weather, pH level, water capacity, and geographical coordinates to recommend optimal cash and food crops that offer the highest yield for your specific farmland.',
      AppColors.farmAccent,
      AppColors.farmTint,
    ),
    _Guide(
      'Tree Recommendation Guide',
      Icons.park_rounded,
      'Find perennial trees for shade, fruit, timber, or windbreaks based on root depth, annual water requirement, local climate zone, and spacing requirements.',
      AppColors.farmAccent,
      AppColors.farmTint,
    ),
    _Guide(
      'Plant Buying Guide',
      Icons.local_florist_rounded,
      'Examine nursery stock for healthy vibrant leaves, white root structure, and absent pests. Our nursery module connects you with certified local plant providers.',
      AppColors.gardenAccent,
      AppColors.gardenTint,
    ),
    _Guide(
      'Farmer Hiring Guide',
      Icons.handshake_rounded,
      'Post detailed requirements including task type (harvesting, seeding, weeding), duration, daily rate, and tools required to hire verified agricultural labor.',
      AppColors.communityAccent,
      AppColors.communityTint,
    ),
  ];

  static const _faqs = <_Guide>[
    _Guide(
      'Is Baghbani free to use?',
      Icons.help_outline_rounded,
      'Yes! All foundational features—including crop recommendations, plant search, nursery directory, and community listings—are free for growers.',
      AppColors.primary,
      AppColors.soft,
    ),
    _Guide(
      'Can I use Baghbani for home gardening?',
      Icons.yard_rounded,
      'Absolutely! The Garden and Nursery modules are specifically crafted with household plants, balcony gardens, and terrace planting in mind.',
      AppColors.gardenAccent,
      AppColors.gardenTint,
    ),
    _Guide(
      'Can I use the app without an account?',
      Icons.person_outline_rounded,
      'Yes, you can browse as a guest! However, creating a free account allows you to save your field analysis, wishlists, and customized alerts.',
      AppColors.communityAccent,
      AppColors.communityTint,
    ),
    _Guide(
      'How does satellite land analysis work?',
      Icons.satellite_alt_rounded,
      'By drawing your land boundary on the interactive map, our engine pulls remote-sensing GIS indexes to evaluate soil condition and vegetation health.',
      AppColors.farmAccent,
      AppColors.farmTint,
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(
      backgroundColor: AppColors.cream,
      title: const Text('Help & Guide'),
      elevation: 0,
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Hero Card matching Figma styling
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.sageLight, size: 42),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A little guidance goes a long way.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Explore walkthroughs, FAQs and agricultural tips.',
                      style: TextStyle(color: AppColors.sageLight, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Guides Section
        const _SectionHeader(
          title: 'Getting started',
          subtitle: 'Learn your way around Baghbani modules',
        ),
        const SizedBox(height: 12),
        ..._guides.map((g) => _GuideTile(guide: g)),

        const SizedBox(height: 24),

        // FAQs Section
        const _SectionHeader(
          title: 'Frequently Asked Questions',
          subtitle: 'Quick answers to common questions',
        ),
        const SizedBox(height: 12),
        ..._faqs.map((f) => _GuideTile(guide: f)),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: AppColors.dark,
          fontWeight: FontWeight.w700,
          fontSize: 19,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        subtitle,
        style: const TextStyle(color: AppColors.muted, fontSize: 13),
      ),
    ],
  );
}

class _GuideTile extends StatelessWidget {
  const _GuideTile({required this.guide});
  final _Guide guide;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: AppColors.white,
      border: Border.all(color: AppColors.borderLight),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: guide.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(guide.icon, color: guide.accent, size: 22),
        ),
        title: Text(
          guide.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.5,
            color: AppColors.dark,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        children: [
          Text(
            guide.body,
            style: const TextStyle(
              height: 1.55,
              color: AppColors.muted,
              fontSize: 13.5,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Guide {
  const _Guide(this.title, this.icon, this.body, this.accent, this.tint);
  final String title;
  final IconData icon;
  final String body;
  final Color accent;
  final Color tint;
}
