/// Strongly-typed Dart SDK for USPS REST APIs (v3).
///
/// Features supported:
/// - Automated OAuth 2.0 token management, caching, and auto-refresh.
/// - Package tracking with full chronological scan events.
/// - US Address normalization and ZIP+4 validation.
/// - Post Office and facility search by coordinates or ZIP.
/// - Postage rate estimation and pricing tiers.
/// - Shipping label creation and barcode generation.
library;

export 'src/core/auth/models/oauth_token.dart';
export 'src/core/auth/usps_auth_manager.dart';
export 'src/core/enums/usps_enums.dart';
export 'src/core/environment/usps_environment.dart';
export 'src/core/exceptions/usps_exceptions.dart';
export 'src/core/network/usps_http_client.dart';
export 'src/core/network/usps_log_interceptor.dart';
export 'src/core/network/usps_retry_interceptor.dart';
export 'src/core/utils/usps_validators.dart';
export 'src/core/utils/usps_webhook_verifier.dart';
export 'src/features/addresses/models/address_models.dart';
export 'src/features/addresses/repository/addresses_repository.dart';
export 'src/features/locations/models/location_models.dart';
export 'src/features/locations/repository/locations_repository.dart';
export 'src/features/pickup/models/pickup_models.dart';
export 'src/features/pickup/repository/pickup_repository.dart';
export 'src/features/pricing/models/pricing_models.dart';
export 'src/features/pricing/repository/pricing_repository.dart';
export 'src/features/scan_forms/models/scan_form_models.dart';
export 'src/features/scan_forms/repository/scan_forms_repository.dart';
export 'src/features/service_standards/models/service_standards_models.dart';
export 'src/features/service_standards/repository/service_standards_repository.dart';
export 'src/features/shipping/models/shipping_models.dart';
export 'src/features/shipping/repository/shipping_repository.dart';
export 'src/features/tracking/models/tracking_models.dart';
export 'src/features/tracking/repository/tracking_repository.dart';
export 'src/usps_client.dart';

