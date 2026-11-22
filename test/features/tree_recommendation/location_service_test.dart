import 'dart:convert';

import 'package:baghbani/features/tree_recommendation/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('manual search shows a formatted address and retains coordinates',
      () async {
    final service = LocationService(
      client: MockClient((request) async {
        expect(request.url.path, '/search');
        expect(request.url.queryParameters['q'], 'Lahore');
        expect(request.url.queryParameters['addressdetails'], '1');
        return http.Response(
          jsonEncode([
            {
              'lat': '31.5204',
              'lon': '74.3587',
              'display_name': 'Lahore, Punjab, Pakistan',
              'address': {
                'city': 'Lahore',
                'state': 'Punjab',
                'country': 'Pakistan',
              },
            },
          ]),
          200,
        );
      }),
    );

    final locations = await service.search('Lahore');
    service.close();

    expect(locations.single.name, 'Lahore, Punjab, Pakistan');
    expect(locations.single.latitude, 31.5204);
    expect(locations.single.longitude, 74.3587);
  });

  test('reverse geocoding returns a concise human-readable address', () async {
    final service = LocationService(
      client: MockClient((request) async {
        expect(request.url.path, '/reverse');
        expect(request.url.queryParameters['lat'], '31.5204');
        expect(request.url.queryParameters['lon'], '74.3587');
        return http.Response(
          jsonEncode({
            'display_name': 'Johar Town, Lahore, Punjab, Pakistan',
            'address': {
              'neighbourhood': 'Johar Town',
              'suburb': 'Lahore',
              'city': 'Lahore',
              'state': 'Punjab',
              'country': 'Pakistan',
            },
          }),
          200,
        );
      }),
    );

    final address = await service.reverseGeocode(
      latitude: 31.5204,
      longitude: 74.3587,
    );
    service.close();

    expect(address, 'Johar Town, Lahore, Punjab, Pakistan');
  });

  test('reverse geocoding reports an unavailable address', () async {
    final service = LocationService(
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    addTearDown(service.close);

    await expectLater(
      service.reverseGeocode(latitude: 31.5204, longitude: 74.3587),
      throwsA(isA<LocationAddressNotFoundException>()),
    );
  });
}
