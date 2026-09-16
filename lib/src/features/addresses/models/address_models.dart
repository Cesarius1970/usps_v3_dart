import 'package:json_annotation/json_annotation.dart';

part 'address_models.g.dart';

/// Represents a standardized or input postal address within the United States.
@JsonSerializable(includeIfNull: false)
class Address {
  /// Primary street address line (e.g. "475 L'Enfant Plaza SW").
  @JsonKey(name: 'streetAddress')
  final String? streetAddress;

  /// Secondary address unit, suite, or apartment number (e.g. "Suite 100").
  @JsonKey(name: 'secondaryAddress')
  final String? secondaryAddress;

  /// City name.
  final String? city;

  /// 2-letter state code (e.g. "DC", "TX", "CA").
  final String? state;

  /// 5-digit primary ZIP code (e.g. "20260").
  @JsonKey(name: 'ZIPCode')
  final String? zipCode;

  /// 4-digit ZIP extension (e.g. "0001").
  @JsonKey(name: 'ZIPPlus4')
  final String? zipPlus4;

  /// Company or firm name.
  final String? firmName;

  /// Puerto Rico urbanization name, if applicable.
  final String? urbanization;

  /// Creates a new [Address] instance.
  const Address({
    this.streetAddress,
    this.secondaryAddress,
    this.city,
    this.state,
    this.zipCode,
    this.zipPlus4,
    this.firmName,
    this.urbanization,
  });

  /// Deserializes a JSON map into an [Address].
  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);

  /// Serializes this address into a JSON map.
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

/// Represents the response received from the USPS Address Standardization API.
@JsonSerializable(explicitToJson: true)
class AddressResponse {
  /// The normalized and standardized address returned by USPS.
  final Address? address;

  /// Optional list of warning or informational messages.
  final List<String>? warnings;

  /// Optional additional matching addresses.
  final List<Address>? additionalMatches;

  /// Creates a new [AddressResponse].
  const AddressResponse({this.address, this.warnings, this.additionalMatches});

  /// Deserializes a JSON map into an [AddressResponse].
  factory AddressResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressResponseFromJson(json);

  /// Serializes this response into a JSON map.
  Map<String, dynamic> toJson() => _$AddressResponseToJson(this);
}

/// Represents the result of a City and State lookup by ZIP code.
@JsonSerializable()
class CityStateLookup {
  /// The 5-digit ZIP code.
  @JsonKey(name: 'ZIPCode')
  final String zipCode;

  /// The standardized city name.
  final String city;

  /// The 2-letter state code.
  final String state;

  /// Creates a new [CityStateLookup].
  const CityStateLookup({
    required this.zipCode,
    required this.city,
    required this.state,
  });

  /// Deserializes a JSON map into a [CityStateLookup].
  factory CityStateLookup.fromJson(Map<String, dynamic> json) =>
      _$CityStateLookupFromJson(json);

  /// Serializes this lookup result into a JSON map.
  Map<String, dynamic> toJson() => _$CityStateLookupToJson(this);
}
