import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/climate_data.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  Future<ClimateData> fetchClimate({
    required double latitude,
    required double longitude,
  }) async {
    final endYear = DateTime.now().year - 1;
    final startYear = endYear - 2;
    final uri = Uri.https(
      'power.larc.nasa.gov',
      '/api/temporal/daily/point',
      {
        'parameters': 'T2M,PRECTOTCORR',
        'community': 'AG',
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'start': '$startYear' '0101',
        'end': '$endYear' '1231',
        'format': 'JSON',
      },
    );

    final response =
        await _client.get(uri).timeout(const Duration(seconds: 35));
    if (response.statusCode != 200) {
      throw Exception('NASA POWER returned status ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'NASA POWER returned an unreadable response.');
    }
    final properties = decoded['properties'];
    final parameters = properties is Map ? properties['parameter'] : null;
    final temperatures = parameters is Map ? parameters['T2M'] : null;
    final rainfall = parameters is Map ? parameters['PRECTOTCORR'] : null;
    if (temperatures is! Map || rainfall is! Map) {
      throw const FormatException(
          'NASA POWER response is missing climate parameters.');
    }

    final yearlyTemperatures = <int, List<double>>{
      for (var year = startYear; year <= endYear; year++) year: <double>[],
    };
    final yearlyRainfall = <int, double>{
      for (var year = startYear; year <= endYear; year++) year: 0,
    };
    final yearlyTemperatureCounts = <int, int>{
      for (var year = startYear; year <= endYear; year++) year: 0,
    };
    final yearlyRainfallCounts = <int, int>{
      for (var year = startYear; year <= endYear; year++) year: 0,
    };

    for (final entry in temperatures.entries) {
      final year = _observationYear(entry.key, startYear, endYear);
      final value = _number(entry.value);
      if (year != null && value != null && value > -900) {
        yearlyTemperatures[year]!.add(value);
        yearlyTemperatureCounts[year] = yearlyTemperatureCounts[year]! + 1;
      }
    }
    for (final entry in rainfall.entries) {
      final year = _observationYear(entry.key, startYear, endYear);
      final value = _number(entry.value);
      if (year != null && value != null && value >= 0) {
        yearlyRainfall[year] = yearlyRainfall[year]! + value;
        yearlyRainfallCounts[year] = yearlyRainfallCounts[year]! + 1;
      }
    }

    var temperatureMeansTotal = 0.0;
    var rainfallTotals = 0.0;
    for (var year = startYear; year <= endYear; year++) {
      final expectedDays = DateTime(year + 1).difference(DateTime(year)).inDays;
      if (yearlyTemperatureCounts[year]! < expectedDays - 15 ||
          yearlyRainfallCounts[year]! < expectedDays - 15) {
        throw FormatException(
          'NASA POWER returned insufficient climate observations for $year.',
        );
      }
      final values = yearlyTemperatures[year]!;
      temperatureMeansTotal += values.reduce((a, b) => a + b) / values.length;
      rainfallTotals += yearlyRainfall[year]!;
    }

    const yearsCount = 3;
    return ClimateData(
      averageTemperatureC: temperatureMeansTotal / yearsCount,
      annualRainfallMm: rainfallTotals / yearsCount,
      startYear: startYear,
      endYear: endYear,
      source: 'NASA POWER',
    );
  }

  int? _observationYear(Object? date, int startYear, int endYear) {
    final dateText = date.toString();
    if (dateText.length != 8) return null;
    final year = int.tryParse(dateText.substring(0, 4));
    if (year == null || year < startYear || year > endYear) return null;
    return year;
  }

  double? _number(Object? value) {
    if (value is num) return value.toDouble();
    return value is String ? double.tryParse(value) : null;
  }
}
