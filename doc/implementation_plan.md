# Plan de Implementación: SDK USPS v3 (Dart)

## Fase 1: Configuración Inicial del Proyecto y Core Networking
1. **Inicializacion de GIT**: Inicializa el git de este proyecto y asegura realizar commit con comentarios acorde al evento, al final cada fase o subfase de la implementacion. Ligar este proyecto con el sitio https://github.com/Cesarius1970/usps_v3_dart. No publicar en ningun momento de la implementacion.
2. **Configurar Dependencias**: Añadir dependencias clave en `pubspec.yaml` (`http` o `dio`, `json_annotation`, `json_serializable`, `build_runner`).
3. **Definir el Cliente Base**: Crear `lib/src/core/network/usps_http_client.dart` para aislar las peticiones HTTP e interceptores.
4. **Manejo de Errores**: Crear la jerarquía de excepciones en `lib/src/core/exceptions/` (ej: `UspsNetworkException`, `UspsApiException`).
5. **Pruebas Unitarias Fase 1**: Pruebas con Mocks sobre el cliente base para asegurar correcto parseo de códigos de estado.

## Fase 2: Autenticación (OAuth 2.0)
1. **Modelado Auth**: Crear los DTOs de autenticación (`AuthResponse`).
2. **Auth Manager**: Crear `lib/src/core/auth/usps_auth_manager.dart` para gestionar la obtención y almacenamiento en memoria del Bearer Token de USPS v3.
3. **Integración con Interceptores**: Modificar el cliente base para inyectar `Authorization: Bearer <token>` y auto-renovar si se detecta expiración.
4. **Pruebas Unitarias Fase 2**: Testear flujos de obtención de token, caché en memoria y reintento.

## Fase 3: Feature - Tracking
1. **Modelos DTO**: Mapear el JSON a clases de Dart y generar archivos `.g.dart` con `json_serializable` para los payloads de Tracking.
2. **Repositorio**: Crear `lib/src/features/tracking/repository/tracking_repository.dart` exponiendo métodos strongly-typed.
3. **Pruebas Unitarias Fase 3**: Testear `TrackingRepository` con fixtures de la documentación de USPS.

## Fase 4: Feature - Shipping y Otras APIs (Iterativo)
1. Repetir el proceso de la Fase 3 iterativamente para las demás funcionalidades:
   - Shipping (Domestic & International)
   - Addresses
   - Locations
   - Pricing
2. Implementar repositorios y DTOs, asegurando cobertura de tests con datos simulados extraídos de `developer.usps.com`.

## Fase 5: Consolidación y Facade (UspsClient)
1. **Clase Principal**: Construir `UspsClient` en `lib/src/usps_client.dart`. Esta clase se instanciará con las credenciales y expondrá getters para cada feature (ej. `client.tracking.getTracking(...)`).
2. **Limpieza de Exportaciones**: Configurar `lib/usps_v3_dart.dart` para exportar la API pública sin filtrar detalles de implementación interna (`src/core/`).
3. **Documentación del Código**: Añadir docstrings estándar de Dart (`///`) a todas las entidades públicas.
4. **App de Ejemplo**: Crear un script funcional en `example/usps_v3_dart_example.dart`.
5. **Validación de Best Practices**: Valida que los documentos elaborados y el mismo proyecto cumplas con los documentado en https://dart.dev/tools/pub/packages

## Fase 6: Validación y Publicación en pub.dev
1. **Análisis de Código**: Ejecutar `dart format .` y asegurar 0 warnings con `dart analyze`.
2. **Ejecución de Pruebas**: Confirmar verde completo con `dart test`.
3. **Dry Run**: Validar reglas de publicación con `dart pub publish --dry-run` antes de hacer el release oficial.
