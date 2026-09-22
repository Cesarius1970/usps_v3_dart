import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late ShippingRepository repository;
  late Map<String, dynamic> labelJson;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = ShippingRepository(mockHttpClient);

    labelJson =
        jsonDecode(
              File(
                'test/fixtures/shipping_label_success.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
  });

  group('ShippingRepository createLabel', () {
    test('successfully generates shipping label and barcode', () async {
      when(
        () => mockHttpClient.post<dynamic>(
          '/labels/v3/label',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: labelJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/labels/v3/label'),
        ),
      );

      const request = LabelRequest(
        fromAddress: Address(
          streetAddress: '475 L\'Enfant Plaza SW',
          city: 'Washington',
          state: 'DC',
          zipCode: '20260',
        ),
        toAddress: Address(
          streetAddress: '100 Congress Ave',
          city: 'Austin',
          state: 'TX',
          zipCode: '78701',
        ),
        weight: 1.25,
        mailClass: UspsMailClass.priorityMail,
        imageType: LabelImageType.pdf,
      );

      final LabelResponse response = await repository.createLabel(request);

      expect(response.trackingNumber, equals('9405511899562537620001'));
      expect(response.totalPrice, equals(9.65));
      expect(response.labelBrokerId, equals('LBRK123456'));
      expect(response.labelUrl, contains('.pdf'));
      expect(response.labelImageBase64, startsWith('JVBERi0xLjQK'));
    });

    test(
      'throws UspsUnknownException on unexpected response data type',
      () async {
        when(
          () => mockHttpClient.post<dynamic>(
            '/labels/v3/label',
            data: any<dynamic>(named: 'data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: 'error string',
            statusCode: 200,
            requestOptions: RequestOptions(path: '/labels/v3/label'),
          ),
        );

        expect(
          () => repository.createLabel(
            const LabelRequest(
              fromAddress: Address(streetAddress: 'A'),
              toAddress: Address(streetAddress: 'B'),
              weight: 1.0,
            ),
          ),
          throwsA(isA<UspsUnknownException>()),
        );
      },
    );
  });

  group('ShippingRepository cancelLabel', () {
    test('returns true on HTTP 200 or 204 success status', () async {
      when(
        () => mockHttpClient.delete<dynamic>(
          '/labels/v3/label/9405511899562537620001',
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {'cancelled': true},
          statusCode: 200,
          requestOptions: RequestOptions(
            path: '/labels/v3/label/9405511899562537620001',
          ),
        ),
      );

      final bool result = await repository.cancelLabel(
        '9405511899562537620001',
      );

      expect(result, isTrue);
    });

    test('returns false when cancel status code is not 2xx', () async {
      when(
        () => mockHttpClient.delete<dynamic>(any()),
      ).thenAnswer(
        (_) async => Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/labels/v3/label/123'),
        ),
      );

      final result = await repository.cancelLabel('123');
      expect(result, isFalse);
    });
  });
}
