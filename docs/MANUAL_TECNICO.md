# Manual Técnico de Arquitectura y Algoritmos: `usps_v3_dart`

> **Versión del SDK:** 1.0.1  
> **Plataforma Objetivo:** Dart 3.12+ / Flutter  
> **API de USPS Soportada:** USPS REST APIs (v3) (`developer.usps.com`)  
> **Última Actualización:** 2026-09-15

---

## 1. Visión General y Filosofía de Diseño

El SDK **`usps_v3_dart`** es una librería cliente en Dart fuertemente tipada, modular y diseñada para entornos de producción de alto rendimiento (backends en Dart Frog/Serverpod o aplicaciones móviles/desktop con Flutter). 

### Principios Arquitectónicos
1. **Patrón Fachada (Facade Pattern):** La clase [`UspsClient`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/usps_client.dart) orquesta todos los subsistemas (autenticación, red, repositorios) bajo una interfaz unificada y limpia.
2. **Separación de Responsabilidades:** Estructura modular dividida estrictamente entre `core/` (infraestructura común) y `features/` (dominios de negocio de USPS).
3. **Inmutabilidad y Tipado Fuerte:** Modelos serializables con `json_annotation` y constructores inmutables.
4. **Manejo Transparente de Fallos:** El cliente gestiona el ciclo de vida del token OAuth 2.0 y el refresco transparente ante errores 401 sin exponer la complejidad al desarrollador.

```
┌────────────────────────────────────────────────────────┐
│                      UspsClient                        │
│                   (Fachada Central)                    │
└──────┬──────────────┬─────────────┬─────────────┬──────┘
       │              │             │             │
┌──────▼──────┐┌──────▼──────┐┌─────▼──────┐┌─────▼──────┐
│  Tracking   ││  Addresses  ││  Locations ││  Shipping  │ ... (Pricing)
│ Repository  ││ Repository  ││ Repository ││ Repository │
└──────┬──────┘└──────┬──────┘└─────┬──────┘└─────┬──────┘
       │              │             │             │
       └──────────────┴──────┬──────┴─────────────┘
                             │
                   ┌─────────▼────────┐
                   │  UspsHttpClient  │  (Dio + Interceptors)
                   └─────────┬────────┘
                             │
                   ┌─────────▼────────┐
                   │  UspsAuthManager │  (OAuth 2.0 + Cache)
                   └──────────────────┘
```

---

## 2. Algoritmos y Mecanismos Clave

### 2.1. Algoritmo de Autenticación y Prevención de Concurrencia (`UspsAuthManager`)
- **Archivo:** [`lib/src/core/auth/usps_auth_manager.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/auth/usps_auth_manager.dart)

El gestor de autenticación resuelve el problema de múltiples llamadas simultáneas que intentan solicitar un nuevo token de acceso a USPS al mismo tiempo (condición de carrera o *race condition*).

#### Algoritmo de Obtención Segura de Token:
```dart
Future<String> getValidToken({bool forceRefresh = false})
```
1. **Comprobación de Caché:** Verifica si existe un `_cachedToken` en memoria y si `!_cachedToken.isExpired(buffer: 60s)`. Si es válido y no se forzó el refresco, retorna el token en `O(1)`.
2. **Bloqueo / Memoización de Petición en Vuelo:**
   - Si otra petición asíncrona ya inició la solicitud de un token (`_inFlightTokenRequest != null`), la llamada actual no realiza una petición HTTP adicional; en su lugar, se suscribe al mismo `Future` pendiente.
3. **Adquisición y Caché:**
   - Si no hay petición en vuelo, asigna `_inFlightTokenRequest = _fetchToken()`.
   - Utiliza una instancia aislada de `Dio` (`_authDio`) sin interceptores para evitar bucles recursivos infinitos.
   - Al resolver la respuesta, guarda el nuevo token con su timestamp de expiración local (`issuedAt + expiresIn`) y limpia `_inFlightTokenRequest` en un bloque `finally`.

---

### 2.2. Algoritmo del Interceptor de Autorización (`UspsAuthInterceptor`)
- **Archivo:** [`lib/src/core/network/usps_auth_interceptor.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/network/usps_auth_interceptor.dart)

Hereda de `QueuedInterceptor` de Dio para pausar la cola de peticiones salientes si se detecta un token vencido o una invalidación.

#### Flujo de Ejecución:
1. **En `onRequest`:**
   - Solicita `authManager.getValidToken()`.
   - Inyecta el encabezado `Authorization: Bearer <token>`.
   - Lanza `handler.next(options)`.
2. **En `onError` (Recuperación Transparente de Error 401):**
   - Si el servidor responde `HTTP 401 Unauthorized`:
     - Invoca `authManager.getValidToken(forceRefresh: true)`.
     - Actualiza el encabezado `Authorization` de las opciones originales con el nuevo token.
     - Reintenta la solicitud original mediante `dio.fetch(requestOptions)`.
     - Resuelve la petición con éxito a través de `handler.resolve(response)` sin que el llamador perciba el error original.
   - Si el fallo no es 401 o el refresco falla, delega el error a `handler.next(err)`.

---

### 2.3. Algoritmo de Traducción de Excepciones (`UspsHttpClient`)
- **Archivo:** [`lib/src/core/network/usps_http_client.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/network/usps_http_client.dart)

Centraliza las llamadas HTTP (`get`, `post`, `put`, `delete`) protegiendo el código contra fugas de abstracción de Dio y traduciendo códigos de estado en excepciones del dominio:

```dart
UspsException _transformDioException(DioException e)
```
- **Errores de Red y Timeout:** Mapeados a `UspsNetworkException`.
- **Certificados SSL:** Detecta `badCertificate` y levanta `UspsNetworkException`.
- **Inspección Profunda de Payload de USPS:** Analiza la respuesta JSON de error buscando estructuras habituales de USPS (`error.message`, `error.detail`, `error.code` o arreglos `errors[0].detail`).
- **Autenticación (401/403):** Mapeados a `UspsAuthException`.
- **Errores de Negocio (400, 404, 422, 500):** Mapeados a `UspsApiException` con el código de error oficial de USPS (`errorCode`).

---

## 3. Estructura de Directorios del Código Fuente

```
lib/
├── usps_v3_dart.dart                 # Export público general del SDK
└── src/
    ├── usps_client.dart              # Fachada central (UspsClient)
    ├── core/                         # Infraestructura transversal
    │   ├── auth/                     # Autenticación y tokens OAuth 2.0
    │   │   ├── models/oauth_token.dart
    │   │   └── usps_auth_manager.dart
    │   ├── environment/              # Definición de entornos Sandbox y Prod
    │   │   └── usps_environment.dart
    │   ├── exceptions/               # Jerarquía de errores UspsException
    │   │   └── usps_exceptions.dart
    │   └── network/                  # Cliente HTTP Dio y sus interceptores
    │       ├── usps_auth_interceptor.dart
    │       └── usps_http_client.dart
    └── features/                     # Dominios de negocio de USPS
        ├── addresses/                # Validación y ZIP code lookup
        │   ├── models/address_models.dart
        │   └── repository/addresses_repository.dart
        ├── locations/                # Búsqueda de oficinas postales
        │   ├── models/location_models.dart
        │   └── repository/locations_repository.dart
        ├── pricing/                  # Cálculo de tarifas de franqueo
        │   ├── models/pricing_models.dart
        │   └── repository/pricing_repository.dart
        ├── shipping/                 # Generación y cancelación de etiquetas
        │   ├── models/shipping_models.dart
        │   └── repository/shipping_repository.dart
        └── tracking/                 # Rastreo de paquetes individual y por lote
            ├── models/tracking_models.dart
            └── repository/tracking_repository.dart
```

---

## 4. Detalle de Repositorios y Endpoints Implementados

| Repositorio | Endpoint USPS v3 | Método HTTP | Propósito |
| :--- | :--- | :--- | :--- |
| **TrackingRepository** | `/tracking/v3/tracking/{trackingNumber}` | `GET` | Consulta el historial completo o resumen de un paquete. |
| **TrackingRepository** | `/tracking/v3/tracking` | `GET` | Consulta masiva por lotes (hasta 30 números de guía). |
| **AddressesRepository** | `/addresses/v3/address` | `GET` | Estandariza una dirección y asigna ZIP+4. |
| **AddressesRepository** | `/addresses/v3/city-state` | `GET` | Obtiene ciudad y estado a partir de un código postal. |
| **AddressesRepository** | `/addresses/v3/zipcode` | `GET` | Busca el código postal a partir de calle y ciudad/estado. |
| **LocationsRepository** | `/locations/v3/locations` | `GET` | Localiza oficinas y buzones dentro de un radio en millas. |
| **PricingRepository** | `/prices/v3/base-rates/search` | `POST` | Cotiza tarifas base según peso, dimensiones y destino. |
| **ShippingRepository** | `/labels/v3/label` | `POST` | Genera una etiqueta de envío con código de barras y tarifa. |
| **ShippingRepository** | `/labels/v3/label/{trackingNumber}` | `DELETE` | Cancela una etiqueta no utilizada y solicita reembolso. |

---

## 5. Guía para Incorporar Nuevos Endpoints o APIs

Para añadir un nuevo dominio (por ejemplo, **Carrier Pickup API** para recolección de paquetes):

1. **Crear el módulo en `lib/src/features/pickup/`:**
   - `models/pickup_models.dart`: Crear las clases de solicitud y respuesta con `@JsonSerializable()`. Ejecutar `dart run build_runner build`.
   - `repository/pickup_repository.dart`: Definir `CarrierPickupRepository` inyectando `UspsHttpClient`.
2. **Implementar los métodos de endpoint:**
   - `Future<EligibilityResponse> checkEligibility(...)` -> `_client.get('/pickup/v3/carrier-pickup/eligibility', ...)`
   - `Future<PickupResponse> schedulePickup(...)` -> `_client.post('/pickup/v3/carrier-pickup', ...)`
3. **Exponer en la fachada `UspsClient`:**
   - Añadir la propiedad `final CarrierPickupRepository pickup;` e instanciarla en el constructor factoría.
4. **Exportar en `lib/usps_v3_dart.dart`:**
   - Exponer los nuevos modelos y el repositorio.
5. **Crear pruebas unitarias:**
   - Añadir `test/features/pickup/pickup_repository_test.dart` simulando respuestas mock.
6. **Actualizar la documentación:**
   - Documentar los endpoints en `docs/MANUAL_TECNICO.md` y registrar la interacción en `docs/historico/HISTORICO_SOLICITUDES.md`.
   - Generar el commit correspondiente bajo `feat(pickup): ...`.

---

## 6. Mantenimiento del Manual

Cualquier cambio que modifique las firmas de los métodos públicos, altere el comportamiento del interceptor de autenticación o agregue un nuevo repositorio debe registrarse de inmediato en las secciones correspondientes de este manual.
