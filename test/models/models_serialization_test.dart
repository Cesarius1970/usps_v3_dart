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

  group('Carrier Pickup Models Serialization', () {
    test('CarrierPickupRequest, PickupContact, and CarrierPickupResponse roundtrip', () {
      const contact = PickupContact(
        email: 'test@example.com',
        cellNumber: '5551234567',
        phone: '5559876543',
        extension: '101',
      );
      final contactJson = contact.toJson();
      expect(contactJson['email'], equals('test@example.com'));
      expect(contactJson['extension'], equals('101'));
      final reconstructedContact = PickupContact.fromJson(contactJson);
      expect(reconstructedContact.cellNumber, equals('5551234567'));

      const addressInfo = PickupAddressInfo(
        firstName: 'John',
        lastName: 'Doe',
        firm: 'ACME',
        address: Address(streetAddress: '4120 Bingham Ave', city: 'Saint Louis'),
        contact: [contact],
      );
      final addressInfoJson = addressInfo.toJson();
      expect(addressInfoJson['firstName'], equals('John'));
      final reconstructedAddressInfo = PickupAddressInfo.fromJson(addressInfoJson);
      expect(reconstructedAddressInfo.lastName, equals('Doe'));

      const item = PickupPackageItem(packageType: 'PRIORITY_MAIL', packageCount: 2);
      final itemJson = item.toJson();
      expect(itemJson['packageType'], equals('PRIORITY_MAIL'));
      final reconstructedItem = PickupPackageItem.fromJson(itemJson);
      expect(reconstructedItem.packageCount, equals(2));

      const location = PickupLocationInstruction(
        packageLocation: 'FRONT_DOOR',
        specialInstructions: 'Ring bell',
      );
      final locationJson = location.toJson();
      expect(locationJson['packageLocation'], equals('FRONT_DOOR'));
      final reconstructedLocation = PickupLocationInstruction.fromJson(locationJson);
      expect(reconstructedLocation.specialInstructions, equals('Ring bell'));

      const request = CarrierPickupRequest(
        pickupDate: '2026-09-25',
        pickupAddress: addressInfo,
        packages: [item],
        estimatedWeight: 5.5,
        pickupLocation: location,
      );
      final reqJson = request.toJson();
      expect(reqJson['pickupDate'], equals('2026-09-25'));
      final reconstructedReq = CarrierPickupRequest.fromJson(reqJson);
      expect(reconstructedReq.pickupDate, equals('2026-09-25'));

      const updateReq = CarrierPickupUpdateRequest(
        confirmationNumber: 'WTC123456',
        pickupDate: '2026-09-26',
        carrierPickupRequest: request,
      );
      final updateJson = updateReq.toJson();
      expect(updateJson['confirmationNumber'], equals('WTC123456'));
      final reconstructedUpdate = CarrierPickupUpdateRequest.fromJson(updateJson);
      expect(reconstructedUpdate.confirmationNumber, equals('WTC123456'));

      const response = CarrierPickupResponse(
        confirmationNumber: 'WTC123456',
        pickupDate: '2026-09-25',
        pickupAddress: addressInfo,
        packages: [item],
        estimatedWeight: 5.5,
        pickupLocation: location,
        message: 'Success',
        status: 'Scheduled',
      );
      final respJson = response.toJson();
      expect(respJson['confirmationNumber'], equals('WTC123456'));
      final reconstructedResp = CarrierPickupResponse.fromJson(respJson);
      expect(reconstructedResp.status, equals('Scheduled'));

      const eligResp = CarrierPickupEligibilityResponse(
        eligible: true,
        address: Address(streetAddress: '4120 Bingham Ave'),
        message: 'Eligible',
      );
      final eligJson = eligResp.toJson();
      expect(eligJson['eligible'], isTrue);
      final reconstructedElig = CarrierPickupEligibilityResponse.fromJson(eligJson);
      expect(reconstructedElig.eligible, isTrue);
    });
  });

  group('Service Standards Models Serialization', () {
    test('ServiceStandardDetail and ServiceStandardsEstimate roundtrip', () {
      const detail = ServiceStandardDetail(
        daysToDelivery: 2,
        estimatedDeliveryDate: '2026-09-27',
        deliveryDays: '2-Day',
        serviceType: 'Commercial',
        message: 'On-time standard',
      );
      final detailJson = detail.toJson();
      expect(detailJson['daysToDelivery'], equals(2));
      final reconstructedDetail = ServiceStandardDetail.fromJson(detailJson);
      expect(reconstructedDetail.deliveryDays, equals('2-Day'));

      const estimate = ServiceStandardsEstimate(
        originZIPCode: '10018',
        destinationZIPCode: '95823',
        acceptanceDate: '2026-09-25',
        mailClass: 'PRIORITY_MAIL',
        serviceStandard: detail,
        serviceStandards: [detail],
        messages: ['Test message'],
      );
      final estimateJson = estimate.toJson();
      expect(estimateJson['originZIPCode'], equals('10018'));
      final reconstructedEstimate = ServiceStandardsEstimate.fromJson(estimateJson);
      expect(reconstructedEstimate.destinationZIPCode, equals('95823'));
      expect(reconstructedEstimate.serviceStandard?.daysToDelivery, equals(2));
    });
  });

  group('SCAN Form Models Serialization', () {
    test('ScanFormShipment, ScanFormFromAddress, ScanFormRequest, and ScanFormResponse roundtrip', () {
      const shipment = ScanFormShipment(
        trackingNumbers: ['9400111899562537680001'],
        mid: '123456789',
        manifestMID: '987654321',
      );
      final shipmentJson = shipment.toJson();
      expect(shipmentJson['MID'], equals('123456789'));
      final reconstructedShipment = ScanFormShipment.fromJson(shipmentJson);
      expect(reconstructedShipment.mid, equals('123456789'));

      const fromAddress = ScanFormFromAddress(
        firstName: 'Leroy',
        lastName: 'Brown',
        firm: 'USPS',
        address: Address(streetAddress: '4261 Port Union Rd', zipCode: '45011'),
      );
      final fromAddressJson = fromAddress.toJson();
      expect(fromAddressJson['firstName'], equals('Leroy'));
      final reconstructedFromAddress = ScanFormFromAddress.fromJson(fromAddressJson);
      expect(reconstructedFromAddress.lastName, equals('Brown'));

      // Test flattened address JSON parsing in ScanFormFromAddress
      final flatAddressJson = {
        'firstName': 'Leroy',
        'lastName': 'Brown',
        'streetAddress': '4261 Port Union Rd',
        'ZIPCode': '45011',
      };
      final parsedFlatFromAddress = ScanFormFromAddress.fromJson(flatAddressJson);
      expect(parsedFlatFromAddress.address?.streetAddress, equals('4261 Port Union Rd'));

      const request = ScanFormRequest(
        mailingDate: '2026-09-25',
        entryFacilityZIPCode: '45011',
        entryFacilityZIPPlus4: '1175',
        shipment: shipment,
        fromAddress: fromAddress,
      );
      final requestJson = request.toJson();
      expect(requestJson['form'], equals('5630'));
      final reconstructedRequest = ScanFormRequest.fromJson(requestJson);
      expect(reconstructedRequest.entryFacilityZIPCode, equals('45011'));

      const response = ScanFormResponse(
        form: '5630',
        imageType: 'PDF',
        labelType: '8.5x11LABEL',
        mailingDate: '2026-09-25',
        manifestNumber: 'MAN123456',
        trackingNumbers: ['9400111899562537680001'],
        labelImage: 'JVBERi0xLjQK...',
      );
      final respJson = response.toJson();
      expect(respJson['manifestNumber'], equals('MAN123456'));
      final reconstructedResp = ScanFormResponse.fromJson(respJson);
      expect(reconstructedResp.manifestNumber, equals('MAN123456'));
    });
  });

  group('Proof of Delivery Models Serialization', () {
    test('ProofOfDeliveryRequest and ProofOfDeliveryResponse roundtrip', () {
      const request = ProofOfDeliveryRequest(
        uniqueMailPieceId: 'UMP123',
        mailPieceIntakeDate: '2026-09-20',
        tableCode: 'T',
        requestType: 'email',
        firstName: 'John',
        lastName: 'Smith',
        email: ['john@example.com'],
        faxNumber: '5551234567',
      );
      final reqJson = request.toJson();
      expect(reqJson['uniqueMailPieceID'], equals('UMP123'));
      expect(reqJson['requestType'], equals('email'));
      final reconstructedReq = ProofOfDeliveryRequest.fromJson(reqJson);
      expect(reconstructedReq.uniqueMailPieceId, equals('UMP123'));
      expect(reconstructedReq.email.first, equals('john@example.com'));

      const response = ProofOfDeliveryResponse(
        success: true,
        message: 'Accepted',
      );
      final respJson = response.toJson();
      expect(respJson['success'], isTrue);
      final reconstructedResp = ProofOfDeliveryResponse.fromJson(respJson);
      expect(reconstructedResp.success, isTrue);
      expect(reconstructedResp.message, equals('Accepted'));
    });
  });
}

