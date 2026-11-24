import 'package:baghbani/features/tree_recommendation/models/land_location.dart';
import 'package:baghbani/features/tree_recommendation/services/location_service.dart';
import 'package:baghbani/models/nursery.dart';
import 'package:baghbani/screens/nursery/nearby_nurseries_screen.dart';
import 'package:baghbani/services/nursery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sorts nurseries by distance from the selected location',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: NearbyNurseriesScreen(
          nurseryService: FakeNurseryService([
            _nursery('Far Nursery', 31.4826, 74.3182),
            _nursery('Closest Nursery', 31.5204, 74.3587),
            _nursery('Nearby Nursery', 31.5220, 74.3587),
          ]),
          locationService: FakeLocationService(
            const LandLocation(
              name: '',
              latitude: 31.5204,
              longitude: 74.3587,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final closestY = tester.getTopLeft(find.text('Closest Nursery')).dy;
    final nearbyY = tester.getTopLeft(find.text('Nearby Nursery')).dy;
    final farY = tester.getTopLeft(find.text('Far Nursery')).dy;
    expect(closestY, lessThan(nearbyY));
    expect(nearbyY, lessThan(farY));
    expect(find.text('0 m away'), findsOneWidget);
  });

  testWidgets('offers city search when location permission is denied',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NearbyNurseriesScreen(
          nurseryService: FakeNurseryService([
            _nursery('Lahore Nursery', 31.5204, 74.3587),
          ]),
          locationService: FakeLocationService(
            const LandLocation(name: '', latitude: 0, longitude: 0),
            denied: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Location access is required to find nearby nurseries.'),
      findsOneWidget,
    );
    expect(find.text('Enable Location'), findsOneWidget);
    expect(find.text('Search by City'), findsOneWidget);

    await tester.tap(find.text('Search by City'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Enter a city or address'),
      'Lahore',
    );
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lahore, Pakistan'));
    await tester.pumpAndSettle();

    expect(find.text('Your Location'), findsOneWidget);
    expect(find.text('Lahore, Pakistan'), findsOneWidget);
    expect(find.text('Lahore Nursery'), findsOneWidget);
  });
}

Nursery _nursery(String name, double latitude, double longitude) => Nursery(
      id: name,
      ownerUserId: 'owner-$name',
      nurseryName: name,
      ownerName: 'Owner',
      phone: '03001234567',
      address: 'Garden Road',
      city: 'Lahore',
      latitude: latitude,
      longitude: longitude,
      description: '',
      openingHours: '8 AM - 5 PM',
      image: '',
      createdAt: DateTime(2026),
    );

class FakeNurseryService extends NurseryService {
  FakeNurseryService(this.nurseries);

  final List<Nursery> nurseries;

  @override
  Future<List<Nursery>> getNurseries() async => nurseries;
}

class FakeLocationService extends LocationService {
  FakeLocationService(this.location, {this.denied = false});

  final LandLocation location;
  final bool denied;

  @override
  Future<LandLocation> currentCoordinates() async {
    if (denied) throw const LocationPermissionDeniedException();
    return location;
  }

  @override
  Future<String> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async =>
      'Johar Town, Lahore, Pakistan';

  @override
  Future<List<LandLocation>> search(String query) async => [
        const LandLocation(
          name: 'Lahore, Pakistan',
          latitude: 31.5204,
          longitude: 74.3587,
        ),
      ];
}
