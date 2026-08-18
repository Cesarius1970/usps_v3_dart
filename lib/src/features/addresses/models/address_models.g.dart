// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
  streetAddress: json['streetAddress'] as String?,
  secondaryAddress: json['secondaryAddress'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['ZIPCode'] as String?,
  zipPlus4: json['ZIPPlus4'] as String?,
  firmName: json['firmName'] as String?,
  urbanization: json['urbanization'] as String?,
);

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
  'streetAddress': ?instance.streetAddress,
  'secondaryAddress': ?instance.secondaryAddress,
  'city': ?instance.city,
  'state': ?instance.state,
  'ZIPCode': ?instance.zipCode,
  'ZIPPlus4': ?instance.zipPlus4,
  'firmName': ?instance.firmName,
  'urbanization': ?instance.urbanization,
};

AddressResponse _$AddressResponseFromJson(Map<String, dynamic> json) =>
    AddressResponse(
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      additionalMatches: (json['additionalMatches'] as List<dynamic>?)
          ?.map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AddressResponseToJson(AddressResponse instance) =>
    <String, dynamic>{
      'address': instance.address,
      'warnings': instance.warnings,
      'additionalMatches': instance.additionalMatches,
    };

CityStateLookup _$CityStateLookupFromJson(Map<String, dynamic> json) =>
    CityStateLookup(
      zipCode: json['ZIPCode'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
    );

Map<String, dynamic> _$CityStateLookupToJson(CityStateLookup instance) =>
    <String, dynamic>{
      'ZIPCode': instance.zipCode,
      'city': instance.city,
      'state': instance.state,
    };
