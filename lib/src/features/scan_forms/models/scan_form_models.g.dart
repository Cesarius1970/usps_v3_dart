// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_form_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScanFormShipment _$ScanFormShipmentFromJson(Map<String, dynamic> json) =>
    ScanFormShipment(
      trackingNumbers: (json['trackingNumbers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      mid: json['MID'] as String?,
      manifestMID: json['manifestMID'] as String?,
    );

Map<String, dynamic> _$ScanFormShipmentToJson(ScanFormShipment instance) =>
    <String, dynamic>{
      'trackingNumbers': ?instance.trackingNumbers,
      'MID': ?instance.mid,
      'manifestMID': ?instance.manifestMID,
    };

ScanFormFromAddress _$ScanFormFromAddressFromJson(Map<String, dynamic> json) =>
    ScanFormFromAddress(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      firm: json['firm'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ScanFormFromAddressToJson(
  ScanFormFromAddress instance,
) => <String, dynamic>{
  'firstName': ?instance.firstName,
  'lastName': ?instance.lastName,
  'firm': ?instance.firm,
  'address': ?instance.address?.toJson(),
};

ScanFormRequest _$ScanFormRequestFromJson(Map<String, dynamic> json) =>
    ScanFormRequest(
      form: json['form'] as String? ?? '5630',
      imageType: json['imageType'] as String? ?? 'PDF',
      labelType: json['labelType'] as String? ?? '8.5x11LABEL',
      mailingDate: json['mailingDate'] as String,
      entryFacilityZIPCode: json['entryFacilityZIPCode'] as String,
      entryFacilityZIPPlus4: json['entryFacilityZIPPlus4'] as String?,
      destinationEntryFacilityType:
          json['destinationEntryFacilityType'] as String? ?? 'NONE',
      overwriteMailingDate: json['overwriteMailingDate'] as bool? ?? false,
      shipment: ScanFormShipment.fromJson(
        json['shipment'] as Map<String, dynamic>,
      ),
      fromAddress: ScanFormFromAddress.fromJson(
        json['fromAddress'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$ScanFormRequestToJson(ScanFormRequest instance) =>
    <String, dynamic>{
      'form': instance.form,
      'imageType': instance.imageType,
      'labelType': instance.labelType,
      'mailingDate': instance.mailingDate,
      'entryFacilityZIPCode': instance.entryFacilityZIPCode,
      'entryFacilityZIPPlus4': ?instance.entryFacilityZIPPlus4,
      'destinationEntryFacilityType': instance.destinationEntryFacilityType,
      'overwriteMailingDate': instance.overwriteMailingDate,
      'shipment': instance.shipment.toJson(),
      'fromAddress': instance.fromAddress.toJson(),
    };

ScanFormResponse _$ScanFormResponseFromJson(Map<String, dynamic> json) =>
    ScanFormResponse(
      form: json['form'] as String?,
      imageType: json['imageType'] as String?,
      labelType: json['labelType'] as String?,
      mailingDate: json['mailingDate'] as String?,
      manifestNumber: json['manifestNumber'] as String?,
      trackingNumbers: (json['trackingNumbers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      labelImage: json['labelImage'] as String?,
    );

Map<String, dynamic> _$ScanFormResponseToJson(ScanFormResponse instance) =>
    <String, dynamic>{
      'form': ?instance.form,
      'imageType': ?instance.imageType,
      'labelType': ?instance.labelType,
      'mailingDate': ?instance.mailingDate,
      'manifestNumber': ?instance.manifestNumber,
      'trackingNumbers': ?instance.trackingNumbers,
      'labelImage': ?instance.labelImage,
    };
