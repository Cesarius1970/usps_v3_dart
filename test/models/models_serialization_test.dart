import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('Address Models Serialization', () {
    test('Address toJson and fromJson roundtrip', () {
      const address = Address(
        streetAddress: '475 LENFANT PLZ SW',
        secondaryAddress: 'STE 100',
        city: 'WASHINGTON',
        state: 'DC',
        zipCode: '20260',
        zipPlus4: '0001',
        firmName: 'USPS HQ',
        urbanization: 'URB',
      );

      final json = address.toJson();
      expect(json['streetAddress'], equals('475 LENFANT PLZ SW'));
      expect(json['secondaryAddress'], equals('STE 100'));
      expect(json['city'], equals('WASHINGTON'));
      expect(json['state'], equals('DC'));
      expect(json['ZIPCode'], equals('20260'));
      expect(json['ZIPPlus4'], equals('0001'));
      expect(json['firmName'], equals('USPS HQ'));
      expect(json['urbanization'], equals('URB'));

      final reconstructed = Address.fromJson(json);
      expect(reconstructed.streetAddress, equals(address.streetAddress));
      expect(reconstructed.secondaryAddress, equals(address.secondaryAddress));
      expect(reconstructed.city, equals(address.city));
      expect(reconstructed.state, equals(address.state));
      expect(reconstructed.zipCode, equals(address.zipCode));
      expect(reconstructed.zipPlus4, equals(address.zipPlus4));
    });

    test('AddressResponse toJson and fromJson roundtrip', () {
      const response = AddressResponse(
        address: Address(streetAddress: '123 MAIN ST', city: 'ANYTOWN'),
        warnings: ['Normalized street name'],
        additionalMatches: [Address(streetAddress: '123 MAIN ST APT 1')],
      );

      final json = response.toJson();
      expect(json['address'], isNotNull);
      expect(json['warnings'], equals(['Normalized street name']));
      expect(json['additionalMatches'], isNotEmpty);

      final reconstructed = AddressResponse.fromJson(json);
      expect(reconstructed.address?.streetAddress, equals('123 MAIN ST'));
      expect(reconstructed.warnings, equals(['Normalized street name']));
      expect(reconstructed.additionalMatches?.first.streetAddress, equals('123 MAIN ST APT 1'));
    });

    test('CityStateLookup toJson and fromJson roundtrip', () {
      const lookup = CityStateLookup(
        zipCode: '90210',
        city: 'BEVERLY HILLS',
        state: 'CA',
      );

      final json = lookup.toJson();
      expect(json['ZIPCode'], equals('90210'));
      expect(json['city'], equals('BEVERLY HILLS'));
      expect(json['state'], equals('CA'));

      final reconstructed = CityStateLookup.fromJson(json);
      expect(reconstructed.zipCode, equals('90210'));
      expect(reconstructed.city, equals('BEVERLY HILLS'));
      expect(reconstructed.state, equals('CA'));
    });
  });

  group('Location Models Serialization', () {
    test('UspsLocation and LocationsResponse toJson and fromJson roundtrip', () {
      const location = UspsLocation(
        locationId: 'LOC_101',
        locationName: 'Main Post Office',
        locationType: 'POST OFFICE',
        streetAddress: '100 POST RD',
        city: 'AUSTIN',
        state: 'TX',
        zipCode: '78701',
        latitude: 30.2672,
        longitude: -97.7431,
        phone: '512-555-0100',
      );

      final locJson = location.toJson();
      expect(locJson['locationId'], equals('LOC_101'));
      expect(locJson['latitude'], equals(30.2672));

      final reconstructedLoc = UspsLocation.fromJson(locJson);
      expect(reconstructedLoc.locationId, equals('LOC_101'));
      expect(reconstructedLoc.locationType, equals('POST OFFICE'));

      const response = LocationsResponse(
        totalLocations: 1,
        locations: [location],
      );

      final respJson = response.toJson();
      expect(respJson['totalLocations'], equals(1));
      expect(respJson['locations'], isNotEmpty);

      final reconstructedResp = LocationsResponse.fromJson(respJson);
      expect(reconstructedResp.totalLocations, equals(1));
      expect(reconstructedResp.locations.first.locationName, equals('Main Post Office'));
    });
  });

  group('Pricing Models Serialization', () {
    test('RateRequest, RateItem, and RateResponse toJson and fromJson roundtrip', () {
      const request = RateRequest(
        originZipCode: '90210',
        destinationZipCode: '10001',
        weight: 2.5,
        length: 10.0,
        width: 8.0,
        height: 4.0,
        mailClass: UspsMailClass.priorityMail,
        priceType: PriceType.retail,
        mailingDate: '2026-09-15',
        hasNonstandardFees: false,
      );

      final reqJson = request.toJson();
      expect(reqJson['originZIPCode'], equals('90210'));
      expect(reqJson['weight'], equals(2.5));
      expect(reqJson['mailClass'], equals('PRIORITY_MAIL'));
      expect(reqJson['priceType'], equals('RETAIL'));

      final reconstructedReq = RateRequest.fromJson(reqJson);
      expect(reconstructedReq.originZipCode, equals('90210'));
      expect(reconstructedReq.weight, equals(2.5));
      expect(reconstructedReq.mailClass, equals(UspsMailClass.priorityMail));
      expect(reconstructedReq.priceType, equals(PriceType.retail));

      const item = RateItem(
        mailClass: 'PRIORITY_MAIL',
        price: 9.85,
        zone: '8',
        description: 'Priority Mail 2-Day',
      );

      final itemJson = item.toJson();
      expect(itemJson['mailClass'], equals('PRIORITY_MAIL'));
      expect(itemJson['price'], equals(9.85));

      final reconstructedItem = RateItem.fromJson(itemJson);
      expect(reconstructedItem.price, equals(9.85));
      expect(reconstructedItem.parsedMailClass, equals(UspsMailClass.priorityMail));

      const fee = RateFee(feeName: 'Base Rate Fee', feePrice: 2.50);
      final feeJson = fee.toJson();
      expect(feeJson['feeName'], equals('Base Rate Fee'));
      expect(feeJson['feePrice'], equals(2.50));
      final reconstructedFee = RateFee.fromJson(feeJson);
      expect(reconstructedFee.feeName, equals('Base Rate Fee'));
      expect(reconstructedFee.feePrice, equals(2.50));

      const response = RateResponse(
        totalBasePrice: 9.85,
        rates: [item],
      );

      final respJson = response.toJson();
      expect(respJson['totalBasePrice'], equals(9.85));
      expect(respJson['rates'], isNotEmpty);

      final reconstructedResp = RateResponse.fromJson(respJson);
      expect(reconstructedResp.totalBasePrice, equals(9.85));
      expect(reconstructedResp.rates.first.mailClass, equals('PRIORITY_MAIL'));
    });
  });

  group('Shipping Models Serialization', () {
    test('LabelRequest and LabelResponse toJson and fromJson roundtrip', () {
      const request = LabelRequest(
        toAddress: Address(streetAddress: '100 DEST ST', city: 'NEW YORK', state: 'NY', zipCode: '10001'),
        fromAddress: Address(streetAddress: '200 ORIG ST', city: 'LOS ANGELES', state: 'CA', zipCode: '90001'),
        packageDescription: 'Documents',
        weight: 0.5,
        mailClass: UspsMailClass.priorityMail,
        imageType: LabelImageType.pdf,
      );

      final reqJson = request.toJson();
      expect(reqJson['packageDescription'], equals('Documents'));
      expect(reqJson['imageType'], equals('PDF'));
      expect(reqJson['mailClass'], equals('PRIORITY_MAIL'));

      final reconstructedReq = LabelRequest.fromJson(reqJson);
      expect(reconstructedReq.packageDescription, equals('Documents'));
      expect(reconstructedReq.toAddress.city, equals('NEW YORK'));
      expect(reconstructedReq.mailClass, equals(UspsMailClass.priorityMail));
      expect(reconstructedReq.imageType, equals(LabelImageType.pdf));

      const response = LabelResponse(
        trackingNumber: '9400111899562537624123',
        labelImageBase64: 'JVBERi0xLjQK...',
        labelBrokerId: 'LBRK_999',
        totalPrice: 10.50,
      );

      final respJson = response.toJson();
      expect(respJson['trackingNumber'], equals('9400111899562537624123'));
      expect(respJson['totalPrice'], equals(10.50));

      final reconstructedResp = LabelResponse.fromJson(respJson);
      expect(reconstructedResp.trackingNumber, equals('9400111899562537624123'));
      expect(reconstructedResp.labelBrokerId, equals('LBRK_999'));
    });
  });

  group('Tracking Models Serialization', () {
    test('TrackingEvent and TrackingResponse toJson and fromJson roundtrip', () {
      const event = TrackingEvent(
        eventType: 'DELIVERED',
        eventTimestamp: '2026-09-15T12:00:00Z',
        eventCity: 'WASHINGTON',
        eventState: 'DC',
        eventZIP: '20260',
        eventCode: '01',
        eventDescription: 'Delivered, In/At Mailbox',
      );

      final eventJson = event.toJson();
      expect(eventJson['eventType'], equals('DELIVERED'));
      expect(eventJson['eventCode'], equals('01'));

      final reconstructedEvent = TrackingEvent.fromJson(eventJson);
      expect(reconstructedEvent.eventType, equals('DELIVERED'));

      const response = TrackingResponse(
        trackingNumber: '9400111899562537624123',
        status: 'Delivered',
        statusCategory: 'DELIVERED',
        statusSummary: 'Your item was delivered at 12:00 pm',
        expectedDeliveryDate: '2026-09-15',
        trackingEvents: [event],
      );

      final respJson = response.toJson();
      expect(respJson['trackingNumber'], equals('9400111899562537624123'));
      expect(respJson['trackingEvents'], isNotEmpty);

      final reconstructedResp = TrackingResponse.fromJson(respJson);
      expect(reconstructedResp.trackingNumber, equals('9400111899562537624123'));
      expect(reconstructedResp.trackingEvents.first.eventCity, equals('WASHINGTON'));
    });
  });
}
