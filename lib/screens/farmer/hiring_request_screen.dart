import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/farmer.dart';
import '../../models/hiring_request.dart';
import '../../providers/auth_scope.dart';
import '../../services/farmer_service.dart';
import '../../widgets/primary_button.dart';

class HiringRequestScreen extends StatefulWidget {
  const HiringRequestScreen({super.key, required this.farmer});

  final Farmer farmer;

  @override
  State<HiringRequestScreen> createState() => _HiringRequestScreenState();
}

class _HiringRequestScreenState extends State<HiringRequestScreen> {
  final _form = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _messageController = TextEditingController();
  final _farmerService = FarmerService();

  String _selectedWorkType = 'Crop Farming';
  String _selectedDuration = '1 Month';
  bool _isSubmitting = false;

  final List<String> _workTypes = [
    'Crop Farming',
    'Tree Plantation',
    'Land Maintenance',
    'Irrigation Management',
  ];

  final List<String> _durations = [
    '1 Month',
    '3 Months',
    'Seasonal',
    'Contract / Task Based',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AuthScope.of(context).profile;
    if (_locationController.text.isEmpty && user?.location != null && user!.location.isNotEmpty) {
      _locationController.text = user.location;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final user = AuthScope.of(context).profile;
    final request = HiringRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      senderUserId: user?.email ?? 'user_anonymous',
      farmerId: widget.farmer.id,
      farmerName: widget.farmer.name,
      landLocation: _locationController.text.trim(),
      workType: _selectedWorkType,
      duration: _selectedDuration,
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    await _farmerService.submitHiringRequest(request);

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
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 36),
            ),
            const SizedBox(height: 18),
            const Text(
              'Request Sent!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your hiring request has been submitted to ${widget.farmer.name}. The farmer will review your request details and respond.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close hiring screen
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
        title: const Text('Send Hiring Request'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            // Target Farmer Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.soft,
                    child: Text(
                      widget.farmer.name.isNotEmpty ? widget.farmer.name[0] : 'F',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.farmer.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                        Text(
                          '${widget.farmer.location} • ${widget.farmer.experienceYears} Years Exp.',
                          style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Land Location Field
            _label('Land Location / Address'),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Chak 42-RB, Faisalabad Road',
                prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.muted),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Please enter land location' : null,
            ),
            const SizedBox(height: 20),

            // Required Work Type Selection
            _label('Required Work Type'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _workTypes.map((type) {
                final isSelected = _selectedWorkType == type;
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
                    if (val) setState(() => _selectedWorkType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Required Duration Selection
            _label('Required Duration'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _durations.map((duration) {
                final isSelected = _selectedDuration == duration;
                return ChoiceChip(
                  label: Text(duration),
                  selected: isSelected,
                  selectedColor: AppColors.secondary,
                  backgroundColor: AppColors.white,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.dark,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.secondary : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedDuration = duration);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Additional Message Field
            _label('Additional Message / Instructions'),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe crop type, acreage, specific equipment available, or start date…',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Please provide some details for the farmer'
                  : null,
            ),
            const SizedBox(height: 28),

            // Submit Button
            PrimaryButton(
              label: 'Send Request',
              icon: Icons.send_rounded,
              busy: _isSubmitting,
              onPressed: _isSubmitting ? null : _submitRequest,
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
