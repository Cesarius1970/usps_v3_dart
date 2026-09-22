import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late CarrierPickupRepository repository;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = CarrierPickupRepository(mockHttpClient);
  });

  group('CarrierPickupRepository checkEligibility', () {
    test('successfully checks eligibility with address object response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/pickup/v3/carrier-pickup/eligibility',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'eligible': true,
            'address': {
              'streetAddress': '4120 Bingham Ave',
              'city': 'Saint Louis',
              'state': 'MO',
              'ZIPCode': '63116',
            },
            'message': 'Address is eligible for pickup',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/eligibility'),
        ),
      );

      final response = await repository.checkEligibility(
        streetAddress: '4120 Bingham Ave',
        secondaryAddress: 'Apt 1',
        city: 'Saint Louis',
        state: 'MO',
        zipCode: '63116',
        zipPlus4: '2520',
        urbanization: 'Urb',
      );

      expect(response.eligible, isTrue);
      expect(response.address?.city, equals('Saint Louis'));
      expect(response.address?.state, equals('MO'));
      expect(response.message, contains('eligible'));
    });

    test('successfully checks eligibility with root address response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/pickup/v3/carrier-pickup/eligibility',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'streetAddress': '4120 Bingham Ave',
            'city': 'Saint Louis',
            'state': 'MO',
            'ZIPCode': '63116',
            'eligible': true,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/eligibility'),
        ),
      );

      final response = await repository.checkEligibility(
        streetAddress: '4120 Bingham Ave',
      );

      expect(response.eligible, isTrue);
      expect(response.address?.zipCode, equals('63116'));
    });

    test('throws UspsUnknownException on non-map response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/pickup/v3/carrier-pickup/eligibility',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'invalid data',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/eligibility'),
        ),
      );

      expect(
        () => repository.checkEligibility(streetAddress: '123 Main St'),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });

  group('CarrierPickupRepository schedulePickup', () {
    const pickupRequest = CarrierPickupRequest(
      pickupDate: '2026-09-25',
      pickupAddress: PickupAddressInfo(
        firstName: 'John',
        lastName: 'Doe',
        firm: 'ACME Corp',
        address: Address(
          streetAddress: '4120 Bingham Ave',
          city: 'Saint Louis',
          state: 'MO',
          zipCode: '63116',
        ),
        contact: [
          PickupContact(email: 'john@example.com', cellNumber: '5551234567'),
        ],
      ),
      packages: [
        PickupPackageItem(packageType: 'PRIORITY_MAIL', packageCount: 2),
      ],
      estimatedWeight: 4.5,
      pickupLocation: PickupLocationInstruction(
        packageLocation: 'FRONT_DOOR',
        specialInstructions: 'Ring doorbell',
      ),
    );

    test('successfully schedules carrier pickup', () async {
      when(
        () => mockHttpClient.post<dynamic>(
          '/pickup/v3/carrier-pickup',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'confirmationNumber': 'WTC123456789',
            'pickupDate': '2026-09-25',
            'status': 'Scheduled',
            'estimatedWeight': 4.5,
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup'),
        ),
      );

      final response = await repository.schedulePickup(pickupRequest);

      expect(response.confirmationNumber, equals('WTC123456789'));
      expect(response.pickupDate, equals('2026-09-25'));
      expect(response.status, equals('Scheduled'));
      expect(response.estimatedWeight, equals(4.5));
    });

    test('throws UspsUnknownException on invalid response format', () async {
      when(
        () => mockHttpClient.post<dynamic>(
          '/pickup/v3/carrier-pickup',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 12345,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup'),
        ),
      );

      expect(
        () => repository.schedulePickup(pickupRequest),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });

  group('CarrierPickupRepository getPickup', () {
    test('successfully retrieves carrier pickup by confirmation number', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/pickup/v3/carrier-pickup/WTC123456789',
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'confirmationNumber': 'WTC123456789',
            'pickupDate': '2026-09-25',
            'status': 'Scheduled',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/WTC123456789'),
        ),
      );

      final response = await repository.getPickup('WTC123456789');

      expect(response.confirmationNumber, equals('WTC123456789'));
      expect(response.status, equals('Scheduled'));
    });

    test('throws UspsUnknownException on unexpected response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/pickup/v3/carrier-pickup/WTC123456789',
        ),
      ).thenAnswer(
        (_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/WTC123456789'),
        ),
      );

      expect(
        () => repository.getPickup('WTC123456789'),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });

  group('CarrierPickupRepository updatePickup', () {
    const updateRequest = CarrierPickupUpdateRequest(
      confirmationNumber: 'WTC123456789',
      pickupDate: '2026-09-26',
      carrierPickupRequest: CarrierPickupRequest(
        pickupDate: '2026-09-26',
        pickupAddress: PickupAddressInfo(
          firstName: 'John',
          lastName: 'Doe',
          firm: 'ACME Corp',
          address: Address(streetAddress: '4120 Bingham Ave'),
        ),
        packages: [
          PickupPackageItem(packageType: 'PRIORITY_MAIL', packageCount: 1),
        ],
        estimatedWeight: 2,
        pickupLocation: PickupLocationInstruction(packageLocation: 'FRONT_DOOR'),
      ),
    );

    test('successfully updates carrier pickup', () async {
      when(
        () => mockHttpClient.put<dynamic>(
          '/pickup/v3/carrier-pickup/WTC123456789',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'confirmationNumber': 'WTC123456789',
            'pickupDate': '2026-09-26',
            'status': 'Updated',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/WTC123456789'),
        ),
      );

      final response = await repository.updatePickup(updateRequest);

      expect(response.confirmationNumber, equals('WTC123456789'));
      expect(response.pickupDate, equals('2026-09-26'));
      expect(response.status, equals('Updated'));
    });

    test('throws UspsUnknownException on unexpected response', () async {
      when(
        () => mockHttpClient.put<dynamic>(
          '/pickup/v3/carrier-pickup/WTC123456789',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'fail',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/WTC123456789'),
        ),
      );

      expect(
        () => repository.updatePickup(updateRequest),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });

  group('CarrierPickupRepository cancelPickup', () {
    test('returns true on 200/204 response', () async {
      when(
        () => mockHttpClient.delete<dynamic>(
          '/pickup/v3/carrier-pickup/WTC123456789',
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/WTC123456789'),
        ),
      );

      final result = await repository.cancelPickup('WTC123456789');
      expect(result, isTrue);
    });

    test('returns false on non-2xx status code', () async {
      when(
        () => mockHttpClient.delete<dynamic>(
          '/pickup/v3/carrier-pickup/WTC123456789',
        ),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/pickup/v3/carrier-pickup/WTC123456789'),
        ),
      );

      final result = await repository.cancelPickup('WTC123456789');
      expect(result, isFalse);
    });
  });
}
