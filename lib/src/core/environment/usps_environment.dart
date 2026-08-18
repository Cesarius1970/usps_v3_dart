/// Defines the target USPS API environments.
library;

/// Represents the operating environment for USPS REST API v3.
enum UspsEnvironment {
  /// Production environment (live USPS systems).
  production(
    baseUrl: 'https://api.usps.com',
    tokenEndpoint: 'https://api.usps.com/oauth2/v3/token',
  ),

  /// Customer Acceptance Testing (CAT) / Sandbox environment.
  sandbox(
    baseUrl: 'https://api-cat.usps.com',
    tokenEndpoint: 'https://api-cat.usps.com/oauth2/v3/token',
  );

  /// Default API base URL for this environment.
  final String baseUrl;

  /// Default OAuth 2.0 token endpoint for this environment.
  final String tokenEndpoint;

  const UspsEnvironment({required this.baseUrl, required this.tokenEndpoint});
}
