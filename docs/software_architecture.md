# Arquitectura de Software: SDK USPS v3 (Dart)

## 1. Introducción
El paquete `usps_v3_dart` es un SDK puro en Dart que proporciona una interfaz completa y segura para consumir las APIs v3 de USPS (United States Postal Service), según las especificaciones de `developer.usps.com`.

## 2. Patrón Arquitectónico: "Feature-First" Adaptado a SDK
Dado que este paquete es un SDK (sin interfaz gráfica), el patrón MVVM clásico se adapta a una arquitectura orientada al dominio (Feature-First) con separación en capas de Datos y Dominio/Servicios.

### Capas Principales
1. **API Client (Core Networking)**: Maneja la comunicación HTTP, interceptores, autenticación OAuth 2.0 y el manejo global de errores.
2. **Models (Data Transfer Objects)**: Clases Dart generadas que representan los payloads y respuestas de la API (JSON serializable).
3. **Services / Repositories**: Clases que exponen los métodos para interactuar con dominios específicos de la API de USPS (ej. Tracking, Shipping, Addresses).

## 3. Estructura de Directorios (Feature First)
```text
lib/
├── src/
│   ├── core/                  # Lógica compartida
│   │   ├── network/           # Cliente HTTP base, interceptores
│   │   ├── auth/              # Gestor de OAuth 2.0
│   │   └── exceptions/        # Excepciones personalizadas
│   ├── features/              # Funcionalidades agrupadas por dominio
│   │   ├── tracking/
│   │   │   ├── models/        # DTOs (TrackingRequest, TrackingResponse)
│   │   │   └── repository/    # TrackingRepository (métodos de la API)
│   │   ├── shipping/
│   │   ├── addresses/
│   │   └── pricing/
│   └── usps_client.dart       # Clase principal (Facade) que expone los repositorios
└── usps_v3_dart.dart          # Archivo de exportación pública
```

## 4. Componentes Clave

### 4.1. USPS Client (Facade)
El punto de entrada principal para la aplicación cliente. 
El consumidor instanciará `UspsClient` proporcionando sus credenciales (Client ID, Client Secret). Esta clase orquestará la autenticación y expondrá instancias de los repositorios de cada feature.

### 4.2. OAuth 2.0 Manager
USPS v3 requiere autenticación Bearer Token. El gestor se encargará de:
- Solicitar el token de acceso.
- Almacenarlo en memoria durante su tiempo de vida.
- Renovar el token automáticamente antes de que expire en las llamadas subsecuentes (usando interceptores HTTP).

### 4.3. Generación de Modelos
Se utilizarán los paquetes `json_serializable`, `json_annotation` y `build_runner` para asegurar un mapeo robusto, type-safe y sin errores manuales de los JSON de USPS a objetos Dart.

### 4.4 Manejo de Errores
Se definirán excepciones específicas (ej. `UspsAuthException`, `UspsNetworkException`, `UspsApiException`) para facilitar el manejo de errores en las aplicaciones consumidoras (permitiendo que sus respectivos ViewModels reaccionen adecuadamente).
