// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackingEvent _$TrackingEventFromJson(Map<String, dynamic> json) =>
    TrackingEvent(
      eventType: json['eventType'] as String?,
      eventTimestamp: json['eventTimestamp'] as String?,
      eventCountry: json['eventCountry'] as String?,
      eventCity: json['eventCity'] as String?,
      eventState: json['eventState'] as String?,
      eventZIP: json['eventZIP'] as String?,
      eventCode: json['eventCode'] as String?,
      name: json['name'] as String?,
      firm: json['firm'] as String?,
      authorizedAgent: json['authorizedAgent'] as bool?,
      eventDescription: json['eventDescription'] as String?,
    );

Map<String, dynamic> _$TrackingEventToJson(TrackingEvent instance) =>
    <String, dynamic>{
      'eventType': instance.eventType,
      'eventTimestamp': instance.eventTimestamp,
      'eventCountry': instance.eventCountry,
      'eventCity': instance.eventCity,
      'eventState': instance.eventState,
      'eventZIP': instance.eventZIP,
      'eventCode': instance.eventCode,
      'name': instance.name,
      'firm': instance.firm,
      'authorizedAgent': instance.authorizedAgent,
      'eventDescription': instance.eventDescription,
    };

TrackingResponse _$TrackingResponseFromJson(Map<String, dynamic> json) =>
    TrackingResponse(
      trackingNumber: json['trackingNumber'] as String,
      status: json['status'] as String?,
      statusCategory: json['statusCategory'] as String?,
      statusSummary: json['statusSummary'] as String?,
      expectedDeliveryDate: json['expectedDeliveryDate'] as String?,
      expectedDeliveryTime: json['expectedDeliveryTime'] as String?,
      guaranteedDeliveryDate: json['guaranteedDeliveryDate'] as String?,
      destinationCity: json['destinationCity'] as String?,
      destinationState: json['destinationState'] as String?,
      destinationZIP: json['destinationZIP'] as String?,
      originCity: json['originCity'] as String?,
      originState: json['originState'] as String?,
      originZIP: json['originZIP'] as String?,
      mailClass: json['mailClass'] as String?,
      serviceTypeCode: json['serviceTypeCode'] as String?,
      trackingEvents:
          (json['trackingEvents'] as List<dynamic>?)
              ?.map((e) => TrackingEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrackingResponseToJson(TrackingResponse instance) =>
    <String, dynamic>{
      'trackingNumber': instance.trackingNumber,
      'status': instance.status,
      'statusCategory': instance.statusCategory,
      'statusSummary': instance.statusSummary,
      'expectedDeliveryDate': instance.expectedDeliveryDate,
      'expectedDeliveryTime': instance.expectedDeliveryTime,
      'guaranteedDeliveryDate': instance.guaranteedDeliveryDate,
      'destinationCity': instance.destinationCity,
      'destinationState': instance.destinationState,
      'destinationZIP': instance.destinationZIP,
      'originCity': instance.originCity,
      'originState': instance.originState,
      'originZIP': instance.originZIP,
      'mailClass': instance.mailClass,
      'serviceTypeCode': instance.serviceTypeCode,
      'trackingEvents': instance.trackingEvents.map((e) => e.toJson()).toList(),
    };
