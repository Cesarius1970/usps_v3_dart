import 'package:json_annotation/json_annotation.dart';
import '../../addresses/models/address_models.dart';

part 'pickup_models.g.dart';

/// Represents contact information for a carrier pickup.
@JsonSerializable(includeIfNull: false)
class PickupContact {
  /// Email address for pickup notifications.
  final String? email;

  /// Cell phone number.
  final String? cellNumber;

  /// Landline phone number.
  final String? phone;

  /// Phone extension.
  final String? extension;

  /// Creates a new [PickupContact] instance.
  const PickupContact({
    this.email,
    this.cellNumber,
    this.phone,
    this.extension,
  });

  /// Deserializes a JSON map into a [PickupContact].
  factory PickupContact.fromJson(Map<String, dynamic> json) =>
      _$PickupContactFromJson(json);

  /// Serializes this contact into a JSON map.
  Map<String, dynamic> toJson() => _$PickupContactToJson(this);
}

/// Represents the address and sender info for carrier pickup.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class PickupAddressInfo {
  /// First name of sender.
  final String? firstName;

  /// Last name of sender.
  final String? lastName;

  /// Company or firm name.
  final String? firm;

  /// Physical postal address for the pickup.
  final Address? address;

  /// Contact information list.
  final List<PickupContact>? contact;

  /// Creates a new [PickupAddressInfo] instance.
  const PickupAddressInfo({
    this.firstName,
    this.lastName,
    this.firm,
    this.address,
    this.contact,
  });

  /// Deserializes a JSON map into a [PickupAddressInfo].
  factory PickupAddressInfo.fromJson(Map<String, dynamic> json) =>
      _$PickupAddressInfoFromJson(json);

  /// Serializes this pickup address info into a JSON map.
  Map<String, dynamic> toJson() => _$PickupAddressInfoToJson(this);
}

/// Details of packages to be picked up by the carrier.
@JsonSerializable(includeIfNull: false)
class PickupPackageItem {
  /// USPS mail class or package type (e.g. "PRIORITY_MAIL", "USPS_GROUND_ADVANTAGE").
  final String packageType;

  /// Number of packages of this type.
  final dynamic packageCount;

  /// Creates a new [PickupPackageItem] instance.
  const PickupPackageItem({
    required this.packageType,
    required this.packageCount,
  });

  /// Deserializes a JSON map into a [PickupPackageItem].
  factory PickupPackageItem.fromJson(Map<String, dynamic> json) =>
      _$PickupPackageItemFromJson(json);

  /// Serializes this item into a JSON map.
  Map<String, dynamic> toJson() => _$PickupPackageItemToJson(this);
}

/// Location instruction for the package pickup.
@JsonSerializable(includeIfNull: false)
class PickupLocationInstruction {
  /// Location where packages are left (e.g. "FRONT_DOOR", "BACK_DOOR", "OFFICE").
  final String packageLocation;

  /// Special instructions for the carrier.
  final String? specialInstructions;

  /// Creates a new [PickupLocationInstruction] instance.
  const PickupLocationInstruction({
    required this.packageLocation,
    this.specialInstructions,
  });

  /// Deserializes a JSON map into a [PickupLocationInstruction].
  factory PickupLocationInstruction.fromJson(Map<String, dynamic> json) =>
      _$PickupLocationInstructionFromJson(json);

  /// Serializes this location instruction into a JSON map.
  Map<String, dynamic> toJson() => _$PickupLocationInstructionToJson(this);
}

/// Request payload to schedule a new carrier pickup.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CarrierPickupRequest {
  /// Requested date for pickup (YYYY-MM-DD).
  final String pickupDate;

  /// Pickup address and contact information.
  final PickupAddressInfo pickupAddress;

  /// List of packages to pick up.
  final List<PickupPackageItem> packages;

  /// Total estimated weight in pounds.
  final dynamic estimatedWeight;

  /// Instructions regarding where packages are located.
  final PickupLocationInstruction pickupLocation;

  /// Creates a new [CarrierPickupRequest] instance.
  const CarrierPickupRequest({
    required this.pickupDate,
    required this.pickupAddress,
    required this.packages,
    required this.estimatedWeight,
    required this.pickupLocation,
  });

  /// Deserializes a JSON map into a [CarrierPickupRequest].
  factory CarrierPickupRequest.fromJson(Map<String, dynamic> json) =>
      _$CarrierPickupRequestFromJson(json);

  /// Serializes this request into a JSON map.
  Map<String, dynamic> toJson() => _$CarrierPickupRequestToJson(this);
}

/// Request payload to modify an existing carrier pickup.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class CarrierPickupUpdateRequest {
  /// Confirmation number of the scheduled pickup.
  final String confirmationNumber;

  /// New requested pickup date.
  final String pickupDate;

  /// Updated pickup request details.
  final CarrierPickupRequest carrierPickupRequest;

  /// Creates a new [CarrierPickupUpdateRequest] instance.
  const CarrierPickupUpdateRequest({
    required this.confirmationNumber,
    required this.pickupDate,
    required this.carrierPickupRequest,
  });

  /// Deserializes a JSON map into a [CarrierPickupUpdateRequest].
  factory CarrierPickupUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CarrierPickupUpdateRequestFromJson(json);

  /// Serializes this request into a JSON map.
  Map<String, dynamic> toJson() => _$CarrierPickupUpdateRequestToJson(this);
}

/// Response received when scheduling, querying, or updating a carrier pickup.
@JsonSerializable(explicitToJson: true)
class CarrierPickupResponse {
  /// Unique confirmation number assigned by USPS.
  final String? confirmationNumber;

  /// Confirmed pickup date.
  final String? pickupDate;

  /// Confirmed pickup address information.
  final PickupAddressInfo? pickupAddress;

  /// List of packages scheduled for pickup.
  final List<PickupPackageItem>? packages;

  /// Estimated weight in pounds.
  final dynamic estimatedWeight;

  /// Confirmed pickup location details.
  final PickupLocationInstruction? pickupLocation;

  /// Status or confirmation message from USPS.
  final String? message;

  /// Pickup status (e.g. "Scheduled", "Cancelled").
  final String? status;

  /// Creates a new [CarrierPickupResponse] instance.
  const CarrierPickupResponse({
    this.confirmationNumber,
    this.pickupDate,
    this.pickupAddress,
    this.packages,
    this.estimatedWeight,
    this.pickupLocation,
    this.message,
    this.status,
  });

  /// Deserializes a JSON map into a [CarrierPickupResponse].
  factory CarrierPickupResponse.fromJson(Map<String, dynamic> json) =>
      _$CarrierPickupResponseFromJson(json);

  /// Serializes this response into a JSON map.
  Map<String, dynamic> toJson() => _$CarrierPickupResponseToJson(this);
}

/// Response returned by the carrier pickup eligibility endpoint.
@JsonSerializable(explicitToJson: true)
class CarrierPickupEligibilityResponse {
  /// Whether the address is eligible for carrier pickup.
  final bool? eligible;

  /// Standardized address for the pickup location.
  final Address? address;

  /// Description or message regarding pickup eligibility.
  final String? message;

  /// Creates a new [CarrierPickupEligibilityResponse] instance.
  const CarrierPickupEligibilityResponse({
    this.eligible,
    this.address,
    this.message,
  });

  /// Deserializes a JSON map into a [CarrierPickupEligibilityResponse].
  factory CarrierPickupEligibilityResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    if (!json.containsKey('address') &&
        (json.containsKey('streetAddress') || json.containsKey('ZIPCode'))) {
      final copy = Map<String, dynamic>.from(json);
      copy['address'] = Address.fromJson(json).toJson();
      copy['eligible'] ??= true;
      return _$CarrierPickupEligibilityResponseFromJson(copy);
    }
    return _$CarrierPickupEligibilityResponseFromJson(json);
  }

  /// Serializes this eligibility response into a JSON map.
  Map<String, dynamic> toJson() =>
      _$CarrierPickupEligibilityResponseToJson(this);
}
