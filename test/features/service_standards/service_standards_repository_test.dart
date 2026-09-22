import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late ServiceStandardsRepository repository;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = ServiceStandardsRepository(mockHttpClient);
  });

  group('ServiceStandardsRepository getEstimates', () {
    test('successfully retrieves estimates with UspsMailClass and parameters', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/estimates',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'originZIPCode': '10018',
            'destinationZIPCode': '95823',
            'acceptanceDate': '2026-09-25',
            'mailClass': 'PRIORITY_MAIL',
            'serviceStandard': {
              'daysToDelivery': 2,
              'estimatedDeliveryDate': '2026-09-27',
              'deliveryDays': '2-Day',
              'serviceType': 'Commercial',
              'message': 'Standard transit',
            },
            'messages': ['On-time delivery standard applies'],
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/estimates'),
        ),
      );

      final response = await repository.getEstimates(
        originZipCode: '10018',
        destinationZipCode: '95823',
        acceptanceDate: '2026-09-25',
        mailClass: UspsMailClass.priorityMail,
        destinationType: 'HOLD_FOR_PICKUP',
        serviceTypeCodes: '925',
      );

      expect(response.originZIPCode, equals('10018'));
      expect(response.destinationZIPCode, equals('95823'));
      expect(response.mailClass, equals('PRIORITY_MAIL'));
      expect(response.serviceStandard?.daysToDelivery, equals(2));
      expect(response.serviceStandard?.deliveryDays, equals('2-Day'));
      expect(response.messages, hasLength(1));
    });

    test('supports mailClassString parameter fallback', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/estimates',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'originZIPCode': '10018',
            'destinationZIPCode': '95823',
            'mailClass': 'CUSTOM_CLASS',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/estimates'),
        ),
      );

      final response = await repository.getEstimates(
        originZipCode: '10018',
        destinationZipCode: '95823',
        acceptanceDate: '2026-09-25',
        mailClassString: 'CUSTOM_CLASS',
      );

      expect(response.mailClass, equals('CUSTOM_CLASS'));
    });

    test('throws ArgumentError on invalid origin or destination ZIP', () {
      expect(
        () => repository.getEstimates(
          originZipCode: 'INVALID',
          destinationZipCode: '95823',
          acceptanceDate: '2026-09-25',
        ),
        throwsArgumentError,
      );

      expect(
        () => repository.getEstimates(
          originZipCode: '10018',
          destinationZipCode: 'BAD',
          acceptanceDate: '2026-09-25',
        ),
        throwsArgumentError,
      );
    });

    test('throws UspsUnknownException on unexpected response data type', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/estimates',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'invalid data string',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/estimates'),
        ),
      );

      expect(
        () => repository.getEstimates(
          originZipCode: '10018',
          destinationZipCode: '95823',
          acceptanceDate: '2026-09-25',
        ),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });

  group('ServiceStandardsRepository getStandards', () {
    test('successfully retrieves standards when response is List', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/standards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: [
            {
              'originZIPCode': '10018',
              'destinationZIPCode': '95823',
              'mailClass': 'PRIORITY_MAIL',
            },
            {
              'originZIPCode': '10018',
              'destinationZIPCode': '95823',
              'mailClass': 'USPS_GROUND_ADVANTAGE',
            },
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/standards'),
        ),
      );

      final results = await repository.getStandards(
        originZipCode: '10018',
        destinationZipCode: '95823',
        mailClass: UspsMailClass.priorityMail,
      );

      expect(results, hasLength(2));
      expect(results.first.mailClass, equals('PRIORITY_MAIL'));
    });

    test('successfully retrieves standards when response contains standards key in Map', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/standards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'standards': [
              {
                'originZIPCode': '10018',
                'destinationZIPCode': '95823',
                'mailClass': 'PRIORITY_MAIL',
              }
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/standards'),
        ),
      );

      final results = await repository.getStandards(
        originZipCode: '10018',
        destinationZipCode: '95823',
        mailClassString: 'PRIORITY_MAIL',
        destinationType: 'HOLD_FOR_PICKUP',
        serviceTypeCodes: '925',
      );

      expect(results, hasLength(1));
    });

    test('successfully handles single Map standard response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/standards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'originZIPCode': '10018',
            'destinationZIPCode': '95823',
            'mailClass': 'PRIORITY_MAIL',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/standards'),
        ),
      );

      final results = await repository.getStandards(
        originZipCode: '10018',
        destinationZipCode: '95823',
      );

      expect(results, hasLength(1));
    });

    test('throws UspsUnknownException on unexpected response data type', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/service-standards/v3/standards',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 12345,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/service-standards/v3/standards'),
        ),
      );

      expect(
        () => repository.getStandards(
          originZipCode: '10018',
          destinationZipCode: '95823',
        ),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });
}
