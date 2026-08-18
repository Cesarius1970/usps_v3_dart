import 'package:json_annotation/json_annotation.dart';

part 'oauth_token.g.dart';

/// Represents an OAuth 2.0 access token issued by the USPS authorization server.
@JsonSerializable()
class OAuthToken {
  /// The Bearer access token string.
  @JsonKey(name: 'access_token')
  final String accessToken;

  /// The token type (usually "Bearer").
  @JsonKey(name: 'token_type')
  final String tokenType;

  /// Token lifetime in seconds.
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  /// Token issuance status (e.g. "approved").
  final String? status;

  /// Granted scopes, if any.
  final String? scope;

  /// Timestamp when this token was obtained locally.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final DateTime issuedAt;

  /// Creates a new [OAuthToken] instance.
  OAuthToken({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.status,
    this.scope,
    DateTime? issuedAt,
  }) : issuedAt = issuedAt ?? DateTime.now();

  /// Deserializes a JSON map into an [OAuthToken].
  factory OAuthToken.fromJson(Map<String, dynamic> json) =>
      _$OAuthTokenFromJson(json);

  /// Serializes this token to a JSON map.
  Map<String, dynamic> toJson() => _$OAuthTokenToJson(this);

  /// Checks whether the token has expired, with an optional safety [bufferDuration] (defaults to 60 seconds).
  bool isExpired([Duration bufferDuration = const Duration(seconds: 60)]) {
    final expirationTime = issuedAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isAfter(expirationTime.subtract(bufferDuration));
  }
}
