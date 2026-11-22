import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../models/climate_data.dart';
import '../models/land_location.dart';
import '../models/tree_recommendation.dart';
import '../widgets/tree_screen_scaffold.dart';
import 'plantation_plan_screen.dart';

class TreeDetailScreen extends StatelessWidget {
  const TreeDetailScreen({
    super.key,
    required this.recommendation,
    required this.location,
    required this.climate,
    required this.soilPH,
    required this.irrigationAvailable,
  });

  final TreeRecommendation recommendation;
  final LandLocation location;
  final ClimateData climate;
  final double? soilPH;
  final bool irrigationAvailable;

  @override
  Widget build(BuildContext context) {
    final tree = recommendation.tree;
    return TreeScreenScaffold(
      title: 'Tree details',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
                color: AppColors.farmTint,
                borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.park_rounded,
                color: AppColors.farmAccent, size: 86),
          ),
          const SizedBox(height: 18),
          Text(tree.name,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark)),
          const SizedBox(height: 4),
          Text(tree.scientificName,
              style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted)),
          const SizedBox(height: 8),
          Text('${recommendation.suitabilityPercent}% Suitable',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 20),
          TreeInfoCard(
            child: Column(
              children: [
                _DetailRow(
                    label: 'Optimal temperature',
                    value:
                        '${tree.tempOptMin.toStringAsFixed(0)}–${tree.tempOptMax.toStringAsFixed(0)} °C'),
                _DetailRow(
                    label: 'Absolute temperature',
                    value:
                        '${tree.tempAbsMin.toStringAsFixed(0)}–${tree.tempAbsMax.toStringAsFixed(0)} °C'),
                _DetailRow(
                    label: 'Optimal annual rainfall',
                    value:
                        '${tree.rainOptMin.toStringAsFixed(0)}–${tree.rainOptMax.toStringAsFixed(0)} mm'),
                _DetailRow(
                    label: 'Absolute annual rainfall',
                    value:
                        '${tree.rainAbsMin.toStringAsFixed(0)}–${tree.rainAbsMax.toStringAsFixed(0)} mm'),
                _DetailRow(
                    label: 'Optimal soil pH',
                    value:
                        '${tree.phOptMin.toStringAsFixed(1)}–${tree.phOptMax.toStringAsFixed(1)}'),
                _DetailRow(
                    label: 'Absolute soil pH',
                    value:
                        '${tree.phAbsMin.toStringAsFixed(1)}–${tree.phAbsMax.toStringAsFixed(1)}'),
                _DetailRow(
                    label: 'Spacing',
                    value:
                        '${tree.spacingDisplay} (${tree.spacingMeters.toStringAsFixed(2)} m average)'),
                _DetailRow(label: 'Source', value: tree.source, last: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
              'Climate at ${location.name}: ${climate.averageTemperatureC.toStringAsFixed(1)} °C average, ${climate.annualRainfallMm.toStringAsFixed(0)} mm rainfall in ${climate.startYear}.',
              style: const TextStyle(
                  fontSize: 13, height: 1.45, color: AppColors.muted)),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Create plantation plan',
            icon: Icons.grid_on_rounded,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => PlantationPlanScreen(
                  recommendation: recommendation,
                  location: location,
                  soilPH: soilPH,
                  irrigationAvailable: irrigationAvailable,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label, required this.value, this.last = false});
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Text(label,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted))),
            const SizedBox(width: 12),
            Flexible(
                child: Text(value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark))),
          ],
        ),
      );
}
