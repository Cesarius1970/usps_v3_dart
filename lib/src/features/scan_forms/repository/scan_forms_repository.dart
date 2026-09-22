import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../../../core/utils/usps_validators.dart';
import '../models/scan_form_models.dart';

/// Repository for creating and managing USPS SCAN Forms (PS Form 5630 manifests).
class ScanFormsRepository {
  final UspsHttpClient _client;

  /// Creates a new [ScanFormsRepository] with the provided [_client].
  ScanFormsRepository(this._client);

  /// Generates a PS Form 5630 SCAN Form manifest for multiple packages.
  ///
  /// The [request] details all packages to be consolidated into the barcode manifest.
  Future<ScanFormResponse> createScanForm(ScanFormRequest request) async {
    UspsValidators.requireValidZipCode(request.entryFacilityZIPCode);

    final response = await _client.post<dynamic>(
      '/scan-forms/v3/scan-form',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ScanFormResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from scan form generation endpoint',
    );
  }
}
