import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/src/core/exceptions/usps_exceptions.dart';
import 'package:usps_v3_dart/src/core/network/usps_http_client.dart';
import 'package:usps_v3_dart/src/features/pricing/models/pricing_models.dart';
import 'package:usps_v3_dart/src/features/pricing/repository/pricing_repository.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late PricingRepository repository;
  late Map<String, dynamic> ratesJson;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = PricingRepository(mockHttpClient);

    ratesJson =
        jsonDecode(
              File(
                'test/fixtures/pricing_rates_success.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  group('PricingRepository calculateRates', () {
    test('successfully calculates base rates with multiple options', () async {
      when(
        () => mockHttpClient.post<dynamic>(
          '/prices/v3/base-rates/search',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: ratesJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/prices/v3/base-rates/search'),
        ),
      );

      const request = RateRequest(
        originZipCode: '20260',
        destinationZipCode: '78701',
        weight: 2.5,
        length: 10.0,
        width: 6.0,
        height: 4.0,
        mailClass: 'PRIORITY_MAIL',
      );

      final RateResponse response = await repository.calculateRates(request);

      expect(response.totalBasePrice, equals(9.65));
      expect(response.rates.length, equals(2));

      final firstRate = response.rates.first;
      expect(firstRate.mailClass, equals('PRIORITY_MAIL'));
      expect(firstRate.price, equals(9.65));
      expect(firstRate.zone, equals('04'));
      expect(firstRate.description, equals('Priority Mail 2-Day'));
      expect(firstRate.fees?.first.feeName, equals('Base Rate'));
      expect(firstRate.fees?.first.feePrice, equals(9.65));
    });

    test(
      'throws UspsUnknownException on unexpected response data type',
      () async {
        when(
          () => mockHttpClient.post<dynamic>(
            '/prices/v3/base-rates/search',
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'malformed string',
            statusCode: 200,
            requestOptions: RequestOptions(
              path: '/prices/v3/base-rates/search',
            ),
          ),
        );

        expect(
          () => repository.calculateRates(
            const RateRequest(
              originZipCode: '20260',
              destinationZipCode: '78701',
              weight: 1.0,
            ),
          ),
          throwsA(isA<UspsUnknownException>()),
        );
      },
    );
  });
}
