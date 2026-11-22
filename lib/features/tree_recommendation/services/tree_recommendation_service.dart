import '../models/climate_data.dart';
import '../models/tree_model.dart';
import '../models/tree_recommendation.dart';

class TreeRecommendationService {
  List<TreeRecommendation> recommend({
    required List<TreeModel> trees,
    required ClimateData climate,
    double? soilPH,
  }) {
    final recommendations = <TreeRecommendation>[];
    for (final tree in trees) {
      final temperatureMatches =
          climate.averageTemperatureC >= tree.tempOptMin &&
              climate.averageTemperatureC <= tree.tempOptMax;
      final rainfallMatches = climate.annualRainfallMm >= tree.rainOptMin &&
          climate.annualRainfallMm <= tree.rainOptMax;
      final phMatches = soilPH == null ||
          (soilPH >= tree.phOptMin && soilPH <= tree.phOptMax);
      if (!temperatureMatches || !rainfallMatches || !phMatches) continue;

      const temperatureWeight = 40;
      const rainfallWeight = 40;
      const soilPHWeight = 20;
      final availablePoints = temperatureWeight +
          rainfallWeight +
          (soilPH == null ? 0 : soilPHWeight);
      final points = (temperatureMatches ? temperatureWeight : 0) +
          (rainfallMatches ? rainfallWeight : 0) +
          (soilPH != null && phMatches ? soilPHWeight : 0);
      recommendations.add(
        TreeRecommendation(
          tree: tree,
          suitabilityPercent: (points / availablePoints * 100).round(),
          reasons: [
            if (temperatureMatches) 'Temperature matches',
            if (rainfallMatches) 'Rainfall matches',
            if (soilPH != null && phMatches) 'Soil pH matches',
          ],
        ),
      );
    }
    recommendations.sort(
      (a, b) => b.suitabilityPercent.compareTo(a.suitabilityPercent),
    );
    return recommendations;
  }
}
