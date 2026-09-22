// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_standards_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceStandardDetail _$ServiceStandardDetailFromJson(
  Map<String, dynamic> json,
) => ServiceStandardDetail(
  daysToDelivery: (json['daysToDelivery'] as num?)?.toInt(),
  estimatedDeliveryDate: json['estimatedDeliveryDate'] as String?,
  deliveryDays: json['deliveryDays'] as String?,
  serviceType: json['serviceType'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$ServiceStandardDetailToJson(
  ServiceStandardDetail instance,
) => <String, dynamic>{
  'daysToDelivery': ?instance.daysToDelivery,
  'estimatedDeliveryDate': ?instance.estimatedDeliveryDate,
  'deliveryDays': ?instance.deliveryDays,
  'serviceType': ?instance.serviceType,
  'message': ?instance.message,
};

ServiceStandardsEstimate _$ServiceStandardsEstimateFromJson(
  Map<String, dynamic> json,
) => ServiceStandardsEstimate(
  originZIPCode: json['originZIPCode'] as String?,
  destinationZIPCode: json['destinationZIPCode'] as String?,
  acceptanceDate: json['acceptanceDate'] as String?,
  mailClass: json['mailClass'] as String?,
  serviceStandard: json['serviceStandard'] == null
      ? null
      : ServiceStandardDetail.fromJson(
          json['serviceStandard'] as Map<String, dynamic>,
        ),
  serviceStandards: (json['serviceStandards'] as List<dynamic>?)
      ?.map((e) => ServiceStandardDetail.fromJson(e as Map<String, dynamic>))
      .toList(),
  messages: (json['messages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ServiceStandardsEstimateToJson(
  ServiceStandardsEstimate instance,
) => <String, dynamic>{
  'originZIPCode': ?instance.originZIPCode,
  'destinationZIPCode': ?instance.destinationZIPCode,
  'acceptanceDate': ?instance.acceptanceDate,
  'mailClass': ?instance.mailClass,
  'serviceStandard': ?instance.serviceStandard?.toJson(),
  'serviceStandards': ?instance.serviceStandards
      ?.map((e) => e.toJson())
      .toList(),
  'messages': ?instance.messages,
};
