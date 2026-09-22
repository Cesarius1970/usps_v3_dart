# Manual Técnico de Arquitectura y Algoritmos: `usps_v3_dart`

> **Versión del SDK:** 1.2.0  
> **Plataforma Objetivo:** Dart 3.12+ / Flutter  
> **API de USPS Soportada:** USPS REST APIs (v3) (`developer.usps.com`)  
> **Última Actualización:** 2026-09-22

---

## 1. Visión General y Filosofía de Diseño

El SDK **`usps_v3_dart`** es una librería cliente en Dart fuertemente tipada, modular y diseñada para entornos de producción de alto rendimiento (backends en Dart Frog/Serverpod o aplicaciones móviles/desktop con Flutter). 

### Principios Arquitectónicos
1. **Patrón Fachada (Facade Pattern):** La clase [`UspsClient`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/usps_client.dart) orquesta todos los subsistemas (autenticación, red, repositorios) bajo una interfaz unificada y limpia.
2. **Separación de Responsabilidades:** Estructura modular dividida estrictamente entre `core/` (infraestructura común) y `features/` (dominios de negocio de USPS).
3. **Inmutabilidad y Tipado Fuerte:** Modelos serializables con `json_annotation` y constructores inmutables.
4. **Manejo Transparente de Fallos:** El cliente gestiona el ciclo de vida del token OAuth 2.0 y el refresco transparente ante errores 401 sin exponer la complejidad al desarrollador.

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                                       UspsClient                                       │
│                                   (Fachada Central)                                    │
└──────┬────────────┬────────────┬────────────┬────────────┬────────────┬────────────┬───────┘
       │            │            │            │            │            │            │
┌──────▼─────┐┌─────▼──────┐┌────▼───────┐┌───▼────────┐┌──▼────────┐┌──▼────────┐┌─▼────────┐
│  Tracking  ││ Addresses  ││ Locations  ││  Pricing   ││  Shipping  ││   Pickup   ││ Standards│ ... (ScanForms)
│ Repository ││ Repository ││ Repository ││ Repository ││ Repository ││ Repository ││Repository│
└──────┬─────┘└─────┬──────┘└────┬───────┘└───┬────────┘└──┬────────┘└──┬────────┘└─┬────────┘
       │            │            │            │            │            │            │
       └────────────┴────────────┴─────┬──────┴────────────┴────────────┴────────────┘
                                       │
                             ┌─────────▼────────┐
                             │  UspsHttpClient  │  (Dio + Interceptors: Retry, Auth, Log)
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

### 2.4. Algoritmo de Reintentos con Backoff Exponencial (`UspsRetryInterceptor`)
- **Archivo:** [`lib/src/core/network/usps_retry_interceptor.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/network/usps_retry_interceptor.dart)

Gestiona la resiliencia de la red reintentando automáticamente solicitudes idempotentes (`GET`, `HEAD`, `OPTIONS`) ante fallos transitorios:
- **Condiciones de Reintento:** Códigos de estado HTTP `429 (Too Many Requests)`, `500`, `502`, `503`, `504`, y errores de socket/timeout (`connectionTimeout`, `sendTimeout`, `receiveTimeout`, `connectionError`).
- **Fórmula de Retroceso Exponencial:**
  $$\text{Delay} = \text{initialDelay} \times (\text{backoffMultiplier})^{\text{attempt}}$$
- Al completarse el reintento exitosamente, resuelve la solicitud de manera transparente mediante `handler.resolve(response)`. Si excede `maxRetries`, propaga el error original.

---

### 2.5. Logging Seguro con Ofuscación de Credenciales (`UspsLogInterceptor`)
- **Archivo:** [`lib/src/core/network/usps_log_interceptor.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/network/usps_log_interceptor.dart)

Permite auditoría y depuración en consola en entornos de desarrollo y producción protegiendo información confidencial:
- **Encabezados:** Detecta `Authorization` y enmascara su contenido como `Bearer [REDACTED]`.
- **Payloads:** Filtra recursivamente claves sensibles como `client_secret` y `access_token` sustituyéndolas por `[REDACTED]`.
- **Salida:** Configurable con un delegado `logPrint: void Function(String message)`.

---

### 2.6. Validadores en el Cliente y Tipado Fuerte (`UspsValidators`, `UspsMailClass`, `LabelImageType`, `PriceType`)
- **Archivos:** [`lib/src/core/utils/usps_validators.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/utils/usps_validators.dart), [`lib/src/core/enums/usps_enums.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/enums/usps_enums.dart)

- **Validación Temprana:** Comprueba formato de códigos postales de 5 dígitos y códigos de rastreo (10 a 34 caracteres alfanuméricos) antes de emitir la llamada HTTP, ahorrando ancho de banda y cuota de API.
- **Tipado Fuerte:** Reemplaza cadenas de texto no tipadas por enumeraciones fuertemente tipadas en solicitudes de precios (`RateRequest`) y generación de etiquetas (`LabelRequest`).

---

### 2.7. Ciclo de Vida y Liberación de Conexiones (`close()`)
- **Archivos:** [`lib/src/usps_client.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/usps_client.dart), [`lib/src/core/network/usps_http_client.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/network/usps_http_client.dart), [`lib/src/core/auth/usps_auth_manager.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/auth/usps_auth_manager.dart)

Expone el método `close({bool force = false})` para cerrar de forma determinista los pools de sockets HTTP subyacentes tanto del cliente principal como del cliente aislado de autenticación, evitando fugas de memoria y descriptores en servidores backend (Dart Frog, Serverpod).

---

### 2.8. Programación y Gestión de Recolecciones (`CarrierPickupRepository`)
- **Archivos:** [`lib/src/features/pickup/repository/pickup_repository.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/features/pickup/repository/pickup_repository.dart), [`lib/src/features/pickup/models/pickup_models.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/features/pickup/models/pickup_models.dart)

Permite gestionar el ciclo de recolección de paquetes por el cartero postal:
1. **Comprobación de Elegibilidad (`checkEligibility`):** Valida si la dirección física cuenta con servicio de recolección domiciliaria antes de agendar.
2. **Creación (`schedulePickup`):** Agenda la recolección para una fecha determinada especificando ubicación del paquete (`packageLocation`) e instrucciones especiales.
3. **Consulta, Modificación y Cancelación (`getPickup`, `updatePickup`, `cancelPickup`):** Controla el estado y cancela peticiones usando el número de confirmación emitido por USPS.

---

### 2.9. Tiempos de Tránsito y Estándares de Entrega (`ServiceStandardsRepository`)
- **Archivos:** [`lib/src/features/service_standards/repository/service_standards_repository.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/features/service_standards/repository/service_standards_repository.dart), [`lib/src/features/service_standards/models/service_standards_models.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/features/service_standards/models/service_standards_models.dart)

Calcula los días estimados de entrega y fecha de llegada esperada entre cualquier par de códigos postales de origen y destino en EE.UU.:
- Soporta integración con [`UspsMailClass`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/enums/usps_enums.dart) o identificadores de clase personalizados.
- Valida anticipadamente los códigos postales usando [`UspsValidators`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/utils/usps_validators.dart).

---

### 2.10. Manifiestos Diarios SCAN Form PS 5630 (`ScanFormsRepository`)
- **Archivos:** [`lib/src/features/scan_forms/repository/scan_forms_repository.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/features/scan_forms/repository/scan_forms_repository.dart), [`lib/src/features/scan_forms/models/scan_form_models.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/features/scan_forms/models/scan_form_models.dart)

Consolida múltiples paquetes y etiquetas generadas durante el día en un único código de barras maestro (PS Form 5630 SCAN Form). Al momento de la entrega o recolección, el cartero escanea únicamente la hoja de manifiesto y todos los paquetes individuales quedan aceptados simultáneamente en la red de rastreo de USPS.

---

### 2.11. Verificación Criptográfica de Webhooks (`UspsWebhookVerifier`)
- **Archivo:** [`lib/src/core/utils/usps_webhook_verifier.dart`](file:///home/cesar/Proyectos/Dart/usps_v3_dart/lib/src/core/utils/usps_webhook_verifier.dart)

Facilita a aplicaciones backend en Dart (Shelf, Dart Frog, Serverpod) validar la autenticidad e integridad de las notificaciones HTTP POST enviadas por USPS:
- **Algoritmo:** HMAC-SHA256 calculado a partir del cuerpo crudo del mensaje y la clave secreta compartida.
- **Comparación en Tiempo Constante:** Implementa un bucle bit a bit (`sigBytes[i] ^ compBytes[i]`) sin salida temprana, mitigando vulnerabilidades a ataques de canal lateral basados en análisis de tiempo (*timing attacks*).

---

## 3. Estructura de Directorios del Código Fuente

```
lib/
├── usps_v3_dart.dart                 # Export público general del SDK
└── src/
    ├── usps_client.dart              # Fachada central (UspsClient)
    ├── core/                         # Infraestructura transversal
    │   ├── auth/                     # Autenticación y tokens OAuth 2.0
    │   ├── enums/                    # Enums tipados (UspsMailClass, etc.)
    │   ├── environment/              # Definición de entornos Sandbox y Prod
    │   ├── exceptions/               # Jerarquía de errores UspsException
    │   ├── network/                  # Cliente HTTP Dio y sus interceptores (Auth, Retry, Log)
    │   └── utils/                    # Validadores y Verificador de Webhooks
    └── features/                     # Dominios de negocio de USPS
        ├── addresses/                # Validación y ZIP code lookup
        ├── locations/                # Búsqueda de oficinas postales
        ├── pickup/                   # Recolección a domicilio (Carrier Pickup)
        ├── pricing/                  # Cálculo de tarifas de franqueo
        ├── scan_forms/               # Manifiestos consolidados (PS Form 5630)
        ├── service_standards/        # Estándares de entrega y tiempos de tránsito
        ├── shipping/                 # Generación y cancelación de etiquetas
        └── tracking/                 # Rastreo de paquetes y Proof of Delivery (POD)
```

---

## 4. Detalle de Repositorios y Endpoints Implementados

| Repositorio | Endpoint USPS v3 | Método HTTP | Propósito |
| :--- | :--- | :--- | :--- |
| **TrackingRepository** | `/tracking/v3/tracking/{trackingNumber}` | `GET` | Consulta el historial completo o resumen de un paquete. |
| **TrackingRepository** | `/tracking/v3/tracking` | `GET` | Consulta masiva por lotes (hasta 30 números de guía). |
| **TrackingRepository** | `/tracking/v3/tracking/{trackingNumber}/proof-of-delivery` | `POST` | Solicita carta o foto oficial de entrega con firma (POD). |
| **AddressesRepository** | `/addresses/v3/address` | `GET` | Estandariza una dirección y asigna ZIP+4. |
| **AddressesRepository** | `/addresses/v3/city-state` | `GET` | Obtiene ciudad y estado a partir de un código postal. |
| **AddressesRepository** | `/addresses/v3/zipcode` | `GET` | Busca el código postal a partir de calle y ciudad/estado. |
| **LocationsRepository** | `/locations/v3/locations` | `GET` | Localiza oficinas y buzones dentro de un radio en millas. |
| **PricingRepository** | `/prices/v3/base-rates/search` | `POST` | Cotiza tarifas base según peso, dimensiones y destino. |
| **ShippingRepository** | `/labels/v3/label` | `POST` | Genera una etiqueta de envío con código de barras y tarifa. |
| **ShippingRepository** | `/labels/v3/label/{trackingNumber}` | `DELETE` | Cancela una etiqueta no utilizada y solicita reembolso. |
| **CarrierPickupRepository** | `/pickup/v3/carrier-pickup/eligibility` | `GET` | Verifica elegibilidad de una dirección para recolección. |
| **CarrierPickupRepository** | `/pickup/v3/carrier-pickup` | `POST` | Programa una nueva recolección a domicilio con el cartero. |
| **CarrierPickupRepository** | `/pickup/v3/carrier-pickup/{id}` | `GET` | Consulta los detalles de una recolección programada. |
| **CarrierPickupRepository** | `/pickup/v3/carrier-pickup/{id}` | `PUT` | Modifica fecha o paquetes de una recolección existente. |
| **CarrierPickupRepository** | `/pickup/v3/carrier-pickup/{id}` | `DELETE` | Cancela una recolección programada con USPS. |
| **ServiceStandardsRepository** | `/service-standards/v3/estimates` | `GET` | Estima fecha y días de tránsito entre dos códigos postales. |
| **ServiceStandardsRepository** | `/service-standards/v3/standards` | `GET` | Obtiene estándares y compromisos de entrega por clase postal. |
| **ScanFormsRepository** | `/scan-forms/v3/scan-form` | `POST` | Genera manifiesto consolidado PS Form 5630 (código maestro). |
| **UspsWebhookVerifier** | *(Local Utility)* | `HMAC-SHA256` | Verificación en tiempo constante de firmas webhooks. |

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

## 6. Estrategia de Pruebas y Cobertura (100%)

El paquete implementa una suite completa de pruebas unitarias y de integración que alcanza el **100.00% de cobertura de líneas** sobre todo el código ejecutable de `lib/`.

### 6.1. Organización de Tests
- `test/core/`: Pruebas de excepciones (`UspsException`), gestor OAuth 2.0 (`UspsAuthManager`), interceptores Dio (`UspsAuthInterceptor`), y cliente HTTP (`UspsHttpClient`).
- `test/features/`: Pruebas exhaustivas para cada repositorio (`AddressesRepository`, `LocationsRepository`, `PricingRepository`, `ShippingRepository`, `TrackingRepository`) simulando respuestas 200, 400, 401 y excepciones de red mediante mocks de Dio (`MockHttpClientAdapter`).
- `test/models/`: Pruebas de serialización y deserialización bidireccional (`toJson` y `fromJson`) para todos los modelos de datos generados.

### 6.2. Verificación de Cobertura
Para ejecutar la suite y auditar la cobertura completa:
```bash
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
```

---

## 7. Mantenimiento del Manual

Cualquier cambio que modifique las firmas de los métodos públicos, altere el comportamiento del interceptor de autenticación, incorpore dependencias o agregue un nuevo repositorio debe registrarse de inmediato en las secciones correspondientes de este manual.
