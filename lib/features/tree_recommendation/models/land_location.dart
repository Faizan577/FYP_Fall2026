class LandLocation {
  const LandLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.label = 'Selected location',
  });

  final String name;
  final double latitude;
  final double longitude;
  final String label;
}
