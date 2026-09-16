import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';
import 'package:usps_v3_dart/src/core/network/usps_http_client.dart';
import 'package:usps_v3_dart/src/features/addresses/models/address_models.dart';
import 'package:usps_v3_dart/src/features/addresses/repository/addresses_repository.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late AddressesRepository repository;
  late Map<String, dynamic> standardizeJson;
  late Map<String, dynamic> cityStateJson;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = AddressesRepository(mockHttpClient);

    standardizeJson =
        jsonDecode(
              File(
                'test/fixtures/address_standardize_success.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;

    cityStateJson =
        jsonDecode(
              File('test/fixtures/city_state_success.json').readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  group('AddressesRepository standardizeAddress', () {
    test('successfully standardizes address and parses ZIP+4 with full fields', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/address',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: standardizeJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/address'),
        ),
      );

      const input = Address(
        streetAddress: '475 L\'Enfant Plaza SW',
        secondaryAddress: 'Suite 100',
        city: 'Washington',
        state: 'DC',
        zipCode: '20260',
        zipPlus4: '0001',
        firmName: 'USPS HQ',
        urbanization: 'URB',
      );

      final result = await repository.standardizeAddress(input);

      expect(result.address?.streetAddress, equals("475 L'ENFANT PLAZA SW"));
      expect(result.address?.secondaryAddress, equals('STE 100'));
      expect(result.address?.city, equals('WASHINGTON'));
      expect(result.address?.state, equals('DC'));
      expect(result.address?.zipCode, equals('20260'));
      expect(result.address?.zipPlus4, equals('0001'));
      expect(result.warnings, contains('Default address line 2 normalized'));
    });

    test('handles flat address response without wrapping address key', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/address',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'streetAddress': '123 MAIN ST',
            'city': 'AUSTIN',
            'state': 'TX',
            'ZIPCode': '78701',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/address'),
        ),
      );

      final result = await repository.standardizeAddress(const Address(streetAddress: '123 Main St'));
      expect(result.address?.streetAddress, equals('123 MAIN ST'));
      expect(result.address?.city, equals('AUSTIN'));
    });

    test('throws UspsUnknownException on invalid payload format', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/address',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'invalid format',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/address'),
        ),
      );

      expect(
        () => repository.standardizeAddress(
          const Address(streetAddress: '123 Main St'),
        ),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });

  group('AddressesRepository lookupCityState', () {
    test('successfully retrieves city and state for a zip code', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/city-state',
          queryParameters: {'ZIPCode': '20260'},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: cityStateJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/city-state'),
        ),
      );

      final result = await repository.lookupCityState('20260');

      expect(result.zipCode, equals('20260'));
      expect(result.city, equals('WASHINGTON'));
      expect(result.state, equals('DC'));
    });

    test('throws UspsUnknownException when payload is not a Map', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/city-state',
          queryParameters: {'ZIPCode': '20260'},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: ['unexpected_list'],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/city-state'),
        ),
      );

      expect(() => repository.lookupCityState('20260'), throwsA(isA<UspsUnknownException>()));
    });
  });

  group('AddressesRepository lookupZipCode', () {
    test('successfully looks up full zip code with all address parameters', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/zipcode',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: standardizeJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/zipcode'),
        ),
      );

      final result = await repository.lookupZipCode(
        const Address(
          streetAddress: '475 L\'Enfant Plaza SW',
          secondaryAddress: 'STE 100',
          city: 'Washington',
          state: 'DC',
          firmName: 'HQ',
        ),
      );

      expect(result.address?.zipCode, equals('20260'));
      expect(result.address?.zipPlus4, equals('0001'));
    });

    test('handles flat address response in lookupZipCode', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/zipcode',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'streetAddress': '475 L\'ENFANT PLZ SW',
            'city': 'WASHINGTON',
            'state': 'DC',
            'ZIPCode': '20260',
            'ZIPPlus4': '0001',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/zipcode'),
        ),
      );

      final result = await repository.lookupZipCode(
        const Address(streetAddress: '475 L\'Enfant Plaza SW', city: 'Washington', state: 'DC'),
      );

      expect(result.address?.zipCode, equals('20260'));
    });

    test('throws UspsUnknownException on invalid zipcode lookup response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/addresses/v3/zipcode',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 12345,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/addresses/v3/zipcode'),
        ),
      );

      expect(
        () => repository.lookupZipCode(const Address(streetAddress: '123 Main')),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });
}
