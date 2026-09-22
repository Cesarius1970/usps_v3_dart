// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupContact _$PickupContactFromJson(Map<String, dynamic> json) =>
    PickupContact(
      email: json['email'] as String?,
      cellNumber: json['cellNumber'] as String?,
      phone: json['phone'] as String?,
      extension: json['extension'] as String?,
    );

Map<String, dynamic> _$PickupContactToJson(PickupContact instance) =>
    <String, dynamic>{
      'email': ?instance.email,
      'cellNumber': ?instance.cellNumber,
      'phone': ?instance.phone,
      'extension': ?instance.extension,
    };

PickupAddressInfo _$PickupAddressInfoFromJson(Map<String, dynamic> json) =>
    PickupAddressInfo(
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      firm: json['firm'] as String?,
      address: json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      contact: (json['contact'] as List<dynamic>?)
          ?.map((e) => PickupContact.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PickupAddressInfoToJson(PickupAddressInfo instance) =>
    <String, dynamic>{
      'firstName': ?instance.firstName,
      'lastName': ?instance.lastName,
      'firm': ?instance.firm,
      'address': ?instance.address?.toJson(),
      'contact': ?instance.contact?.map((e) => e.toJson()).toList(),
    };

PickupPackageItem _$PickupPackageItemFromJson(Map<String, dynamic> json) =>
    PickupPackageItem(
      packageType: json['packageType'] as String,
      packageCount: json['packageCount'],
    );

Map<String, dynamic> _$PickupPackageItemToJson(PickupPackageItem instance) =>
    <String, dynamic>{
      'packageType': instance.packageType,
      'packageCount': ?instance.packageCount,
    };

PickupLocationInstruction _$PickupLocationInstructionFromJson(
  Map<String, dynamic> json,
) => PickupLocationInstruction(
  packageLocation: json['packageLocation'] as String,
  specialInstructions: json['specialInstructions'] as String?,
);

Map<String, dynamic> _$PickupLocationInstructionToJson(
  PickupLocationInstruction instance,
) => <String, dynamic>{
  'packageLocation': instance.packageLocation,
  'specialInstructions': ?instance.specialInstructions,
};

CarrierPickupRequest _$CarrierPickupRequestFromJson(
  Map<String, dynamic> json,
) => CarrierPickupRequest(
  pickupDate: json['pickupDate'] as String,
  pickupAddress: PickupAddressInfo.fromJson(
    json['pickupAddress'] as Map<String, dynamic>,
  ),
  packages: (json['packages'] as List<dynamic>)
      .map((e) => PickupPackageItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  estimatedWeight: json['estimatedWeight'],
  pickupLocation: PickupLocationInstruction.fromJson(
    json['pickupLocation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CarrierPickupRequestToJson(
  CarrierPickupRequest instance,
) => <String, dynamic>{
  'pickupDate': instance.pickupDate,
  'pickupAddress': instance.pickupAddress.toJson(),
  'packages': instance.packages.map((e) => e.toJson()).toList(),
  'estimatedWeight': ?instance.estimatedWeight,
  'pickupLocation': instance.pickupLocation.toJson(),
};

CarrierPickupUpdateRequest _$CarrierPickupUpdateRequestFromJson(
  Map<String, dynamic> json,
) => CarrierPickupUpdateRequest(
  confirmationNumber: json['confirmationNumber'] as String,
  pickupDate: json['pickupDate'] as String,
  carrierPickupRequest: CarrierPickupRequest.fromJson(
    json['carrierPickupRequest'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$CarrierPickupUpdateRequestToJson(
  CarrierPickupUpdateRequest instance,
) => <String, dynamic>{
  'confirmationNumber': instance.confirmationNumber,
  'pickupDate': instance.pickupDate,
  'carrierPickupRequest': instance.carrierPickupRequest.toJson(),
};

CarrierPickupResponse _$CarrierPickupResponseFromJson(
  Map<String, dynamic> json,
) => CarrierPickupResponse(
  confirmationNumber: json['confirmationNumber'] as String?,
  pickupDate: json['pickupDate'] as String?,
  pickupAddress: json['pickupAddress'] == null
      ? null
      : PickupAddressInfo.fromJson(
          json['pickupAddress'] as Map<String, dynamic>,
        ),
  packages: (json['packages'] as List<dynamic>?)
      ?.map((e) => PickupPackageItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  estimatedWeight: json['estimatedWeight'],
  pickupLocation: json['pickupLocation'] == null
      ? null
      : PickupLocationInstruction.fromJson(
          json['pickupLocation'] as Map<String, dynamic>,
        ),
  message: json['message'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$CarrierPickupResponseToJson(
  CarrierPickupResponse instance,
) => <String, dynamic>{
  'confirmationNumber': instance.confirmationNumber,
  'pickupDate': instance.pickupDate,
  'pickupAddress': instance.pickupAddress?.toJson(),
  'packages': instance.packages?.map((e) => e.toJson()).toList(),
  'estimatedWeight': instance.estimatedWeight,
  'pickupLocation': instance.pickupLocation?.toJson(),
  'message': instance.message,
  'status': instance.status,
};

CarrierPickupEligibilityResponse _$CarrierPickupEligibilityResponseFromJson(
  Map<String, dynamic> json,
) => CarrierPickupEligibilityResponse(
  eligible: json['eligible'] as bool?,
  address: json['address'] == null
      ? null
      : Address.fromJson(json['address'] as Map<String, dynamic>),
  message: json['message'] as String?,
);

Map<String, dynamic> _$CarrierPickupEligibilityResponseToJson(
  CarrierPickupEligibilityResponse instance,
) => <String, dynamic>{
  'eligible': instance.eligible,
  'address': instance.address?.toJson(),
  'message': instance.message,
};
