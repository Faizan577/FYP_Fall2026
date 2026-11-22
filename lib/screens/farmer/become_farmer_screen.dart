import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/farmer.dart';
import '../../providers/auth_scope.dart';
import '../../services/farmer_service.dart';
import '../../widgets/primary_button.dart';

class BecomeFarmerScreen extends StatefulWidget {
  const BecomeFarmerScreen({super.key});

  @override
  State<BecomeFarmerScreen> createState() => _BecomeFarmerScreenState();
}

class _BecomeFarmerScreenState extends State<BecomeFarmerScreen> {
  final _form = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _servicesController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _rateController = TextEditingController(text: 'Rs. 2,000 / day');
  final _farmerService = FarmerService();

  bool _isAvailable = true;
  bool _isSubmitting = false;

  final Map<String, bool> _skills = {
    'Crop Farming': true,
    'Tree Plantation': false,
    'Irrigation Management': true,
    'Farm Maintenance': false,
    'Pest Management': false,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AuthScope.of(context).profile;
    if (_nameController.text.isEmpty && user?.name != null && !user!.isGuest) {
      _nameController.text = user.name;
    }
    if (_locationController.text.isEmpty && user?.location != null && !user!.isGuest) {
      _locationController.text = user.location;
    }
    if (_servicesController.text.isEmpty) {
      _servicesController.text = 'Field Preparation, Sowing, Crop Management';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _experienceController.dispose();
    _servicesController.dispose();
    _aboutMeController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _submitProfile() async {
    if (!_form.currentState!.validate()) return;

    final selectedSkills = _skills.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one farming skill'),
          backgroundColor: AppColors.gardenAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = AuthScope.of(context);
    final user = auth.profile;
    final expYears = int.tryParse(_experienceController.text.trim()) ?? 1;

    final parsedServices = _servicesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final newFarmer = Farmer(
      id: 'farmer_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.email ?? 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      experienceYears: expYears,
      skills: selectedSkills,
      services: parsedServices.isNotEmpty
          ? parsedServices
          : selectedSkills.map((s) => '$s Service').toList(),
      availability: _isAvailable,
      rating: 5.0,
      reviewsCount: 1,
      dailyRate: _rateController.text.trim().isNotEmpty
          ? _rateController.text.trim()
          : 'Rs. 2,000 / day',
      phone: user?.phone ?? '0300 1234567',
      description: _aboutMeController.text.trim(),
    );

    await _farmerService.addFarmer(newFarmer);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.soft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Profile Registered!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your farmer profile is now active on Baghbani. It will now appear in the Hire Farmer directory for land owners seeking services.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context, true); // return
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthScope.of(context).profile;
    final initials = (user?.name.isNotEmpty ?? false)
        ? user!.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : 'F';

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('Become a Farmer'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            // Intro Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.eco_rounded, color: AppColors.primary, size: 32),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Offer Your Farming Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Register as a service provider on Baghbani to receive direct hiring requests from land owners.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 1: Personal Information
            _sectionHeader('Personal Information'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  // Profile Picture Preview
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.soft,
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. Tariq Mehmood',
                      prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.muted),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 14),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location / District',
                      hintText: 'e.g. Sahiwal, Punjab',
                      prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Enter your location' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // SECTION 2: Farming Information
            _sectionHeader('Farming Information'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Experience Years & Rate
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Experience (Years)',
                            hintText: 'e.g. 5',
                            prefixIcon: Icon(Icons.work_history_outlined, color: AppColors.muted),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            if (int.tryParse(v.trim()) == null) return 'Numbers only';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _rateController,
                          decoration: const InputDecoration(
                            labelText: 'Daily Rate',
                            hintText: 'Rs. 2,000 / day',
                            prefixIcon: Icon(Icons.payments_outlined, color: AppColors.muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Skills Checkboxes
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._skills.keys.map((skill) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        skill,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.dark,
                        ),
                      ),
                      value: _skills[skill],
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _skills[skill] = val ?? false);
                      },
                    );
                  }),
                  const SizedBox(height: 14),

                  // Available Services Field
                  TextFormField(
                    controller: _servicesController,
                    decoration: const InputDecoration(
                      labelText: 'Available Services',
                      hintText: 'e.g. Soil Tillage, Sowing, Laser Leveling',
                      prefixIcon: Icon(Icons.handyman_outlined, color: AppColors.muted),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Enter your services' : null,
                  ),
                  const SizedBox(height: 14),

                  // About Me Field
                  TextFormField(
                    controller: _aboutMeController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'About Me',
                      hintText:
                          'Share your agricultural background, crops managed, machinery operated, or preferred working seasons…',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please share a brief summary of your background'
                        : null,
                  ),
                  const SizedBox(height: 18),

                  // Availability Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Availability Status',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAvailable ? 'Available for new work' : 'Currently Not Available',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _isAvailable ? AppColors.primary : Colors.orange[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Submit Button
            PrimaryButton(
              label: 'Submit Profile',
              icon: Icons.check_circle_rounded,
              busy: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.dark,
    ),
  );
}
