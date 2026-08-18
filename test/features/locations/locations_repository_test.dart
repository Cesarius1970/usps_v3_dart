import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';
import 'package:usps_v3_dart/src/core/network/usps_http_client.dart';
import 'package:usps_v3_dart/src/features/locations/models/location_models.dart';
import 'package:usps_v3_dart/src/features/locations/repository/locations_repository.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late LocationsRepository repository;
  late Map<String, dynamic> locationsJson;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = LocationsRepository(mockHttpClient);

    locationsJson =
        jsonDecode(
              File('test/fixtures/locations_success.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  group('LocationsRepository findLocations', () {
    test('successfully finds locations by zip code', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/locations/v3/locations',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: locationsJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/locations/v3/locations'),
        ),
      );

      final LocationsResponse response = await repository.findLocations(
        zipCode: '20260',
        maxResults: 5,
      );

      expect(response.totalLocations, equals(1));
      expect(response.locations.length, equals(1));

      final loc = response.locations.first;
      expect(loc.locationName, equals("L'ENFANT PLAZA POST OFFICE"));
      expect(loc.locationType, equals('POST OFFICE'));
      expect(loc.city, equals('WASHINGTON'));
      expect(loc.state, equals('DC'));
      expect(loc.latitude, equals(38.884));
      expect(loc.longitude, equals(-77.018));
      expect(loc.services, contains('Passport Services'));
    });

    test('successfully finds locations by coordinates', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/locations/v3/locations',
          queryParameters: {
            'maxResults': 3,
            'latitude': 38.884,
            'longitude': -77.018,
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          data: locationsJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/locations/v3/locations'),
        ),
      );

      final LocationsResponse response = await repository.findLocations(
        latitude: 38.884,
        longitude: -77.018,
        maxResults: 3,
      );

      expect(response.locations.isNotEmpty, isTrue);
    });

    test(
      'throws UspsUnknownException on unexpected response data type',
      () async {
        when(
          () => mockHttpClient.get<dynamic>(
            '/locations/v3/locations',
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 12345,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/locations/v3/locations'),
          ),
        );

        expect(
          () => repository.findLocations(zipCode: '20260'),
          throwsA(isA<UspsUnknownException>()),
        );
      },
    );
  });
}
