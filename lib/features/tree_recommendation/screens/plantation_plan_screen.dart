import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../models/land_area_unit.dart';
import '../models/land_location.dart';
import '../models/tree_recommendation.dart';
import '../widgets/tree_screen_scaffold.dart';

class PlantationPlanScreen extends StatefulWidget {
  const PlantationPlanScreen({
    super.key,
    required this.recommendation,
    required this.location,
    required this.soilPH,
    required this.irrigationAvailable,
  });

  final TreeRecommendation recommendation;
  final LandLocation location;
  final double? soilPH;
  final bool irrigationAvailable;

  @override
  State<PlantationPlanScreen> createState() => _PlantationPlanScreenState();
}

class _PlantationPlanScreenState extends State<PlantationPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  LandAreaUnit _areaUnit = LandAreaUnit.acres;
  int? _treeCount;
  double? _convertedAreaSquareMeters;

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final area = double.parse(_areaController.text.trim());
    final areaSquareMeters = _areaUnit.toSquareMeters(area);
    final spacing = widget.recommendation.tree.spacingMeters;
    setState(() {
      _convertedAreaSquareMeters = areaSquareMeters;
      _treeCount = (areaSquareMeters / (spacing * spacing)).floor();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tree = widget.recommendation.tree;
    return TreeScreenScaffold(
      title: 'Plantation plan',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          const Text('Plan your tree layout',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark)),
          const SizedBox(height: 8),
          Text('Estimate planting capacity for ${widget.location.name}.',
              style: const TextStyle(color: AppColors.muted, height: 1.4)),
          const SizedBox(height: 20),
          TreeInfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recommended tree',
                    style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 5),
                Text(tree.name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark)),
                Text(tree.scientificName,
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: AppColors.muted)),
                const SizedBox(height: 14),
                Text('Spacing: ${tree.spacingDisplay}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.dark)),
                Text(
                    'Calculation uses ${tree.spacingMeters.toStringAsFixed(2)} m average spacing.',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _areaController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Land Area',
                  hintText: 'Enter land area',
                  prefixIcon: Icon(Icons.square_foot_rounded)),
              validator: (value) {
                final area = double.tryParse(value?.trim() ?? '');
                if (area == null || !area.isFinite || area <= 0) {
                  return 'Enter a land area greater than zero.';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<LandAreaUnit>(
            initialValue: _areaUnit,
            decoration: const InputDecoration(labelText: 'Unit'),
            items: [
              for (final unit in LandAreaUnit.values)
                DropdownMenuItem(value: unit, child: Text(unit.label)),
            ],
            onChanged: (unit) {
              if (unit == null) return;
              setState(() {
                _areaUnit = unit;
                _treeCount = null;
                _convertedAreaSquareMeters = null;
              });
            },
          ),
          const SizedBox(height: 16),
          PrimaryButton(
              label: 'Calculate tree count',
              icon: Icons.calculate_outlined,
              onPressed: _calculate),
          if (_treeCount != null) ...[
            const SizedBox(height: 20),
            TreeInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Estimated tree count',
                      style: TextStyle(fontSize: 13, color: AppColors.muted)),
                  const SizedBox(height: 4),
                  Text('$_treeCount trees',
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                  const SizedBox(height: 10),
                  Text(
                    'Plant ${tree.name} at about ${tree.spacingMeters.toStringAsFixed(2)} m spacing across ${double.parse(_areaController.text.trim()).toStringAsFixed(2)} ${_areaUnit.label} (${_convertedAreaSquareMeters!.toStringAsFixed(0)} m²).',
                    style: const TextStyle(
                        fontSize: 13, height: 1.45, color: AppColors.dark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.recommendation.suitabilityPercent}% climate suitability · Irrigation ${widget.irrigationAvailable ? 'available' : 'not available'}${widget.soilPH == null ? '' : ' · Soil pH ${widget.soilPH!.toStringAsFixed(1)}'}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
