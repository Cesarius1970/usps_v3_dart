import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../models/address_models.dart';

/// Repository for interacting with USPS Addresses REST APIs (v3).
class AddressesRepository {
  final UspsHttpClient _client;

  /// Creates a new [AddressesRepository] with the provided [_client].
  AddressesRepository(this._client);

  /// Standardizes and validates a US postal address, appending ZIP+4 codes if available.
  Future<AddressResponse> standardizeAddress(Address address) async {
    final queryParameters = <String, dynamic>{};
    if (address.streetAddress != null) {
      queryParameters['streetAddress'] = address.streetAddress;
    }
    if (address.secondaryAddress != null) {
      queryParameters['secondaryAddress'] = address.secondaryAddress;
    }
    if (address.city != null) {
      queryParameters['city'] = address.city;
    }
    if (address.state != null) {
      queryParameters['state'] = address.state;
    }
    if (address.zipCode != null) {
      queryParameters['ZIPCode'] = address.zipCode;
    }
    if (address.zipPlus4 != null) {
      queryParameters['ZIPPlus4'] = address.zipPlus4;
    }
    if (address.firmName != null) {
      queryParameters['firmName'] = address.firmName;
    }
    if (address.urbanization != null) {
      queryParameters['urbanization'] = address.urbanization;
    }

    final response = await _client.get<dynamic>(
      '/addresses/v3/address',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('address') || data.containsKey('warnings')) {
        return AddressResponse.fromJson(data);
      }
      return AddressResponse(address: Address.fromJson(data));
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from address standardization endpoint',
    );
  }

  /// Looks up the official city and state associated with a 5-digit [zipCode].
  Future<CityStateLookup> lookupCityState(String zipCode) async {
    final response = await _client.get<dynamic>(
      '/addresses/v3/city-state',
      queryParameters: {'ZIPCode': zipCode},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CityStateLookup.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from city-state lookup endpoint',
    );
  }

  /// Retrieves the complete ZIP and ZIP+4 codes for an input address.
  Future<AddressResponse> lookupZipCode(Address address) async {
    final queryParameters = <String, dynamic>{};
    if (address.streetAddress != null) {
      queryParameters['streetAddress'] = address.streetAddress;
    }
    if (address.secondaryAddress != null) {
      queryParameters['secondaryAddress'] = address.secondaryAddress;
    }
    if (address.city != null) {
      queryParameters['city'] = address.city;
    }
    if (address.state != null) {
      queryParameters['state'] = address.state;
    }
    if (address.firmName != null) {
      queryParameters['firmName'] = address.firmName;
    }

    final response = await _client.get<dynamic>(
      '/addresses/v3/zipcode',
      queryParameters: queryParameters,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('address') || data.containsKey('warnings')) {
        return AddressResponse.fromJson(data);
      }
      return AddressResponse(address: Address.fromJson(data));
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from zipcode lookup endpoint',
    );
  }
}
