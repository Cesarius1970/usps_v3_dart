import 'package:json_annotation/json_annotation.dart';

/// Supported domestic USPS mail classes.
enum UspsMailClass {
  /// USPS Priority Mail (1-3 business days domestic delivery).
  @JsonValue('PRIORITY_MAIL')
  priorityMail('PRIORITY_MAIL'),

  /// USPS Priority Mail Express (fastest domestic service with money-back guarantee).
  @JsonValue('PRIORITY_MAIL_EXPRESS')
  priorityMailExpress('PRIORITY_MAIL_EXPRESS'),

  /// USPS Ground Advantage (reliable, cost-effective 2-5 day ground shipping).
  @JsonValue('USPS_GROUND_ADVANTAGE')
  groundAdvantage('USPS_GROUND_ADVANTAGE'),

  /// USPS Media Mail (cost-effective delivery for qualified books, media, recordings).
  @JsonValue('MEDIA_MAIL')
  mediaMail('MEDIA_MAIL'),

  /// USPS Library Mail (discounted service for schools, libraries, non-profit institutions).
  @JsonValue('LIBRARY_MAIL')
  libraryMail('LIBRARY_MAIL');

  /// The USPS wire representation of this mail class.
  final String code;

  const UspsMailClass(this.code);

  /// Parses a string into a [UspsMailClass], or returns null if not recognized.
  static UspsMailClass? tryParse(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toUpperCase();
    for (final val in values) {
      if (val.code == normalized) return val;
    }
    return null;
  }
}

/// Image formats supported for generating USPS shipping labels.
enum LabelImageType {
  /// Portable Document Format (PDF).
  @JsonValue('PDF')
  pdf('PDF'),

  /// Portable Network Graphics (PNG).
  @JsonValue('PNG')
  png('PNG'),

  /// Zebra Programming Language at 203 DPI for thermal label printers.
  @JsonValue('ZPL203')
  zpl203('ZPL203'),

  /// Zebra Programming Language at 300 DPI for thermal label printers.
  @JsonValue('ZPL300')
  zpl300('ZPL300'),

  /// Scalable Vector Graphics (SVG).
  @JsonValue('SVG')
  svg('SVG'),

  /// Tag Image File Format (TIFF).
  @JsonValue('TIFF')
  tiff('TIFF');

  /// The USPS wire string representation.
  final String code;

  const LabelImageType(this.code);

  /// Parses a string into a [LabelImageType], defaulting to [LabelImageType.pdf] if invalid.
  static LabelImageType fromString(String? code) {
    if (code == null) return LabelImageType.pdf;
    final normalized = code.trim().toUpperCase();
    for (final val in values) {
      if (val.code == normalized) return val;
    }
    return LabelImageType.pdf;
  }
}

/// Rate pricing tiers supported by USPS.
enum PriceType {
  /// Standard retail counter prices.
  @JsonValue('RETAIL')
  retail('RETAIL'),

  /// Discounted commercial pricing for volume shippers and software platforms.
  @JsonValue('COMMERCIAL')
  commercial('COMMERCIAL'),

  /// Negotiated contract pricing for enterprise shippers.
  @JsonValue('CONTRACT')
  contract('CONTRACT');

  /// The USPS wire string representation.
  final String code;

  const PriceType(this.code);

  /// Parses a string into a [PriceType], or returns null if not recognized.
  static PriceType? tryParse(String? code) {
    if (code == null) return null;
    final normalized = code.trim().toUpperCase();
    for (final val in values) {
      if (val.code == normalized) return val;
    }
    return null;
  }
}

/// Detail expansion options when querying tracking information.
enum TrackingExpand {
  /// Detailed response including all chronological scanning events.
  detail('DETAIL'),

  /// Summary response with current package status and estimated delivery only.
  summary('SUMMARY');

  /// The USPS wire query parameter value.
  final String value;

  const TrackingExpand(this.value);
}
