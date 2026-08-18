import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../models/shipping_models.dart';

/// Repository for creating and managing USPS shipping labels and domestic postage.
class ShippingRepository {
  final UspsHttpClient _client;

  /// Creates a new [ShippingRepository] with the provided [_client].
  ShippingRepository(this._client);

  /// Generates a shipping label and tracking barcode with the given [request] details.
  Future<LabelResponse> createLabel(LabelRequest request) async {
    final response = await _client.post<dynamic>(
      '/labels/v3/label',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LabelResponse.fromJson(data);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from label generation endpoint',
    );
  }

  /// Cancels / requests a refund for an unused shipping label by [trackingNumber].
  Future<bool> cancelLabel(String trackingNumber) async {
    final response = await _client.delete<dynamic>(
      '/labels/v3/label/$trackingNumber',
    );

    final statusCode = response.statusCode;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      return true;
    }

    return false;
  }
}
