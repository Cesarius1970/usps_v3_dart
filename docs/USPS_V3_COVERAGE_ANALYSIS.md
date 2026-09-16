# Análisis de Cobertura: SDK Dart para USPS v3 API

## 1. Evaluación de Cobertura Actual (¿Cubre al 100%?)

**Resultado:** **Negativo (No cubre el 100%)**

El proyecto `usps_v3_dart` actual tiene una excelente arquitectura base orientada a dominios y cubre los **5 pilares fundamentales** del e-commerce:
- `Addresses` (Validación y búsqueda de ZIPs)
- `Locations` (Búsqueda de oficinas)
- `Pricing` (Cálculo de tarifas base)
- `Shipping` (Generación y cancelación de etiquetas)
- `Tracking` (Rastreo individual y por lotes)

Sin embargo, el ecosistema completo de USPS v3 (REST/JSON) incluye otros dominios y endpoints avanzados que actualmente **no están implementados**.

---

## 2. Mejoras Propuestas para las APIs ya Cubiertas

Para elevar el nivel de los repositorios actuales a un estándar "Enterprise", se proponen las siguientes mejoras:

### Tracking (Rastreo)
*   **Proof of Delivery (POD):** Añadir endpoints para solicitar la firma electrónica o la foto de entrega del paquete.
*   **Webhooks / Push Notifications:** Si el cliente requiere rastreo masivo, USPS v3 permite configuración de Webhooks para recibir actualizaciones automáticas en lugar de hacer *polling* (consultas repetitivas).

### Addresses (Direcciones)
*   **DPV (Delivery Point Validation):** Exponer de forma estructurada los metadatos de DPV. Esto indica no solo si la dirección existe, sino si es un buzón comercial, si está vacante, o si le faltan datos de apartamento.

### Pricing (Precios)
*   **Servicios Extra (Extra Services):** Ampliar los modelos para permitir cotizar servicios adicionales como: Seguro (Insurance), Confirmación de Firma (Signature Confirmation), o Manejo Especial.
*   **Tarifas Internacionales:** Añadir soporte para cotizar envíos fuera de EE.UU., lo cual requiere parámetros distintos (peso dimensional internacional, código del país de destino).

### Shipping (Envíos y Etiquetas)
*   **Formatos de Etiqueta:** Permitir especificar y manejar múltiples formatos de salida (ej. `PDF`, `ZPL` para impresoras térmicas, `PNG`).
*   **Formularios de Aduanas (Customs Forms):** Integrar la generación de formularios de aduana para envíos internacionales o a bases militares (APO/FPO).
*   **Manifiestos (SCAN Forms - PS Form 5630):** Añadir el endpoint para agrupar múltiples etiquetas del día en un solo código de barras que el cartero escanea al recoger.

### Locations (Ubicaciones)
*   **Filtros Avanzados:** Incluir queries para filtrar locaciones por servicios específicos (ej. *Oficinas que procesan Pasaportes*, *Oficinas con buzón de recolección 24/7*).

---

## 3. APIs Faltantes y Plan para Añadirlas

Para llegar a una cobertura del 100% de la plataforma USPS v3, se deben implementar los siguientes dominios. Todos seguirían el patrón de diseño actual (crear el `[Domain]Repository`, sus modelos y añadirlo al `UspsClient`).

### A. Carrier Pickup API (Recolección por el Cartero)
Esta es la API más crítica que falta. Permite a los usuarios programar que el cartero recoja los paquetes directamente en su casa o negocio.
*   **Endpoints a implementar:**
    *   `GET /pickup/v3/carrier-pickup/eligibility` (Verifica si la dirección califica para recolección).
    *   `POST /pickup/v3/carrier-pickup/` (Programa una recolección).
    *   `PUT /pickup/v3/carrier-pickup/{id}` (Modifica una recolección existente).
    *   `DELETE /pickup/v3/carrier-pickup/{id}` (Cancela la recolección).
*   **Diseño:** Crear un `PickupRepository`.

### B. Service Standards API (Estándares de Servicio / Tiempos de Entrega)
Permite predecir exactamente cuántos días tardará un envío entre el origen y el destino antes de comprar la etiqueta.
*   **Endpoints a implementar:**
    *   Consultas de tránsito por clase de correo (Priority Mail, Ground Advantage, etc.) entre un ZIP de origen y uno de destino.
*   **Diseño:** Crear un `ServiceStandardsRepository`.

### C. Returns API (Etiquetas de Retorno)
Para e-commerce, generar etiquetas de devolución que solo se cobran si el cliente las utiliza (*Scan Based Payment*).
*   **Diseño:** Puede integrarse dentro del actual `ShippingRepository` o crear un `ReturnsRepository` separado dependiendo de la estructura exacta de la documentación de USPS v3.

### D. Payments & eVS API
Para clientes de gran volumen (Enterprise), el manejo de pagos por eVS (Electronic Verification System) o EPS (Enterprise Payment System).
*   **Diseño:** Crear un `PaymentsRepository` para consultar balances y transacciones de la cuenta postal.

## Conclusión Estratégica
La base del proyecto actual es robusta y escalable. Para expandir el SDK, el primer paso lógico es implementar **Carrier Pickup API** y **Service Standards API**, seguidos de la funcionalidad de **Manifiestos (SCAN Forms)**, ya que completan el ciclo de vida de un envío estándar en e-commerce.
