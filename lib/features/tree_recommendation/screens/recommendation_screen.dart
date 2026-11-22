import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/climate_data.dart';
import '../models/land_location.dart';
import '../models/tree_recommendation.dart';
import '../repositories/tree_repository.dart';
import '../services/tree_recommendation_service.dart';
import '../services/weather_service.dart';
import '../widgets/tree_screen_scaffold.dart';
import 'tree_detail_screen.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({
    super.key,
    required this.location,
    required this.soilPH,
    required this.irrigationAvailable,
  });

  final LandLocation location;
  final double? soilPH;
  final bool irrigationAvailable;

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _repository = TreeRepository();
  final _recommendationService = TreeRecommendationService();
  final _weatherService = WeatherService();
  bool _loading = true;
  String _loadingMessage = 'Fetching climate data...';
  String? _error;
  ClimateData? _climate;
  List<TreeRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _weatherService.close();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    try {
      final climate = await _weatherService.fetchClimate(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      );
      if (!mounted) return;
      setState(() => _loadingMessage = 'Analyzing soil conditions...');
      final trees = await _repository.getTrees();
      if (!mounted) return;
      setState(() => _loadingMessage = 'Finding suitable trees...');
      final results = _recommendationService.recommend(
        trees: trees,
        climate: climate,
        soilPH: widget.soilPH,
      );
      if (!mounted) return;
      setState(() {
        _climate = climate;
        _recommendations = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'We could not load climate data or the tree dataset. Check your connection and try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => TreeScreenScaffold(
        title: 'Recommended trees',
        child: _loading
            ? _LoadingView(message: _loadingMessage)
            : _error != null
                ? _ErrorView(
                    message: _error!,
                    onRetry: () {
                      setState(() {
                        _loading = true;
                        _loadingMessage = 'Fetching climate data...';
                        _error = null;
                      });
                      _loadRecommendations();
                    })
                : _ResultsView(
                    location: widget.location,
                    climate: _climate!,
                    recommendations: _recommendations,
                    soilPH: widget.soilPH,
                    irrigationAvailable: widget.irrigationAvailable,
                  ),
      );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 22),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark)),
              const SizedBox(height: 8),
              const Text(
                  'Fetching the last 3 complete years of NASA POWER observations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.4)),
            ],
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 52, color: AppColors.muted),
              const SizedBox(height: 14),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.dark, height: 1.45)),
              const SizedBox(height: 18),
              TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try again')),
            ],
          ),
        ),
      );
}

class _ResultsView extends StatelessWidget {
  const _ResultsView({
    required this.location,
    required this.climate,
    required this.recommendations,
    required this.soilPH,
    required this.irrigationAvailable,
  });

  final LandLocation location;
  final ClimateData climate;
  final List<TreeRecommendation> recommendations;
  final double? soilPH;
  final bool irrigationAvailable;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(location.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.farmTint,
                borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NASA POWER climate',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: AppColors.dark)),
                const SizedBox(height: 8),
                Text(
                    'Average Temperature  ${climate.averageTemperatureC.toStringAsFixed(1)} °C'),
                Text(
                    'Average Annual Rainfall  ${climate.annualRainfallMm.toStringAsFixed(0)} mm'),
                const SizedBox(height: 8),
                const Text('Based on last 3 years NASA POWER climate data'),
                Text('Data source: ${climate.source}'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            recommendations.isEmpty
                ? 'No suitable trees found'
                : '${recommendations.length} suitable ${recommendations.length == 1 ? 'tree' : 'trees'}',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark),
          ),
          const SizedBox(height: 6),
          Text(
            recommendations.isEmpty
                ? 'The observed climate and soil pH did not match the dataset’s optimal ranges. Try another location or leave soil pH empty.'
                : 'Based on the observed climate${soilPH == null ? '' : ' and your soil pH'}.',
            style: const TextStyle(
                fontSize: 13, height: 1.4, color: AppColors.muted),
          ),
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final recommendation in recommendations)
              _TreeRecommendationCard(
                recommendation: recommendation,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => TreeDetailScreen(
                      recommendation: recommendation,
                      location: location,
                      climate: climate,
                      soilPH: soilPH,
                      irrigationAvailable: irrigationAvailable,
                    ),
                  ),
                ),
              ),
          ],
        ],
      );
}

class _TreeRecommendationCard extends StatelessWidget {
  const _TreeRecommendationCard(
      {required this.recommendation, required this.onTap});
  final TreeRecommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tree = recommendation.tree;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderLight)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                    color: AppColors.farmTint,
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.park_rounded,
                    color: AppColors.farmAccent, size: 42),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tree.name,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                    const SizedBox(height: 2),
                    Text(tree.scientificName,
                        style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.muted)),
                    const SizedBox(height: 7),
                    Text('${recommendation.suitabilityPercent}% Suitable',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 2),
                    const SizedBox(height: 4),
                    const Text('Suitable because:',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark)),
                    for (final reason in recommendation.reasons)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.check_rounded,
                                size: 13, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(reason,
                                  style: const TextStyle(
                                      fontSize: 11.5, color: AppColors.muted)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
