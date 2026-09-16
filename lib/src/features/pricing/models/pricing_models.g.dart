// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RateRequest _$RateRequestFromJson(Map<String, dynamic> json) => RateRequest(
  originZipCode: json['originZIPCode'] as String,
  destinationZipCode: json['destinationZIPCode'] as String,
  weight: (json['weight'] as num).toDouble(),
  length: (json['length'] as num?)?.toDouble(),
  width: (json['width'] as num?)?.toDouble(),
  height: (json['height'] as num?)?.toDouble(),
  mailClass: json['mailClass'] as String?,
  priceType: json['priceType'] as String?,
  mailingDate: json['mailingDate'] as String?,
  hasNonstandardFees: json['hasNonstandardFees'] as bool?,
);

Map<String, dynamic> _$RateRequestToJson(RateRequest instance) =>
    <String, dynamic>{
      'originZIPCode': instance.originZipCode,
      'destinationZIPCode': instance.destinationZipCode,
      'weight': instance.weight,
      'length': ?instance.length,
      'width': ?instance.width,
      'height': ?instance.height,
      'mailClass': ?instance.mailClass,
      'priceType': ?instance.priceType,
      'mailingDate': ?instance.mailingDate,
      'hasNonstandardFees': ?instance.hasNonstandardFees,
    };

RateFee _$RateFeeFromJson(Map<String, dynamic> json) => RateFee(
  feeName: json['feeName'] as String?,
  feePrice: (json['feePrice'] as num?)?.toDouble(),
);

Map<String, dynamic> _$RateFeeToJson(RateFee instance) => <String, dynamic>{
  'feeName': instance.feeName,
  'feePrice': instance.feePrice,
};

RateItem _$RateItemFromJson(Map<String, dynamic> json) => RateItem(
  mailClass: json['mailClass'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  zone: json['zone'] as String?,
  description: json['description'] as String?,
  fees: (json['fees'] as List<dynamic>?)
      ?.map((e) => RateFee.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RateItemToJson(RateItem instance) => <String, dynamic>{
  'mailClass': instance.mailClass,
  'price': instance.price,
  'zone': instance.zone,
  'description': instance.description,
  'fees': instance.fees,
};

RateResponse _$RateResponseFromJson(Map<String, dynamic> json) => RateResponse(
  totalBasePrice: (json['totalBasePrice'] as num?)?.toDouble(),
  rates:
      (json['rates'] as List<dynamic>?)
          ?.map((e) => RateItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <RateItem>[],
);

Map<String, dynamic> _$RateResponseToJson(RateResponse instance) =>
    <String, dynamic>{
      'totalBasePrice': instance.totalBasePrice,
      'rates': instance.rates.map((e) => e.toJson()).toList(),
    };
