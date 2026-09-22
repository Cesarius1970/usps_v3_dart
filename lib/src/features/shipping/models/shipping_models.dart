import 'package:json_annotation/json_annotation.dart';

import '../../../core/enums/usps_enums.dart';
import '../../addresses/models/address_models.dart';

part 'shipping_models.g.dart';

/// Request payload for generating domestic shipping labels with postage barcodes.
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class LabelRequest {
  /// Shipper / sender address.
  final Address fromAddress;

  /// Recipient destination address.
  final Address toAddress;

  /// Package weight in pounds.
  final double weight;

  /// Package length in inches.
  final double? length;

  /// Package width in inches.
  final double? width;

  /// Package height in inches.
  final double? height;

  /// Mail class (e.g. [UspsMailClass.priorityMail], [UspsMailClass.groundAdvantage]).
  final UspsMailClass? mailClass;

  /// Description of package contents.
  final String? packageDescription;

  /// Format of the returned label image.
  final LabelImageType imageType;

  /// Optional USPS Label Broker ID.
  final String? labelBrokerId;

  /// Creates a new [LabelRequest].
  const LabelRequest({
    required this.fromAddress,
    required this.toAddress,
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.mailClass,
    this.packageDescription,
    this.imageType = LabelImageType.pdf,
    this.labelBrokerId,
  });

  /// Deserializes a JSON map into a [LabelRequest].
  factory LabelRequest.fromJson(Map<String, dynamic> json) =>
      _$LabelRequestFromJson(json);

  /// Serializes this request into a JSON map.
  Map<String, dynamic> toJson() => _$LabelRequestToJson(this);
}

/// Represents the generated shipping label response from USPS.
@JsonSerializable()
class LabelResponse {
  /// The generated tracking barcode number.
  final String trackingNumber;

  /// Total postage charged for this label.
  final double? totalPrice;

  /// Label Broker ID if requested.
  final String? labelBrokerId;

  /// Base64-encoded label image or PDF data string.
  final String? labelImageBase64;

  /// Direct URL to download label if provided.
  final String? labelUrl;

  /// Additional metadata returned by USPS.
  final Map<String, dynamic>? labelMetadata;

  /// Creates a new [LabelResponse].
  const LabelResponse({
    required this.trackingNumber,
    this.totalPrice,
    this.labelBrokerId,
    this.labelImageBase64,
    this.labelUrl,
    this.labelMetadata,
  });

  /// Deserializes a JSON map into a [LabelResponse].
  factory LabelResponse.fromJson(Map<String, dynamic> json) =>
      _$LabelResponseFromJson(json);

  /// Serializes this label response into a JSON map.
  Map<String, dynamic> toJson() => _$LabelResponseToJson(this);
}
