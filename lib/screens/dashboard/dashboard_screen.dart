import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_scope.dart';
import '../../widgets/feature_tile.dart';
import '../../widgets/section_heading.dart';
import '../coming_soon_screen.dart';
import '../farmer/become_farmer_screen.dart';
import '../farmer/farmer_listing_screen.dart';
import '../farmer/widgets/login_required_dialog.dart';
import '../help/help_guide_screen.dart';
import '../land/offer_land_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onOpenNotifications: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
      )),
      const _PlantsExploreTab(),
      const _CommunityExploreTab(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(index: _tab, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: NavigationBar(
          backgroundColor: AppColors.white,
          indicatorColor: AppColors.soft,
          elevation: 0,
          selectedIndex: _tab,
          onDestinationSelected: (value) => setState(() => _tab = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.muted),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_florist_outlined, color: AppColors.muted),
              selectedIcon: Icon(Icons.local_florist_rounded, color: AppColors.primary),
              label: 'Plants',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppColors.muted),
              selectedIcon: Icon(Icons.groups_rounded, color: AppColors.primary),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.muted),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onOpenNotifications});
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final user = auth.profile;
    final isGuest = auth.isGuest || (user?.isGuest ?? false);
    final displayName = isGuest ? 'Guest' : (user?.name.split(' ').first ?? 'Gardener');

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          // Header (Greeting + Notification button matching Figma 3:810)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good morning,',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Welcome, $displayName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
              // Notifications button: circular white pill from Figma (node 3:814)
              InkWell(
                onTap: onOpenNotifications,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.dark,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Search Bar matching Figma (node 3:17)
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.muted, size: 22),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search plants, crops, nurseries…',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(Icons.tune_rounded, color: AppColors.muted.withValues(alpha: 0.6), size: 18),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hero Banner matching Figma (node 3:817)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  right: -30,
                  top: -40,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan your next harvest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Analyze your land with satellite insights and get tailored crop advice.',
                      style: TextStyle(
                        color: AppColors.sageLight,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _openComingSoon(context, 'Land Satellite Analysis'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.sageLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Get started',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Row matching Figma (node 3:823)
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickActionTile(
                label: 'Explore',
                icon: Icons.grid_view_rounded,
                tint: AppColors.nurseryTint,
                iconColor: AppColors.nurseryAccent,
                onTap: () => _openComingSoon(context, 'Explore Baghbani'),
              ),
              _QuickActionTile(
                label: 'Crops',
                icon: Icons.agriculture_rounded,
                tint: AppColors.farmTint,
                iconColor: AppColors.farmAccent,
                onTap: () => _openComingSoon(context, 'Crop Recommendation'),
              ),
              _QuickActionTile(
                label: 'Plants',
                icon: Icons.local_florist_rounded,
                tint: AppColors.gardenTint,
                iconColor: AppColors.gardenAccent,
                onTap: () => _openComingSoon(context, 'Plant Recommendation'),
              ),
              _QuickActionTile(
                label: 'Trees',
                icon: Icons.park_rounded,
                tint: AppColors.farmTint,
                iconColor: AppColors.farmAccent,
                onTap: () => _openComingSoon(context, 'Tree Recommendation'),
              ),
            ],
          ),
          const SizedBox(height: 26),

          // 🌾 FARM Section Card matching Figma (node 3:830)
          _SectionContainer(
            title: 'Farm',
            subtitle: 'Smart land & crop planning',
            accentColor: AppColors.farmAccent,
            children: [
              FeatureRowTile(
                title: 'Crop Recommendation',
                subtitle: 'Match crops to your land & season',
                icon: Icons.agriculture_rounded,
                tint: AppColors.farmTint,
                iconColor: AppColors.farmAccent,
                showDivider: true,
                onTap: () => _openComingSoon(context, 'Crop Recommendation'),
              ),
              FeatureRowTile(
                title: 'Tree Recommendation',
                subtitle: 'Choose trees suited for your climate',
                icon: Icons.park_rounded,
                tint: AppColors.farmTint,
                iconColor: AppColors.farmAccent,
                showDivider: true,
                onTap: () => _openComingSoon(context, 'Tree Recommendation'),
              ),
              FeatureRowTile(
                title: 'Plantation Planning',
                subtitle: 'Organize schedule and field layout',
                icon: Icons.calendar_month_rounded,
                tint: AppColors.farmTint,
                iconColor: AppColors.farmAccent,
                onTap: () => _openComingSoon(context, 'Plantation Planning'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🏡 GARDEN Section Card matching Figma (node 3:838)
          _SectionContainer(
            title: 'Garden',
            subtitle: 'Care for your home garden',
            accentColor: AppColors.gardenAccent,
            children: [
              FeatureRowTile(
                title: 'Plant Recommendation',
                subtitle: 'Find indoor and outdoor plants',
                icon: Icons.local_florist_rounded,
                tint: AppColors.gardenTint,
                iconColor: AppColors.gardenAccent,
                showDivider: true,
                onTap: () => _openComingSoon(context, 'Plant Recommendation'),
              ),
              FeatureRowTile(
                title: 'Plant Health Analysis',
                subtitle: 'Diagnose leaf and stem symptoms',
                icon: Icons.health_and_safety_rounded,
                tint: AppColors.gardenTint,
                iconColor: AppColors.gardenAccent,
                onTap: () => _openComingSoon(context, 'Plant Health Analysis'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🌱 NURSERY Section Card matching Figma (node 3:846)
          _SectionContainer(
            title: 'Nursery',
            subtitle: 'Find and buy healthy plants',
            accentColor: AppColors.nurseryAccent,
            children: [
              FeatureRowTile(
                title: 'Browse Plants',
                subtitle: 'Explore full catalog with prices',
                icon: Icons.yard_rounded,
                tint: AppColors.nurseryTint,
                iconColor: AppColors.nurseryAccent,
                showDivider: true,
                onTap: () => _openComingSoon(context, 'Browse Plants'),
              ),
              FeatureRowTile(
                title: 'Nearby Nurseries',
                subtitle: 'Locate verified nurseries near you',
                icon: Icons.storefront_rounded,
                tint: AppColors.nurseryTint,
                iconColor: AppColors.nurseryAccent,
                showDivider: true,
                onTap: () => _openComingSoon(context, 'Nearby Nurseries'),
              ),
              FeatureRowTile(
                title: 'Wishlist',
                subtitle: 'Save favorites for next season',
                icon: Icons.favorite_border_rounded,
                tint: AppColors.nurseryTint,
                iconColor: AppColors.nurseryAccent,
                onTap: () => _openComingSoon(context, 'Wishlist'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 🤝 COMMUNITY Section Card matching Figma (node 3:854)
          _SectionContainer(
            title: 'Community',
            subtitle: 'Connect with farmers & landowners',
            accentColor: AppColors.communityAccent,
            children: [
              FeatureRowTile(
                title: 'Hire Farmer',
                subtitle: 'Find skilled farmers for your land',
                icon: Icons.groups_rounded,
                tint: AppColors.communityTint,
                iconColor: AppColors.communityAccent,
                showDivider: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const FarmerListingScreen(),
                  ),
                ),
              ),
              FeatureRowTile(
                title: 'Become a Farmer',
                subtitle: 'Offer your farming services',
                icon: Icons.person_add_alt_1_rounded,
                tint: AppColors.soft,
                iconColor: AppColors.primary,
                showDivider: true,
                onTap: () async {
                  if (isGuest) {
                    await LoginRequiredDialog.show(
                      context,
                      actionName: 'register as a farmer',
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const BecomeFarmerScreen(),
                      ),
                    );
                  }
                },
              ),
              FeatureRowTile(
                title: 'Offer Land',
                subtitle: 'Find farmers for your land',
                icon: Icons.landscape_rounded,
                tint: AppColors.farmTint,
                iconColor: AppColors.farmAccent,
                onTap: () async {
                  if (isGuest) {
                    await LoginRequiredDialog.show(
                      context,
                      actionName: 'offer your land',
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const OfferLandScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openComingSoon(BuildContext context, String feature) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ComingSoonScreen(feature: feature),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.children,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF245C43).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: title,
            subtitle: subtitle,
            accentColor: accentColor,
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.tint,
    required this.iconColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantsExploreTab extends StatelessWidget {
  const _PlantsExploreTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.cream,
    appBar: AppBar(title: const Text('Plants & Nurseries')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gardenTint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.local_florist_rounded, color: AppColors.gardenAccent, size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              'Plant Catalog & Care',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.dark),
            ),
            const SizedBox(height: 8),
            const Text(
              'Browse hundreds of plants, seeds and care guides from certified nurseries.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.45),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CommunityExploreTab extends StatelessWidget {
  const _CommunityExploreTab();
  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final isGuest = auth.isGuest || (auth.profile?.isGuest ?? false);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Grower Community')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.communityTint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.handshake_rounded, color: AppColors.communityAccent, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Agricultural Community',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Connecting landowners, skilled farmers, and service providers across Pakistan.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Hire Farmer Card
          _communityActionCard(
            context,
            icon: Icons.groups_rounded,
            title: 'Hire Farmer',
            subtitle: 'Find skilled farmers for your land',
            description: 'Browse verified growers, view ratings & skills, and send direct hiring requests.',
            tint: AppColors.communityTint,
            accent: AppColors.communityAccent,
            buttonText: 'Browse Farmers',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const FarmerListingScreen(),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Become a Farmer Card
          _communityActionCard(
            context,
            icon: Icons.person_add_alt_1_rounded,
            title: 'Become a Farmer',
            subtitle: 'Offer your farming services',
            description: 'Register your skills, daily rates, and availability to receive work requests.',
            tint: AppColors.soft,
            accent: AppColors.primary,
            buttonText: 'Register as Farmer',
            onTap: () async {
              if (isGuest) {
                await LoginRequiredDialog.show(
                  context,
                  actionName: 'register as a farmer',
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const BecomeFarmerScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 14),

          // 3. Offer Land Card
          _communityActionCard(
            context,
            icon: Icons.landscape_rounded,
            title: 'Offer Land',
            subtitle: 'Find farmers for your land',
            description: 'List your agricultural acreage and water resources to partner with reliable growers.',
            tint: AppColors.farmTint,
            accent: AppColors.farmAccent,
            buttonText: 'Offer Your Land',
            onTap: () async {
              if (isGuest) {
                await LoginRequiredDialog.show(
                  context,
                  actionName: 'offer your land',
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const OfferLandScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _communityActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required Color tint,
    required Color accent,
    required String buttonText,
    required VoidCallback onTap,
  }) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
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
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
            ),
          ),
        ),
      ],
    ),
  );
}
