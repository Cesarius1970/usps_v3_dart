// ignore_for_file: avoid_print
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() async {
  // 1. Initialize the USPS SDK client with credentials
  final usps = UspsClient(
    clientId: 'YOUR_USPS_CLIENT_ID',
    clientSecret: 'YOUR_USPS_CLIENT_SECRET',
    environment: UspsEnvironment.sandbox, // Use sandbox for testing
  );

  print('=== USPS v3 Dart SDK Example ===');

  try {
    // 2. Package Tracking
    print('\n[1] Tracking a Package...');
    final tracking = await usps.tracking.getTracking(
      '9400111899562537624656',
      expand: TrackingExpand.detail,
    );
    print('Tracking Number: ${tracking.trackingNumber}');
    print('Status: ${tracking.status}');
    print('Events recorded: ${tracking.trackingEvents.length}');

    // 3. Address Validation & Standardization
    print('\n[2] Standardizing an Address...');
    const addressInput = Address(
      streetAddress: '475 L\'Enfant Plaza SW',
      secondaryAddress: 'Suite 100',
      city: 'Washington',
      state: 'DC',
      zipCode: '20260',
    );

    final standardized = await usps.addresses.standardizeAddress(addressInput);
    if (standardized.address != null) {
      final addr = standardized.address!;
      print(
        'Standardized: ${addr.streetAddress}, ${addr.city}, ${addr.state} ${addr.zipCode}-${addr.zipPlus4}',
      );
    }

    // 4. Rate Calculation
    print('\n[3] Calculating Postage Rates...');
    const rateRequest = RateRequest(
      originZipCode: '20260',
      destinationZipCode: '78701',
      weight: 2.5,
      length: 10.0,
      width: 6.0,
      height: 4.0,
      mailClass: UspsMailClass.priorityMail,
    );

    final rates = await usps.pricing.calculateRates(rateRequest);
    print('Base Price Total: \$${rates.totalBasePrice}');
    for (final rate in rates.rates) {
      print('- ${rate.mailClass} (Zone ${rate.zone}): \$${rate.price}');
    }

    // 5. Locations Search
    print('\n[4] Searching Nearby USPS Facilities...');
    final locations = await usps.locations.findLocations(
      zipCode: '20260',
      maxResults: 2,
    );
    for (final loc in locations.locations) {
      print('- ${loc.locationName} (${loc.streetAddress}, ${loc.city})');
    }
  } on UspsApiException catch (e) {
    print('USPS API Error (${e.statusCode}): ${e.message}');
  } on UspsAuthException catch (e) {
    print('USPS Auth Error: ${e.message}');
  } on UspsNetworkException catch (e) {
    print('Network Error: ${e.message}');
  } on UspsException catch (e) {
    print('General USPS SDK Error: ${e.message}');
  } finally {
    // 6. Dispose client and release network resources
    usps.close();
  }
}
