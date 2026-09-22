import '../../../core/enums/usps_enums.dart';
import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../../../core/utils/usps_validators.dart';
import '../models/service_standards_models.dart';

/// Repository for querying USPS Service Standards REST APIs (v3).
class ServiceStandardsRepository {
  final UspsHttpClient _client;

  /// Creates a new [ServiceStandardsRepository] with the provided [_client].
  ServiceStandardsRepository(this._client);

  /// Retrieves estimated delivery standards and transit dates between origin and destination ZIP codes.
  ///
  /// The [originZipCode], [destinationZipCode], and [acceptanceDate] (YYYY-MM-DD) are required.
  Future<ServiceStandardsEstimate> getEstimates({
    required String originZipCode,
    required String destinationZipCode,
    required String acceptanceDate,
    UspsMailClass? mailClass,
    String? mailClassString,
    String? destinationType,
    String? serviceTypeCodes,
  }) async {
    final validOrigin = UspsValidators.requireValidZipCode(originZipCode);
    final validDest = UspsValidators.requireValidZipCode(destinationZipCode);

    final queryParams = <String, dynamic>{
      'originZIPCode': validOrigin,
      'destinationZIPCode': validDest,
      'acceptanceDate': acceptanceDate,
    };

    final effectiveMailClass = mailClass?.code ?? mailClassString;
    if (effectiveMailClass != null) {
      queryParams['mailClass'] = effectiveMailClass;
    }
    if (destinationType != null) {
      queryParams['destinationType'] = destinationType;
    }
    if (serviceTypeCodes != null) {
      queryParams['serviceTypeCodes'] = serviceTypeCodes;
    }

    final response = await _client.get<dynamic>(
      '/service-standards/v3/estimates',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ServiceStandardsEstimate.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from service standards estimates endpoint',
    );
  }

  /// Retrieves general delivery standard benchmarks between origin and destination ZIP codes.
  Future<List<ServiceStandardsEstimate>> getStandards({
    required String originZipCode,
    required String destinationZipCode,
    UspsMailClass? mailClass,
    String? mailClassString,
    String? destinationType,
    String? serviceTypeCodes,
  }) async {
    final validOrigin = UspsValidators.requireValidZipCode(originZipCode);
    final validDest = UspsValidators.requireValidZipCode(destinationZipCode);

    final queryParams = <String, dynamic>{
      'originZIPCode': validOrigin,
      'destinationZIPCode': validDest,
    };

    final effectiveMailClass = mailClass?.code ?? mailClassString;
    if (effectiveMailClass != null) {
      queryParams['mailClass'] = effectiveMailClass;
    }
    if (destinationType != null) {
      queryParams['destinationType'] = destinationType;
    }
    if (serviceTypeCodes != null) {
      queryParams['serviceTypeCodes'] = serviceTypeCodes;
    }

    final response = await _client.get<dynamic>(
      '/service-standards/v3/standards',
      queryParameters: queryParams,
    );

    final data = response.data;
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(ServiceStandardsEstimate.fromJson)
          .toList();
    } else if (data is Map<String, dynamic>) {
      if (data['standards'] is List) {
        return (data['standards'] as List)
            .whereType<Map<String, dynamic>>()
            .map(ServiceStandardsEstimate.fromJson)
            .toList();
      }
      return [ServiceStandardsEstimate.fromJson(data)];
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from service standards endpoint',
    );
  }
}
