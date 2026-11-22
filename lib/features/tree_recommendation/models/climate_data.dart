class ClimateData {
  const ClimateData({
    required this.averageTemperatureC,
    required this.annualRainfallMm,
    required this.startYear,
    required this.endYear,
    required this.source,
  });

  final double averageTemperatureC;
  final double annualRainfallMm;
  final int startYear;
  final int endYear;
  final String source;
}
