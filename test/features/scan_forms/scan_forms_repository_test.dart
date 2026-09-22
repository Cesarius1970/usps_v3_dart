import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

class MockUspsHttpClient extends Mock implements UspsHttpClient {}

void main() {
  late MockUspsHttpClient mockHttpClient;
  late ScanFormsRepository repository;

  setUp(() {
    mockHttpClient = MockUspsHttpClient();
    repository = ScanFormsRepository(mockHttpClient);
  });

  group('ScanFormsRepository createScanForm', () {
    const scanFormRequest = ScanFormRequest(
      mailingDate: '2026-09-25',
      entryFacilityZIPCode: '45011',
      entryFacilityZIPPlus4: '1175',
      shipment: ScanFormShipment(
        trackingNumbers: ['9400111899562537680001', '9400111899562537680002'],
        mid: '123456789',
        manifestMID: '987654321',
      ),
      fromAddress: ScanFormFromAddress(
        firstName: 'John',
        lastName: 'Doe',
        firm: 'ACME Corp',
        address: Address(
          streetAddress: '4261 Port Union Rd',
          city: 'West Chester',
          state: 'OH',
          zipCode: '45011',
        ),
      ),
    );

    test('successfully generates PS Form 5630 SCAN Form', () async {
      when(
        () => mockHttpClient.post<dynamic>(
          '/scan-forms/v3/scan-form',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: {
            'form': '5630',
            'imageType': 'PDF',
            'labelType': '8.5x11LABEL',
            'mailingDate': '2026-09-25',
            'manifestNumber': 'MAN1234567890123456',
            'trackingNumbers': [
              '9400111899562537680001',
              '9400111899562537680002',
            ],
            'labelImage': 'JVBERi0xLjQK...',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/scan-forms/v3/scan-form'),
        ),
      );

      final response = await repository.createScanForm(scanFormRequest);

      expect(response.form, equals('5630'));
      expect(response.imageType, equals('PDF'));
      expect(response.manifestNumber, equals('MAN1234567890123456'));
      expect(response.trackingNumbers, hasLength(2));
      expect(response.labelImage, startsWith('JVBERi0xLjQK'));
    });

    test('throws ArgumentError on invalid entryFacilityZIPCode', () {
      const invalidRequest = ScanFormRequest(
        mailingDate: '2026-09-25',
        entryFacilityZIPCode: 'INVALID',
        shipment: ScanFormShipment(trackingNumbers: ['9400111899562537680001']),
        fromAddress: ScanFormFromAddress(firm: 'ACME'),
      );

      expect(
        () => repository.createScanForm(invalidRequest),
        throwsArgumentError,
      );
    });

    test('throws UspsUnknownException on unexpected response data', () async {
      when(
        () => mockHttpClient.post<dynamic>(
          '/scan-forms/v3/scan-form',
          data: any<dynamic>(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: 'invalid string',
          statusCode: 200,
          requestOptions: RequestOptions(path: '/scan-forms/v3/scan-form'),
        ),
      );

      expect(
        () => repository.createScanForm(scanFormRequest),
        throwsA(isA<UspsUnknownException>()),
      );
    });
  });
}
