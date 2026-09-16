import 'package:json_annotation/json_annotation.dart';

part 'location_models.g.dart';

/// Represents a USPS Post Office, facility, or collection box location.
@JsonSerializable()
class UspsLocation {
  /// Unique identifier of the location.
  final String? locationId;

  /// Display name of the post office or facility (e.g. "L'ENFANT PLAZA POST OFFICE").
  final String? locationName;

  /// Type of facility (e.g. "POST OFFICE", "COLLECTION BOX", "CONTRACT POSTAL UNIT").
  final String? locationType;

  /// Primary street address.
  @JsonKey(name: 'streetAddress')
  final String? streetAddress;

  /// Secondary address line.
  @JsonKey(name: 'secondaryAddress')
  final String? secondaryAddress;

  /// City name.
  final String? city;

  /// State abbreviation.
  final String? state;

  /// 5-digit ZIP code.
  @JsonKey(name: 'ZIPCode')
  final String? zipCode;

  /// 4-digit ZIP extension.
  @JsonKey(name: 'ZIPPlus4')
  final String? zipPlus4;

  /// Contact phone number.
  final String? phone;

  /// Latitude coordinate.
  final double? latitude;

  /// Longitude coordinate.
  final double? longitude;

  /// Distance in miles from the search point.
  final double? distance;

  /// List of services offered at this facility (e.g. "Passport Services", "Money Orders").
  final List<String>? services;

  /// Creates a new [UspsLocation] instance.
  const UspsLocation({
    this.locationId,
    this.locationName,
    this.locationType,
    this.streetAddress,
    this.secondaryAddress,
    this.city,
    this.state,
    this.zipCode,
    this.zipPlus4,
    this.phone,
    this.latitude,
    this.longitude,
    this.distance,
    this.services,
  });

  /// Deserializes a JSON map into a [UspsLocation].
  factory UspsLocation.fromJson(Map<String, dynamic> json) =>
      _$UspsLocationFromJson(json);

  /// Serializes this location into a JSON map.
  Map<String, dynamic> toJson() => _$UspsLocationToJson(this);
}

/// Represents the search results from the USPS Locations API.
@JsonSerializable(explicitToJson: true)
class LocationsResponse {
  /// List of locations matching the search criteria.
  final List<UspsLocation> locations;

  /// Total count of matching locations found.
  final int? totalLocations;

  /// Creates a new [LocationsResponse].
  const LocationsResponse({
    this.locations = const <UspsLocation>[],
    this.totalLocations,
  });

  /// Deserializes a JSON map into a [LocationsResponse].
  factory LocationsResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationsResponseFromJson(json);

  /// Serializes this response into a JSON map.
  Map<String, dynamic> toJson() => _$LocationsResponseToJson(this);
}
