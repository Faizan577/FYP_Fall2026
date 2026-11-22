import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/land_offer.dart';
import '../../providers/auth_scope.dart';
import '../../services/land_service.dart';
import '../../widgets/primary_button.dart';

class OfferLandScreen extends StatefulWidget {
  const OfferLandScreen({super.key});

  @override
  State<OfferLandScreen> createState() => _OfferLandScreenState();
}

class _OfferLandScreenState extends State<OfferLandScreen> {
  final _form = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _acreageController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _landService = LandService();

  String _selectedWaterSource = 'Canal Water';
  String _selectedPartnership = 'Crop Sharing';
  bool _isSubmitting = false;

  final List<String> _waterSources = [
    'Canal Water',
    'Tube-well',
    'Drip System',
    'Canal + Tube-well',
    'Rainfed',
  ];

  final List<String> _partnershipTypes = [
    'Crop Sharing',
    'Full Management',
    'Seasonal Lease',
    'Contract Farming',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AuthScope.of(context).profile;
    if (_locationController.text.isEmpty && user?.location != null && !user!.isGuest) {
      _locationController.text = user.location;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _acreageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitLandOffer() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final user = AuthScope.of(context).profile;
    final offer = LandOffer(
      id: 'land_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.email ?? 'usr_anonymous',
      ownerName: user?.name ?? 'Land Owner',
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      acreage: '${_acreageController.text.trim()} Acres',
      waterSource: _selectedWaterSource,
      partnershipType: _selectedPartnership,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _landService.submitLandOffer(offer);

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
                color: AppColors.farmTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.landscape_rounded, color: AppColors.farmAccent, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Land Listed Successfully!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your land requirement has been published in the Baghbani Community. Suitable farmers in your district will be able to review and connect.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // return to dashboard
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        title: const Text('Offer Land'),
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
                  Icon(Icons.landscape_rounded, color: AppColors.farmAccent, size: 34),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Find Farmers for Your Land',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'List your available acreage, water resources, and partnership terms to connect with experienced growers.',
                          style: TextStyle(fontSize: 12.5, color: AppColors.muted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Listing Title
            _label('Listing Title'),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'e.g. 15 Acres Agricultural Land for Wheat & Cotton',
                prefixIcon: Icon(Icons.title_rounded, color: AppColors.muted),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: 18),

            // Location
            _label('Land Location / District / Tehsil'),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Near Raiwind Road, Lahore',
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter land location' : null,
            ),
            const SizedBox(height: 18),

            // Acreage
            _label('Total Land Size (Acres)'),
            TextFormField(
              controller: _acreageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 12',
                prefixIcon: Icon(Icons.square_foot_rounded, color: AppColors.muted),
                suffixText: 'Acres',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter number of acres' : null,
            ),
            const SizedBox(height: 20),

            // Water Source Selection
            _label('Primary Water Source'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _waterSources.map((source) {
                final isSelected = _selectedWaterSource == source;
                return ChoiceChip(
                  label: Text(source),
                  selected: isSelected,
                  selectedColor: AppColors.farmAccent,
                  backgroundColor: AppColors.white,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.dark,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.farmAccent : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedWaterSource = source);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Partnership Type Selection
            _label('Partnership / Service Model'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _partnershipTypes.map((type) {
                final isSelected = _selectedPartnership == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.white,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.dark,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedPartnership = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Description
            _label('Land Details & Soil Condition'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Describe soil quality, current standing crops (if any), electricity availability, tractor access, or specific requirements…',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please describe your land' : null,
            ),
            const SizedBox(height: 28),

            // Submit Button
            PrimaryButton(
              label: 'Submit Land Requirement',
              icon: Icons.check_circle_rounded,
              busy: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitLandOffer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
      ),
    ),
  );
}
