class TreeModel {
  const TreeModel({
    required this.name,
    required this.scientificName,
    required this.tempOptMin,
    required this.tempOptMax,
    required this.tempAbsMin,
    required this.tempAbsMax,
    required this.rainOptMin,
    required this.rainOptMax,
    required this.rainAbsMin,
    required this.rainAbsMax,
    required this.phOptMin,
    required this.phOptMax,
    required this.phAbsMin,
    required this.phAbsMax,
    required this.spacingDisplay,
    required this.spacingMeters,
    required this.source,
  });

  final String name;
  final String scientificName;
  final double tempOptMin;
  final double tempOptMax;
  final double tempAbsMin;
  final double tempAbsMax;
  final double rainOptMin;
  final double rainOptMax;
  final double rainAbsMin;
  final double rainAbsMax;
  final double phOptMin;
  final double phOptMax;
  final double phAbsMin;
  final double phAbsMax;
  final String spacingDisplay;
  final double spacingMeters;
  final String source;

  factory TreeModel.fromCsvRow(Map<String, String> row) {
    double number(String key) {
      final value = double.tryParse(row[key] ?? '');
      if (value == null || !value.isFinite) {
        throw FormatException(
            'Invalid or missing "$key" value in tree dataset.');
      }
      return value;
    }

    final spacing = row['spacing_m'] ?? row['spacing'] ?? '';
    final spacingMeters = _spacingInMeters(spacing);
    if (spacingMeters <= 0) {
      throw const FormatException('Tree spacing must be greater than zero.');
    }
    return TreeModel(
      name: row['tree_name'] ?? '',
      scientificName: row['scientific_name'] ?? '',
      tempOptMin: number('temp_opt_min'),
      tempOptMax: number('temp_opt_max'),
      tempAbsMin: number('temp_abs_min'),
      tempAbsMax: number('temp_abs_max'),
      rainOptMin: number('rain_opt_min'),
      rainOptMax: number('rain_opt_max'),
      rainAbsMin: number('rain_abs_min'),
      rainAbsMax: number('rain_abs_max'),
      phOptMin: number('ph_opt_min'),
      phOptMax: number('ph_opt_max'),
      phAbsMin: number('ph_abs_min'),
      phAbsMax: number('ph_abs_max'),
      spacingDisplay: spacing,
      spacingMeters: spacingMeters,
      source: row['source'] ?? '',
    );
  }

  static double _spacingInMeters(String spacing) {
    final values = RegExp(r'(\d+(?:\.\d+)?)')
        .allMatches(spacing)
        .map((match) => double.parse(match.group(1)!))
        .toList();
    if (values.isEmpty) return 0;
    final average = values.reduce((a, b) => a + b) / values.length;
    return spacing.toLowerCase().contains('feet') ||
            spacing.toLowerCase().contains('ft')
        ? average * 0.3048
        : average;
  }
}
