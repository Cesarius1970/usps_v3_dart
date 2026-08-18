// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelRequest _$LabelRequestFromJson(Map<String, dynamic> json) => LabelRequest(
  fromAddress: Address.fromJson(json['fromAddress'] as Map<String, dynamic>),
  toAddress: Address.fromJson(json['toAddress'] as Map<String, dynamic>),
  weight: (json['weight'] as num).toDouble(),
  length: (json['length'] as num?)?.toDouble(),
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  mailClass: json['mailClass'] as String?,
  packageDescription: json['packageDescription'] as String?,
  imageType: json['imageType'] as String? ?? 'PDF',
  labelBrokerId: json['labelBrokerId'] as String?,
);

Map<String, dynamic> _$LabelRequestToJson(LabelRequest instance) =>
    <String, dynamic>{
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'weight': instance.weight,
      'length': ?instance.length,
      'width': ?instance.width,
      'height': ?instance.height,
      'mailClass': ?instance.mailClass,
      'packageDescription': ?instance.packageDescription,
      'imageType': instance.imageType,
      'labelBrokerId': ?instance.labelBrokerId,
    };

LabelResponse _$LabelResponseFromJson(Map<String, dynamic> json) =>
    LabelResponse(
      trackingNumber: json['trackingNumber'] as String,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      labelBrokerId: json['labelBrokerId'] as String?,
      labelImageBase64: json['labelImageBase64'] as String?,
      labelUrl: json['labelUrl'] as String?,
      labelMetadata: json['labelMetadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LabelResponseToJson(LabelResponse instance) =>
    <String, dynamic>{
      'trackingNumber': instance.trackingNumber,
      'totalPrice': instance.totalPrice,
      'labelBrokerId': instance.labelBrokerId,
      'labelImageBase64': instance.labelImageBase64,
      'labelUrl': instance.labelUrl,
      'labelMetadata': instance.labelMetadata,
    };
