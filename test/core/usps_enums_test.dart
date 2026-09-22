import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('UspsMailClass', () {
    test('tryParse parses valid codes correctly', () {
      expect(
        UspsMailClass.tryParse('PRIORITY_MAIL'),
        equals(UspsMailClass.priorityMail),
      );
      expect(
        UspsMailClass.tryParse('priority_mail_express'),
        equals(UspsMailClass.priorityMailExpress),
      );
      expect(
        UspsMailClass.tryParse(' USPS_GROUND_ADVANTAGE '),
        equals(UspsMailClass.groundAdvantage),
      );
      expect(
        UspsMailClass.tryParse('MEDIA_MAIL'),
        equals(UspsMailClass.mediaMail),
      );
      expect(
        UspsMailClass.tryParse('LIBRARY_MAIL'),
        equals(UspsMailClass.libraryMail),
      );
    });

    test('tryParse returns null on unknown or null code', () {
      expect(UspsMailClass.tryParse(null), isNull);
      expect(UspsMailClass.tryParse('UNKNOWN_CLASS'), isNull);
      expect(UspsMailClass.tryParse(''), isNull);
    });
  });

  group('LabelImageType', () {
    test('fromString parses valid codes correctly', () {
      expect(LabelImageType.fromString('PDF'), equals(LabelImageType.pdf));
      expect(LabelImageType.fromString('png'), equals(LabelImageType.png));
      expect(
        LabelImageType.fromString(' ZPL203 '),
        equals(LabelImageType.zpl203),
      );
      expect(LabelImageType.fromString('ZPL300'), equals(LabelImageType.zpl300));
      expect(LabelImageType.fromString('svg'), equals(LabelImageType.svg));
      expect(LabelImageType.fromString('TIFF'), equals(LabelImageType.tiff));
    });

    test('fromString defaults to PDF on invalid or null code', () {
      expect(LabelImageType.fromString(null), equals(LabelImageType.pdf));
      expect(LabelImageType.fromString('INVALID'), equals(LabelImageType.pdf));
      expect(LabelImageType.fromString(''), equals(LabelImageType.pdf));
    });
  });

  group('PriceType', () {
    test('tryParse parses valid price types', () {
      expect(PriceType.tryParse('RETAIL'), equals(PriceType.retail));
      expect(PriceType.tryParse('commercial'), equals(PriceType.commercial));
      expect(PriceType.tryParse(' CONTRACT '), equals(PriceType.contract));
    });

    test('tryParse returns null for invalid or null code', () {
      expect(PriceType.tryParse(null), isNull);
      expect(PriceType.tryParse('NON_EXISTENT'), isNull);
      expect(PriceType.tryParse(''), isNull);
    });
  });

  group('TrackingExpand', () {
    test('values have expected wire representations', () {
      expect(TrackingExpand.detail.value, equals('DETAIL'));
      expect(TrackingExpand.summary.value, equals('SUMMARY'));
    });
  });
}
