import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('UspsClient Facade initialization', () {
    test('instantiates with production environment defaults', () {
      final client = UspsClient(
        clientId: 'mock_client_id',
        clientSecret: 'mock_client_secret',
      );

      expect(client.auth.clientId, equals('mock_client_id'));
      expect(client.auth.clientSecret, equals('mock_client_secret'));
      expect(client.tracking, isA<TrackingRepository>());
      expect(client.addresses, isA<AddressesRepository>());
      expect(client.locations, isA<LocationsRepository>());
      expect(client.pricing, isA<PricingRepository>());
      expect(client.shipping, isA<ShippingRepository>());
      expect(client.pickup, isA<CarrierPickupRepository>());
      expect(client.serviceStandards, isA<ServiceStandardsRepository>());
      expect(client.scanForms, isA<ScanFormsRepository>());
    });

    test('instantiates with sandbox environment and custom timeouts', () {
      final client = UspsClient(
        clientId: 'mock_client_id',
        clientSecret: 'mock_client_secret',
        environment: UspsEnvironment.sandbox,
        connectTimeout: const Duration(seconds: 15),
      );

      expect(
        client.auth.tokenEndpoint,
        equals(UspsEnvironment.sandbox.tokenEndpoint),
      );
      expect(
        client.httpClient.dio.options.baseUrl,
        equals(UspsEnvironment.sandbox.baseUrl),
      );
      expect(
        client.httpClient.dio.options.connectTimeout,
        equals(const Duration(seconds: 15)),
      );
    });

    test('instantiates with enableLogging and enableRetry interceptors', () {
      final client = UspsClient(
        clientId: 'mock_client_id',
        clientSecret: 'mock_client_secret',
        enableLogging: true,
        enableRetry: true,
        maxRetries: 4,
      );

      final hasRetryInterceptor = client.httpClient.dio.interceptors
          .any((i) => i is UspsRetryInterceptor);
      final hasLogInterceptor = client.httpClient.dio.interceptors
          .any((i) => i is UspsLogInterceptor);

      expect(hasRetryInterceptor, isTrue);
      expect(hasLogInterceptor, isTrue);

      expect(() => client.close(), returnsNormally);
    });
  });
}
