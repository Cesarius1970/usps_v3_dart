import 'package:json_annotation/json_annotation.dart';

part 'tracking_models.g.dart';

/// Represents a single chronological tracking event/scan recorded by USPS.
@JsonSerializable()
class TrackingEvent {
  /// Type of event recorded.
  final String? eventType;

  /// ISO-8601 or formatted timestamp of the event.
  final String? eventTimestamp;

  /// Country where the event occurred.
  final String? eventCountry;

  /// City where the event occurred.
  final String? eventCity;

  /// State or province where the event occurred.
  final String? eventState;

  /// ZIP or postal code of the event location.
  final String? eventZIP;

  /// USPS internal event code.
  final String? eventCode;

  /// Name associated with the event (if signature captured or delivered to individual).
  final String? name;

  /// Firm or company name, if applicable.
  final String? firm;

  /// Indicates if an authorized agent received the package.
  final bool? authorizedAgent;

  /// Human-readable description of the tracking scan event.
  final String? eventDescription;

  /// Creates a new [TrackingEvent].
  const TrackingEvent({
    this.eventType,
    this.eventTimestamp,
    this.eventCountry,
    this.eventCity,
    this.eventState,
    this.eventZIP,
    this.eventCode,
    this.name,
    this.firm,
    this.authorizedAgent,
    this.eventDescription,
  });

  /// Deserializes a JSON map into a [TrackingEvent].
  factory TrackingEvent.fromJson(Map<String, dynamic> json) =>
      _$TrackingEventFromJson(json);

  /// Serializes this event into a JSON map.
  Map<String, dynamic> toJson() => _$TrackingEventToJson(this);
}

/// Represents the complete tracking information for a USPS package.
@JsonSerializable(explicitToJson: true)
class TrackingResponse {
  /// The USPS tracking number / barcode.
  final String trackingNumber;

  /// Current overall package status (e.g., "Delivered", "In Transit").
  final String? status;

  /// Status category (e.g., "DELIVERED", "IN_TRANSIT", "ACCEPTANCE").
  final String? statusCategory;

  /// Summary text describing the current status.
  final String? statusSummary;

  /// Expected delivery date (YYYY-MM-DD).
  final String? expectedDeliveryDate;

  /// Expected delivery time window or timestamp.
  final String? expectedDeliveryTime;

  /// Guaranteed delivery date, if guaranteed service.
  final String? guaranteedDeliveryDate;

  /// Destination city name.
  final String? destinationCity;

  /// Destination state 2-letter abbreviation.
  final String? destinationState;

  /// Destination ZIP code.
  final String? destinationZIP;

  /// Origin city name.
  final String? originCity;

  /// Origin state abbreviation.
  final String? originState;

  /// Origin ZIP code.
  final String? originZIP;

  /// USPS mail class (e.g., "PRIORITY_MAIL", "USPS_GROUND_ADVANTAGE").
  final String? mailClass;

  /// Service type code.
  final String? serviceTypeCode;

  /// Chronological list of scan events.
  final List<TrackingEvent> trackingEvents;

  /// Creates a new [TrackingResponse].
  const TrackingResponse({
    required this.trackingNumber,
    this.status,
    this.statusCategory,
    this.statusSummary,
    this.expectedDeliveryDate,
    this.expectedDeliveryTime,
    this.guaranteedDeliveryDate,
    this.destinationCity,
    this.destinationState,
    this.destinationZIP,
    this.originCity,
    this.originState,
    this.originZIP,
    this.mailClass,
    this.serviceTypeCode,
    this.trackingEvents = const [],
  });

  /// Deserializes a JSON map into a [TrackingResponse].
  factory TrackingResponse.fromJson(Map<String, dynamic> json) =>
      _$TrackingResponseFromJson(json);

  /// Serializes this tracking response into a JSON map.
  Map<String, dynamic> toJson() => _$TrackingResponseToJson(this);
}

/// Request payload to obtain official Proof of Delivery (POD) with signature or delivery photo.
@JsonSerializable(includeIfNull: false)
class ProofOfDeliveryRequest {
  /// Unique identifier of the mail piece, if available.
  @JsonKey(name: 'uniqueMailPieceID')
  final String? uniqueMailPieceId;

  /// Date when the piece was inducted/accepted (YYYY-MM-DD).
  final String? mailPieceIntakeDate;

  /// USPS internal table routing code.
  final String? tableCode;

  /// Delivery channel requested (e.g. "email" or "fax").
  final String requestType;

  /// Recipient's first name.
  final String? firstName;

  /// Recipient's last name.
  final String? lastName;

  /// Email addresses to receive the Proof of Delivery letter.
  final List<String> email;

  /// Destination fax number if requested by fax.
  final String? faxNumber;

  /// Creates a new [ProofOfDeliveryRequest] instance.
  const ProofOfDeliveryRequest({
    this.uniqueMailPieceId,
    this.mailPieceIntakeDate,
    this.tableCode,
    this.requestType = 'email',
    this.firstName,
    this.lastName,
    this.email = const [],
    this.faxNumber,
  });

  /// Deserializes a JSON map into a [ProofOfDeliveryRequest].
  factory ProofOfDeliveryRequest.fromJson(Map<String, dynamic> json) =>
      _$ProofOfDeliveryRequestFromJson(json);

  /// Serializes this request into a JSON map.
  Map<String, dynamic> toJson() => _$ProofOfDeliveryRequestToJson(this);
}

/// Response returned from the USPS Proof of Delivery API endpoint.
@JsonSerializable(includeIfNull: false)
class ProofOfDeliveryResponse {
  /// Whether the request was accepted by USPS.
  final bool success;

  /// Status code or confirmation message from the API.
  final String? message;

  /// Creates a new [ProofOfDeliveryResponse] instance.
  const ProofOfDeliveryResponse({
    required this.success,
    this.message,
  });

  /// Deserializes a JSON map into a [ProofOfDeliveryResponse].
  factory ProofOfDeliveryResponse.fromJson(Map<String, dynamic> json) =>
      _$ProofOfDeliveryResponseFromJson(json);

  /// Serializes this response into a JSON map.
  Map<String, dynamic> toJson() => _$ProofOfDeliveryResponseToJson(this);
}

