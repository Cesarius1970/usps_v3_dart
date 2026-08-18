import 'package:json_annotation/json_annotation.dart';

part 'pricing_models.g.dart';

/// Represents a rate calculation request for domestic USPS mail and package services.
@JsonSerializable(includeIfNull: false)
class RateRequest {
  /// 5-digit origin ZIP code.
  @JsonKey(name: 'originZIPCode')
  final String originZipCode;

  /// 5-digit destination ZIP code.
  @JsonKey(name: 'destinationZIPCode')
  final String destinationZipCode;

  /// Package weight in pounds (e.g. 2.5).
  final double weight;

  /// Package length in inches.
  final double? length;

  /// Package width in inches.
  final double? width;

  /// Package height in inches.
  final double? height;

  /// Specific mail class to quote (e.g. "PRIORITY_MAIL", "USPS_GROUND_ADVANTAGE").
  final String? mailClass;

  /// Price type rate tier (e.g. "RETAIL", "COMMERCIAL").
  final String? priceType;

  /// Planned mailing date in ISO-8601 or YYYY-MM-DD format.
  final String? mailingDate;

  /// Whether nonstandard dimension or handling fees should be evaluated.
  final bool? hasNonstandardFees;

  /// Creates a new [RateRequest] instance.
  const RateRequest({
    required this.originZipCode,
    required this.destinationZipCode,
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.mailClass,
    this.priceType,
    this.mailingDate,
    this.hasNonstandardFees,
  });

  /// Deserializes a JSON map into a [RateRequest].
  factory RateRequest.fromJson(Map<String, dynamic> json) =>
      _$RateRequestFromJson(json);

  /// Serializes this request into a JSON map.
  Map<String, dynamic> toJson() => _$RateRequestToJson(this);
}

/// Represents an extra fee, surcharge, or special service fee attached to a postal rate.
@JsonSerializable()
class RateFee {
  /// Name or description of the fee (e.g. "Nonstandard Length Surcharge").
  final String? feeName;

  /// Amount charged for this fee.
  final double? feePrice;

  /// Creates a new [RateFee].
  const RateFee({this.feeName, this.feePrice});

  /// Deserializes a JSON map into a [RateFee].
  factory RateFee.fromJson(Map<String, dynamic> json) =>
      _$RateFeeFromJson(json);

  /// Serializes this fee into a JSON map.
  Map<String, dynamic> toJson() => _$RateFeeToJson(this);
}

/// Represents a single rate quote returned by USPS for a specific mail class.
@JsonSerializable()
class RateItem {
  /// USPS mail class identifier (e.g. "PRIORITY_MAIL", "PRIORITY_MAIL_EXPRESS").
  final String? mailClass;

  /// Postage price for this class.
  final double? price;

  /// Postal pricing zone calculated between origin and destination (e.g. "01", "04", "08").
  final String? zone;

  /// Human-readable description of the service and delivery estimate.
  final String? description;

  /// Breakdown of additional fees or surcharges included in the rate.
  final List<RateFee>? fees;

  /// Creates a new [RateItem].
  const RateItem({
    this.mailClass,
    this.price,
    this.zone,
    this.description,
    this.fees,
  });

  /// Deserializes a JSON map into a [RateItem].
  factory RateItem.fromJson(Map<String, dynamic> json) =>
      _$RateItemFromJson(json);

  /// Serializes this rate item into a JSON map.
  Map<String, dynamic> toJson() => _$RateItemToJson(this);
}

/// Represents the response returned by the USPS Prices / Rates API.
@JsonSerializable()
class RateResponse {
  /// Total calculated base postage price.
  final double? totalBasePrice;

  /// Available rate quotes across matching mail classes.
  final List<RateItem> rates;

  /// Creates a new [RateResponse].
  const RateResponse({this.totalBasePrice, this.rates = const <RateItem>[]});

  /// Deserializes a JSON map into a [RateResponse].
  factory RateResponse.fromJson(Map<String, dynamic> json) =>
      _$RateResponseFromJson(json);

  /// Serializes this rate response into a JSON map.
  Map<String, dynamic> toJson() => _$RateResponseToJson(this);
}
