import 'core/auth/usps_auth_manager.dart';
import 'core/environment/usps_environment.dart';
import 'core/network/usps_auth_interceptor.dart';
import 'core/network/usps_http_client.dart';
import 'core/network/usps_log_interceptor.dart';
import 'core/network/usps_retry_interceptor.dart';
import 'features/addresses/repository/addresses_repository.dart';
import 'features/locations/repository/locations_repository.dart';
import 'features/pickup/repository/pickup_repository.dart';
import 'features/pricing/repository/pricing_repository.dart';
import 'features/scan_forms/repository/scan_forms_repository.dart';
import 'features/service_standards/repository/service_standards_repository.dart';
import 'features/shipping/repository/shipping_repository.dart';
import 'features/tracking/repository/tracking_repository.dart';

/// Central Facade client for accessing all USPS REST APIs (v3).
///
/// Handles OAuth 2.0 token lifecycle automatically and provides strongly-typed
/// access to tracking, addresses, locations, pricing, shipping, carrier pickups,
/// service standards, and SCAN forms.
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

  /// Carrier pickup scheduling, inquiries, and management repository.
  final CarrierPickupRepository pickup;

  /// Delivery benchmark estimates and service standards repository.
  final ServiceStandardsRepository serviceStandards;

  /// PS Form 5630 SCAN Form manifest generation repository.
  final ScanFormsRepository scanForms;

  /// Creates a new [UspsClient] with the given USPS Developer Portal credentials.
  ///
  /// The [clientId] and [clientSecret] are obtained from developer.usps.com.
  /// The [environment] defaults to [UspsEnvironment.production]. Use
  /// [UspsEnvironment.sandbox] for integration testing.
  /// Optionally override [baseUrl] or [tokenEndpoint], or configure custom
  /// [connectTimeout], [receiveTimeout], and [sendTimeout] durations.
  ///
  /// Set [enableLogging] to true to log redacted HTTP requests and responses.
  /// Set [enableRetry] to true to enable exponential backoff retry on transient failures.
  factory UspsClient({
    required String clientId,
    required String clientSecret,
    UspsEnvironment environment = UspsEnvironment.production,
    String? baseUrl,
    String? tokenEndpoint,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    bool enableLogging = false,
    void Function(String message)? logPrint,
    bool enableRetry = false,
    int maxRetries = 3,
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

    // Attach retry interceptor if enabled
    if (enableRetry) {
      httpClient.addInterceptor(
        UspsRetryInterceptor(
          dio: httpClient.dio,
          maxRetries: maxRetries,
        ),
      );
    }

    // Attach OAuth token interceptor to automatically sign requests and handle 401s
    httpClient.addInterceptor(
      UspsAuthInterceptor(authManager: authManager, dio: httpClient.dio),
    );

    // Attach logging interceptor if enabled
    if (enableLogging) {
      httpClient.addInterceptor(
        UspsLogInterceptor(logPrint: logPrint),
      );
    }

    return UspsClient._(
      httpClient: httpClient,
      auth: authManager,
      tracking: TrackingRepository(httpClient),
      addresses: AddressesRepository(httpClient),
      locations: LocationsRepository(httpClient),
      pricing: PricingRepository(httpClient),
      shipping: ShippingRepository(httpClient),
      pickup: CarrierPickupRepository(httpClient),
      serviceStandards: ServiceStandardsRepository(httpClient),
      scanForms: ScanFormsRepository(httpClient),
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
    required this.pickup,
    required this.serviceStandards,
    required this.scanForms,
  });

  /// Closes underlying HTTP clients and releases active network connections.
  void close({bool force = false}) {
    httpClient.close(force: force);
    auth.close(force: force);
  }
}
