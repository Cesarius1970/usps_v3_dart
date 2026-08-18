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
export 'src/core/environment/usps_environment.dart';
export 'src/core/exceptions/usps_exceptions.dart';
export 'src/features/addresses/models/address_models.dart';
export 'src/features/addresses/repository/addresses_repository.dart';
export 'src/features/locations/models/location_models.dart';
export 'src/features/locations/repository/locations_repository.dart';
export 'src/features/pricing/models/pricing_models.dart';
export 'src/features/pricing/repository/pricing_repository.dart';
export 'src/features/shipping/models/shipping_models.dart';
export 'src/features/shipping/repository/shipping_repository.dart';
export 'src/features/tracking/models/tracking_models.dart';
export 'src/features/tracking/repository/tracking_repository.dart';
export 'src/usps_client.dart';
