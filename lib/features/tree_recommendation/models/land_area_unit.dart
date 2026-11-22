enum LandAreaUnit {
  acres('Acres', 4046.8564224),
  kanal('Kanal', 505.857),
  hectares('Hectare', 10000);

  const LandAreaUnit(this.label, this.squareMetersPerUnit);

  final String label;
  final double squareMetersPerUnit;

  double toSquareMeters(double area) => area * squareMetersPerUnit;
}
