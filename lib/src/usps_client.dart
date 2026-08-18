import 'core/auth/usps_auth_manager.dart';
import 'core/environment/usps_environment.dart';
import 'core/network/usps_auth_interceptor.dart';
import 'core/network/usps_http_client.dart';
import 'features/addresses/repository/addresses_repository.dart';
import 'features/locations/repository/locations_repository.dart';
import 'features/pricing/repository/pricing_repository.dart';
import 'features/shipping/repository/shipping_repository.dart';
import 'features/tracking/repository/tracking_repository.dart';

/// Central Facade client for accessing all USPS REST APIs (v3).
///
/// Handles OAuth 2.0 token lifecycle automatically and provides strongly-typed
/// access to tracking, addresses, locations, pricing, and shipping domains.
class UspsClient {
  /// Low-level HTTP client configured with base URL, timeouts, and auth interceptors.
  final UspsHttpClient httpClient;

  /// Authentication manager handling OAuth 2.0 token lifecycle and caching.
  final UspsAuthManager auth;

  /// Package tracking and scan history repository.
  final TrackingRepository tracking;

  /// US Address validation and standardization repository.
  final AddressesRepository addresses;

  /// Post Office and collection box search repository.
  final LocationsRepository locations;

  /// Postage rates and pricing calculation repository.
  final PricingRepository pricing;

  /// Shipping label generation and cancellation repository.
  final ShippingRepository shipping;

  /// Creates a new [UspsClient] with the given USPS Developer Portal credentials.
  ///
  /// - [clientId]: Application Client ID from developer.usps.com.
  /// - [clientSecret]: Application Client Secret from developer.usps.com.
  /// - [environment]: Defaults to [UspsEnvironment.production]. Use [UspsEnvironment.sandbox] for testing.
  /// - [baseUrl]: Optional override for the main API base URL.
  /// - [tokenEndpoint]: Optional override for the OAuth token endpoint.
  factory UspsClient({
    required String clientId,
    required String clientSecret,
    UspsEnvironment environment = UspsEnvironment.production,
    String? baseUrl,
    String? tokenEndpoint,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
  }) {
    final effectiveBaseUrl = baseUrl ?? environment.baseUrl;
    final effectiveTokenEndpoint = tokenEndpoint ?? environment.tokenEndpoint;

    final authManager = UspsAuthManager(
      clientId: clientId,
      clientSecret: clientSecret,
      tokenEndpoint: effectiveTokenEndpoint,
      environment: environment,
    );

    final httpClient = UspsHttpClient(
      baseUrl: effectiveBaseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );

    // Attach OAuth token interceptor to automatically sign requests and handle 401s
    httpClient.addInterceptor(
      UspsAuthInterceptor(
        authManager: authManager,
        dio: httpClient.dio,
      ),
    );

    return UspsClient._(
      httpClient: httpClient,
      auth: authManager,
      tracking: TrackingRepository(httpClient),
      addresses: AddressesRepository(httpClient),
      locations: LocationsRepository(httpClient),
      pricing: PricingRepository(httpClient),
      shipping: ShippingRepository(httpClient),
    );
  }

  /// Internal constructor for dependency injection or custom setups.
  const UspsClient._({
    required this.httpClient,
    required this.auth,
    required this.tracking,
    required this.addresses,
    required this.locations,
    required this.pricing,
    required this.shipping,
  });
}
