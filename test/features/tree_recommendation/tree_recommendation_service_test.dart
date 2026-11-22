import 'dart:convert';

import 'package:baghbani/features/tree_recommendation/models/climate_data.dart';
import 'package:baghbani/features/tree_recommendation/models/land_area_unit.dart';
import 'package:baghbani/features/tree_recommendation/models/tree_model.dart';
import 'package:baghbani/features/tree_recommendation/repositories/tree_repository.dart';
import 'package:baghbani/features/tree_recommendation/services/tree_recommendation_service.dart';
import 'package:baghbani/features/tree_recommendation/services/weather_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tree = TreeModel(
    name: 'Test tree',
    scientificName: 'Arbor testus',
    tempOptMin: 20,
    tempOptMax: 30,
    tempAbsMin: 10,
    tempAbsMax: 40,
    rainOptMin: 500,
    rainOptMax: 1500,
    rainAbsMin: 100,
    rainAbsMax: 2000,
    phOptMin: 5.5,
    phOptMax: 7.5,
    phAbsMin: 4,
    phAbsMax: 8,
    spacingDisplay: '10-12 feet',
    spacingMeters: 3.35,
    source: 'Test dataset',
  );
  final service = TreeRecommendationService();
  const climate = ClimateData(
    averageTemperatureC: 25,
    annualRainfallMm: 1000,
    startYear: 2023,
    endYear: 2025,
    source: 'NASA POWER',
  );

  test('matches optimal climate and ignores pH when it is omitted', () {
    final matches = service.recommend(trees: const [tree], climate: climate);

    expect(matches, hasLength(1));
    expect(matches.single.suitabilityPercent, 100);
    expect(matches.single.reasons, ['Temperature matches', 'Rainfall matches']);
  });

  test('includes soil pH in the weighted suitability criteria when provided',
      () {
    final matches = service.recommend(
      trees: const [tree],
      climate: climate,
      soilPH: 6.5,
    );

    expect(matches.single.suitabilityPercent, 100);
    expect(
      matches.single.reasons,
      ['Temperature matches', 'Rainfall matches', 'Soil pH matches'],
    );
  });

  test('filters trees when supplied pH is outside the optimal range', () {
    final matches = service.recommend(
      trees: const [tree],
      climate: climate,
      soilPH: 8,
    );

    expect(matches, isEmpty);
  });

  test('converts source dataset spacing ranges from feet to meters', () {
    final parsed = TreeModel.fromCsvRow({
      'tree_name': 'Aam',
      'scientific_name': 'Mangifera indica',
      'temp_opt_min': '24',
      'temp_opt_max': '30',
      'temp_abs_min': '8',
      'temp_abs_max': '48',
      'rain_opt_min': '600',
      'rain_opt_max': '1500',
      'rain_abs_min': '300',
      'rain_abs_max': '2600',
      'ph_opt_min': '5.5',
      'ph_opt_max': '7.5',
      'ph_abs_min': '4.3',
      'ph_abs_max': '8.5',
      'spacing': '10-12 feet',
      'source': 'EcoCrop',
    });

    expect(parsed.spacingDisplay, '10-12 feet');
    expect(parsed.spacingMeters, closeTo(3.3528, 0.0001));
  });

  test('loads the provided suitability dataset', () async {
    final trees = await TreeRepository().getTrees();

    expect(trees, hasLength(9));
    expect(trees.first.name, 'Aam');
    expect(trees.first.source, 'EcoCrop');
  });

  test('requests and averages three complete years of NASA climate data',
      () async {
    final startYear = DateTime.now().year - 3;
    final temperatures = <String, double>{};
    final rainfall = <String, double>{};
    final yearlyDayCounts = <int>[];
    for (var offset = 0; offset < 3; offset++) {
      final year = startYear + offset;
      var date = DateTime(year);
      var days = 0;
      while (date.year == year) {
        final dateKey =
            '$year${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
        temperatures[dateKey] = 10 + offset * 10;
        rainfall[dateKey] = (offset + 1).toDouble();
        date = date.add(const Duration(days: 1));
        days++;
      }
      yearlyDayCounts.add(days);
    }

    final service = WeatherService(
      client: MockClient((request) async {
        expect(request.url.host, 'power.larc.nasa.gov');
        expect(request.url.queryParameters['parameters'], 'T2M,PRECTOTCORR');
        expect(request.url.queryParameters['start'], '${startYear}0101');
        expect(request.url.queryParameters['end'], '${startYear + 2}1231');
        return http.Response(
          jsonEncode({
            'properties': {
              'parameter': {
                'T2M': temperatures,
                'PRECTOTCORR': rainfall,
              },
            },
          }),
          200,
        );
      }),
    );

    final climate = await service.fetchClimate(latitude: 31.5, longitude: 74.3);
    service.close();

    expect(climate.averageTemperatureC, 20);
    expect(
      climate.annualRainfallMm,
      closeTo(
        (yearlyDayCounts[0] + yearlyDayCounts[1] * 2 + yearlyDayCounts[2] * 3) /
            3,
        0.0001,
      ),
    );
    expect(climate.startYear, startYear);
    expect(climate.endYear, startYear + 2);
    expect(climate.source, 'NASA POWER');
  });

  test('converts acres, kanal, and hectares to square meters', () {
    expect(LandAreaUnit.acres.toSquareMeters(1), closeTo(4046.8564, 0.001));
    expect(LandAreaUnit.kanal.toSquareMeters(1), closeTo(505.857, 0.001));
    expect(LandAreaUnit.hectares.toSquareMeters(1), 10000);
  });
}
