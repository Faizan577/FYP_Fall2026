import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../models/land_location.dart';
import '../widgets/tree_screen_scaffold.dart';
import 'recommendation_screen.dart';

class SoilInputScreen extends StatefulWidget {
  const SoilInputScreen({super.key, required this.location});
  final LandLocation location;

  @override
  State<SoilInputScreen> createState() => _SoilInputScreenState();
}

class _SoilInputScreenState extends State<SoilInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phController = TextEditingController();
  bool _irrigationAvailable = true;

  @override
  void dispose() {
    _phController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final soilPH = _phController.text.trim().isEmpty
        ? null
        : double.parse(_phController.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RecommendationScreen(
          location: widget.location,
          soilPH: soilPH,
          irrigationAvailable: _irrigationAvailable,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => TreeScreenScaffold(
        title: 'Soil and irrigation',
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(widget.location.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
              const SizedBox(height: 20),
              const Text('Add soil information',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark)),
              const SizedBox(height: 8),
              const Text(
                  'Soil pH helps refine your recommendations. You can leave it blank if you do not know it.',
                  style: TextStyle(color: AppColors.muted, height: 1.45)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Soil pH (optional)',
                  hintText: 'For example, 6.5',
                  prefixIcon: Icon(Icons.science_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed < 0 || parsed > 14) {
                    return 'Enter a valid pH between 0 and 14.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Is irrigation available?',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.dark)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _IrrigationChoice(
                          label: 'Yes',
                          selected: _irrigationAvailable,
                          onTap: () =>
                              setState(() => _irrigationAvailable = true))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _IrrigationChoice(
                          label: 'No',
                          selected: !_irrigationAvailable,
                          onTap: () =>
                              setState(() => _irrigationAvailable = false))),
                ],
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                  label: 'Generate recommendations',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _continue),
            ],
          ),
        ),
      );
}

class _IrrigationChoice extends StatelessWidget {
  const _IrrigationChoice(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.soft : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: AppColors.primary,
                  size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.dark, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}
