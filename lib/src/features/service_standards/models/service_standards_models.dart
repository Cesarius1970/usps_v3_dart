import 'package:json_annotation/json_annotation.dart';

part 'service_standards_models.g.dart';

/// Detailed delivery standard timeline and benchmark information.
@JsonSerializable(includeIfNull: false)
class ServiceStandardDetail {
  /// Estimated number of days required for delivery.
  final int? daysToDelivery;

  /// Estimated delivery date (YYYY-MM-DD), if computed.
  final String? estimatedDeliveryDate;

  /// Human-readable delivery commitment description (e.g. "2-Day").
  final String? deliveryDays;

  /// Type of service applied to the shipment.
  final String? serviceType;

  /// Explanatory message or condition for the standard.
  final String? message;

  /// Creates a new [ServiceStandardDetail] instance.
  const ServiceStandardDetail({
    this.daysToDelivery,
    this.estimatedDeliveryDate,
    this.deliveryDays,
    this.serviceType,
    this.message,
  });

  /// Deserializes a JSON map into a [ServiceStandardDetail].
  factory ServiceStandardDetail.fromJson(Map<String, dynamic> json) =>
      _$ServiceStandardDetailFromJson(json);

  /// Serializes this detail into a JSON map.
  Map<String, dynamic> toJson() => _$ServiceStandardDetailToJson(this);
}

/// Response returned by the USPS Service Standards / Estimates API.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ServiceStandardsEstimate {
  /// Origin 5-digit ZIP code.
  final String? originZIPCode;

  /// Destination 5-digit ZIP code.
  final String? destinationZIPCode;

  /// Date when the package is accepted by USPS (YYYY-MM-DD).
  final String? acceptanceDate;

  /// Mail class queried.
  final String? mailClass;

  /// Primary delivery benchmark standard.
  final ServiceStandardDetail? serviceStandard;

  /// List of delivery benchmark standards when multiple options apply.
  final List<ServiceStandardDetail>? serviceStandards;

  /// Informational notes or advisory messages.
  final List<String>? messages;

  /// Creates a new [ServiceStandardsEstimate] instance.
  const ServiceStandardsEstimate({
    this.originZIPCode,
    this.destinationZIPCode,
    this.acceptanceDate,
    this.mailClass,
    this.serviceStandard,
    this.serviceStandards,
    this.messages,
  });

  /// Deserializes a JSON map into a [ServiceStandardsEstimate].
  factory ServiceStandardsEstimate.fromJson(Map<String, dynamic> json) =>
      _$ServiceStandardsEstimateFromJson(json);

  /// Serializes this estimate into a JSON map.
  Map<String, dynamic> toJson() => _$ServiceStandardsEstimateToJson(this);
}
