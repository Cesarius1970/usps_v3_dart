// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UspsLocation _$UspsLocationFromJson(Map<String, dynamic> json) => UspsLocation(
  locationId: json['locationId'] as String?,
  locationName: json['locationName'] as String?,
  locationType: json['locationType'] as String?,
  streetAddress: json['streetAddress'] as String?,
  secondaryAddress: json['secondaryAddress'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  zipCode: json['ZIPCode'] as String?,
  zipPlus4: json['ZIPPlus4'] as String?,
  phone: json['phone'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  distance: (json['distance'] as num?)?.toDouble(),
  services: (json['services'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UspsLocationToJson(UspsLocation instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'locationName': instance.locationName,
      'locationType': instance.locationType,
      'streetAddress': instance.streetAddress,
      'secondaryAddress': instance.secondaryAddress,
      'city': instance.city,
      'state': instance.state,
      'ZIPCode': instance.zipCode,
      'ZIPPlus4': instance.zipPlus4,
      'phone': instance.phone,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'distance': instance.distance,
      'services': instance.services,
    };

LocationsResponse _$LocationsResponseFromJson(Map<String, dynamic> json) =>
    LocationsResponse(
      locations:
          (json['locations'] as List<dynamic>?)
              ?.map((e) => UspsLocation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <UspsLocation>[],
      totalLocations: (json['totalLocations'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LocationsResponseToJson(LocationsResponse instance) =>
    <String, dynamic>{
      'locations': instance.locations,
      'totalLocations': instance.totalLocations,
    };
