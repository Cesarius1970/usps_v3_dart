import '../../../core/exceptions/usps_exceptions.dart';
import '../../../core/network/usps_http_client.dart';
import '../models/pricing_models.dart';

/// Repository for calculating postage rates and fees using the USPS Pricing APIs (v3).
class PricingRepository {
  final UspsHttpClient _client;

  /// Creates a new [PricingRepository] with the provided [_client].
  PricingRepository(this._client);

  /// Calculates postage pricing and available mail classes for the given [request] parameters.
  Future<RateResponse> calculateRates(RateRequest request) async {
    final response = await _client.post<dynamic>(
      '/prices/v3/base-rates/search',
      data: request.toJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('rates') || data.containsKey('totalBasePrice')) {
        return RateResponse.fromJson(data);
      }
      if (data['rateList'] is List) {
        final list = (data['rateList'] as List)
            .whereType<Map<String, dynamic>>()
            .map(RateItem.fromJson)
            .toList();
        return RateResponse(
          totalBasePrice: (data['totalPrice'] as num?)?.toDouble(),
          rates: list,
        );
      }
      return RateResponse.fromJson(data);
    } else if (data is List) {
      final list = data
          .whereType<Map<String, dynamic>>()
          .map(RateItem.fromJson)
          .toList();
      return RateResponse(rates: list);
    }

    throw const UspsUnknownException(
      message:
          'Unexpected payload format received from rates calculation endpoint',
    );
  }
}
