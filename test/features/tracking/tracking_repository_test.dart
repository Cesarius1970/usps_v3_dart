import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';
import 'package:usps_v3_dart/src/core/network/usps_http_client.dart';
import 'package:usps_v3_dart/src/features/tracking/models/tracking_models.dart';
import 'package:usps_v3_dart/src/features/tracking/repository/tracking_repository.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late TrackingRepository repository;
  late Map<String, dynamic> detailJson;
  late Map<String, dynamic> summaryJson;
  late Map<String, dynamic> batchJson;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = TrackingRepository(mockHttpClient);

    detailJson =
        jsonDecode(
              File(
                'test/fixtures/tracking_detail_success.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;

    summaryJson =
        jsonDecode(
              File(
                'test/fixtures/tracking_summary_success.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;

    batchJson =
        jsonDecode(
              File(
                'test/fixtures/tracking_batch_success.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  group('TrackingRepository getTracking', () {
    test(
      'successfully parses detailed tracking response with events',
      () async {
        when(
          () => mockHttpClient.get<dynamic>(
            '/tracking/v3/tracking/9400111899562537624656',
            queryParameters: {'expand': 'DETAIL'},
          ),
        ).thenAnswer(
          (_) async => Response(
            data: detailJson,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/tracking/v3/tracking/9400111899562537624656',
            ),
          ),
        );

        final TrackingResponse result = await repository.getTracking(
          '9400111899562537624656',
          expand: 'DETAIL',
        );

        expect(result.trackingNumber, equals('9400111899562537624656'));
        expect(result.status, equals('Delivered'));
        expect(result.statusCategory, equals('DELIVERED'));
        expect(result.destinationCity, equals('AUSTIN'));
        expect(result.destinationState, equals('TX'));
        expect(result.destinationZIP, equals('78701'));
        expect(result.mailClass, equals('PRIORITY_MAIL'));
        expect(result.trackingEvents.length, equals(3));

        final firstEvent = result.trackingEvents.first;
        expect(firstEvent.eventType, equals('Delivered'));
        expect(firstEvent.eventTimestamp, equals('2026-08-18T13:45:00Z'));
        expect(firstEvent.eventCode, equals('01'));
        expect(firstEvent.name, equals('J DOE'));
      },
    );

    test('successfully parses summary tracking response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/tracking/v3/tracking/9400111899562537624656',
          queryParameters: {'expand': 'SUMMARY'},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: summaryJson,
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/tracking/v3/tracking/9400111899562537624656',
          ),
        ),
      );

      final TrackingResponse result = await repository.getTracking(
        '9400111899562537624656',
        expand: 'SUMMARY',
      );

      expect(result.trackingNumber, equals('9400111899562537624656'));
      expect(result.status, equals('In Transit'));
      expect(result.trackingEvents, isEmpty);
    });

    test(
      'throws UspsUnknownException when response format is invalid',
      () async {
        when(
          () => mockHttpClient.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'invalid string payload',
            statusCode: 200,
            requestOptions: RequestOptions(path: '/tracking/v3/tracking/123'),
          ),
        );

        expect(
          () => repository.getTracking('123'),
          throwsA(isA<UspsUnknownException>()),
        );
      },
    );
  });

  group('TrackingRepository getMultipleTracking', () {
    test('returns empty list immediately when input list is empty', () async {
      final results = await repository.getMultipleTracking([]);
      expect(results, isEmpty);
      verifyZeroInteractions(mockHttpClient);
    });

    test('successfully parses batch tracking results', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/tracking/v3/tracking',
          queryParameters: {
            'trackingNumbers': '9400111899562537624656,9400111899562537629999',
            'expand': 'SUMMARY',
          },
        ),
      ).thenAnswer(
        (_) async => Response(
          data: batchJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/tracking/v3/tracking'),
        ),
      );

      final results = await repository.getMultipleTracking([
        '9400111899562537624656',
        '9400111899562537629999',
      ], expand: 'SUMMARY');

      expect(results.length, equals(2));
      expect(results[0].trackingNumber, equals('9400111899562537624656'));
      expect(results[0].destinationCity, equals('AUSTIN'));
      expect(results[1].trackingNumber, equals('9400111899562537629999'));
      expect(results[1].destinationCity, equals('DALLAS'));
    });

    test('successfully parses raw List in batch tracking', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/tracking/v3/tracking',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: [
            {'trackingNumber': '111', 'status': 'Delivered'},
            {'trackingNumber': '222', 'status': 'In Transit'},
          ],
          statusCode: 200,
          requestOptions: RequestOptions(path: '/tracking/v3/tracking'),
        ),
      );

      final results = await repository.getMultipleTracking(['111', '222']);
      expect(results.length, equals(2));
      expect(results.first.trackingNumber, equals('111'));
    });

    test('successfully parses single Map object in batch tracking', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/tracking/v3/tracking',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'trackingNumber': '999', 'status': 'Accepted'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/tracking/v3/tracking'),
        ),
      );

      final results = await repository.getMultipleTracking(['999']);
      expect(results.length, equals(1));
      expect(results.first.trackingNumber, equals('999'));
    });

    test('throws UspsUnknownException on unexpected batch tracking response', () async {
      when(
        () => mockHttpClient.get<dynamic>(
          '/tracking/v3/tracking',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'invalid string',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/tracking/v3/tracking'),
        ),
      );

      expect(
        () => repository.getMultipleTracking(['999']),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });
}
