# Guía de Ejemplos de la API (USPS v3 Dart SDK)

Esta guía documenta cada una de las interfaces, repositorios y modelos provistos por `usps_v3_dart`.

---

## 1. Inicialización del Cliente (`UspsClient`)

`UspsClient` actúa como facade central para acceder a todas las funcionalidades del SDK.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  final usps = UspsClient(
    clientId: 'TU_CLIENT_ID',
    clientSecret: 'TU_CLIENT_SECRET',
    // Opcional: Personalizar endpoints o Base URL
    baseUrl: 'https://api.usps.com',
    tokenEndpoint: 'https://api.usps.com/oauth2/v3/token',
  );

  // Acceso a repositorios:
  // usps.tracking
  // usps.addresses
  // usps.locations
  // usps.pricing
  // usps.shipping
  // usps.auth
}
```

---

## 2. Autenticación (`UspsAuthManager`)

El gestor de autenticación maneja el ciclo de vida del token OAuth 2.0, caching en memoria y auto-renovación ante expiración o respuestas `401 Unauthorized`.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() async {
  final authManager = UspsAuthManager(
    clientId: 'TU_CLIENT_ID',
    clientSecret: 'TU_CLIENT_SECRET',
  );

  // 1. Obtener un token válido (obtiene nuevo o usa caché en memoria)
  final token = await authManager.getValidToken();
  print('Bearer Token: $token');

  // 2. Verificar estado de autenticación
  print('¿Autenticado?: ${authManager.isAuthenticated}');

  // 3. Forzar refresco del token
  final nuevoToken = await authManager.getValidToken(forceRefresh: true);

  // 4. Limpiar caché en memoria
  authManager.clearToken();
}
```

---

## 3. Rastreo de Paquetes (`TrackingRepository`)

Permite consultar el estado y el historial cronológico de escaneos de un paquete.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void consultarRastreo(UspsClient usps) async {
  try {
    final TrackingResponse response = await usps.tracking.getTracking(
      '9400111899562537624656',
      expand: 'DETAIL', // 'DETAIL' o 'SUMMARY'
    );

    print('Número de Guía: ${response.trackingNumber}');
    print('Estado: ${response.status}');
    print('Resumen: ${response.statusSummary}');
    print('Fecha estimada de entrega: ${response.expectedDeliveryDate}');

    print('\nHistorial de eventos:');
    for (final TrackingEvent event in response.trackingEvents) {
      print('- [${event.eventTimestamp}] ${event.eventDescription} (${event.eventCity}, ${event.eventState})');
    }
  } on UspsApiException catch (e) {
    print('Error USPS [${e.statusCode}]: ${e.message}');
  } on UspsNetworkException catch (e) {
    print('Error de conexión: ${e.message}');
  }
}
```

---

## 4. Estandarización de Direcciones (`AddressesRepository`)

Valida direcciones en Estados Unidos, corrigiendo formatos y agregando el código ZIP+4.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void estandarizarDireccion(UspsClient usps) async {
  const direccionEntrada = Address(
    streetAddress: '475 L\'Enfant Plaza SW',
    secondaryAddress: 'Suite 100',
    city: 'Washington',
    state: 'DC',
    zipCode: '20260',
    firmName: 'USPS Headquarters',
  );

  try {
    final AddressResponse response = await usps.addresses.standardizeAddress(direccionEntrada);
    final Address? normalizada = response.address;

    if (normalizada != null) {
      print('Calle: ${normalizada.streetAddress}');
      print('Ciudad: ${normalizada.city}, ${normalizada.state}');
      print('Código Postal Completo: ${normalizada.zipCode}-${normalizada.zipPlus4}');
    }

    if (response.warnings != null && response.warnings!.isNotEmpty) {
      print('Advertencias: ${response.warnings!.join(', ')}');
    }
  } on UspsApiException catch (e) {
    print('Error al validar dirección: ${e.message}');
  }
}
```

---

## 5. Búsqueda de Sucursales y Ubicaciones (`LocationsRepository`)

Encuentra instalaciones y buzones de recolección de USPS mediante código postal o coordenadas geográficas.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void buscarUbicaciones(UspsClient usps) async {
  try {
    // Búsqueda por código postal
    final LocationsResponse responseZip = await usps.locations.findLocations(
      zipCode: '20260',
      maxResults: 3,
    );

    // O búsqueda por coordenadas geográficas
    final LocationsResponse responseGeo = await usps.locations.findLocations(
      latitude: 38.884,
      longitude: -77.018,
      maxResults: 3,
    );

    for (final UspsLocation loc in responseZip.locations) {
      print('Ubicación: ${loc.locationName} (${loc.locationType})');
      print('Dirección: ${loc.streetAddress}, ${loc.city}, ${loc.state} ${loc.zipCode}');
      print('Teléfono: ${loc.phone ?? 'N/A'}');
      print('Coordenadas: Lat ${loc.latitude}, Long ${loc.longitude}\n');
    }
  } on UspsApiException catch (e) {
    print('Error al buscar ubicaciones: ${e.message}');
  }
}
```

---

## 6. Cálculo de Tarifas y Precios (`PricingRepository`)

Calcula costos de franqueo para envíos domésticos según dimensiones, peso y códigos postales.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void cotizarEnvio(UspsClient usps) async {
  final cotizacion = RateRequest(
    originZipCode: '20260',
    destinationZipCode: '78701',
    weight: 2.5, // Libras
    length: 10.0, // Pulgadas
    width: 6.0,
    height: 4.0,
    mailClass: 'PRIORITY_MAIL', // Opcional
    priceType: 'RETAIL',        // Opcional
  );

  try {
    final RateResponse response = await usps.pricing.calculateRates(cotizacion);

    print('Precio Base Total: \$${response.totalBasePrice}');
    for (final RateItem rate in response.rates) {
      print('- Clase: ${rate.mailClass} | Zona: ${rate.zone} | Precio: \$${rate.price} (${rate.description})');
    }
  } on UspsApiException catch (e) {
    print('Error al cotizar envío: ${e.message}');
  }
}
```

---

## 7. Creación de Etiquetas de Envío (`ShippingRepository`)

Genera etiquetas postales con código de barras en formato PDF o Base64.

```dart
import 'package:usps_v3_dart/usps_v3_dart.dart';

void generarEtiqueta(UspsClient usps) async {
  const remitente = Address(
    streetAddress: '475 L\'Enfant Plaza SW',
    city: 'Washington',
    state: 'DC',
    zipCode: '20260',
  );

  const destinatario = Address(
    streetAddress: '100 Congress Ave',
    city: 'Austin',
    state: 'TX',
    zipCode: '78701',
  );

  const solicitud = LabelRequest(
    fromAddress: remitente,
    toAddress: destinatario,
    weight: 1.25,
    mailClass: 'PRIORITY_MAIL',
    packageDescription: 'Documentos comerciales',
    imageType: 'PDF', // 'PDF', 'PNG', 'ZPL203', 'ZPL300'
  );

  try {
    final LabelResponse response = await usps.shipping.createLabel(solicitud);

    print('Guía Generada: ${response.trackingNumber}');
    print('Total Cobrado: \$${response.totalPrice}');
    print('Label Broker ID: ${response.labelBrokerId ?? 'N/A'}');
    print('Longitud de datos de imagen: ${response.labelImageBase64?.length ?? 0} caracteres');
  } on UspsApiException catch (e) {
    print('Error al generar etiqueta: ${e.message}');
  }
}
```

---

## 8. Manejo de Excepciones

El SDK provee una jerarquía unificada de errores basada en `UspsException`:

| Excepción | Causa | Propiedades Clave |
|-----------|-------|-------------------|
| `UspsApiException` | Respuesta de error devuelta por la API de USPS (4xx, 5xx). | `statusCode` (int), `data` (Map<String, dynamic>?) |
| `UspsNetworkException` | Falla en la capa de red o transporte (Timeouts, sin conexión). | `message` (String) |
| `UspsUnknownException` | Errores no catalogados o inesperados durante el procesamiento. | `message` (String) |

```dart
try {
  await usps.tracking.getTracking('NUMERO_INVALIDO');
} on UspsApiException catch (e) {
  print('Código HTTP: ${e.statusCode}');
  print('Detalles: ${e.data}');
} on UspsNetworkException catch (e) {
  print('Fallo de red: ${e.message}');
} on UspsException catch (e) {
  print('Error general de USPS: ${e.message}');
}
```
