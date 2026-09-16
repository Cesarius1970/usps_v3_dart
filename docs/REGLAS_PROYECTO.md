# Reglas de Desarrollo y Operación del Proyecto

Este documento establece las normas obligatorias que rigen el flujo de trabajo, las interacciones con agentes y el control de versiones en **`usps_v3_dart`**.

---

## 1. Regla Mandatoria de Commits por Fase o Interacción

> [!IMPORTANT]
> **Al finalizar cada fase de desarrollo o cada interacción sustantiva con el agente, es OBLIGATORIO generar un commit en Git.**

### Estándar de Mensajes de Commit (Conventional Commits)
Los commits deben seguir la convención estándar internacional [Conventional Commits v1.0.0](https://www.conventionalcommits.org/):

```
<tipo>(<ámbito opcional>): <descripción concisa en imperativo y minúsculas>

[cuerpo explicativo opcional]
```

#### Tipos Permitidos:
- **`feat`**: Nueva funcionalidad o nuevo endpoint/dominio añadido (ej: `feat(pickup): add CarrierPickupRepository and scheduling endpoints`).
- **`fix`**: Corrección de un error o fallo en la lógica (ej: `fix(auth): handle expired token edge case on network reconnect`).
- **`docs`**: Cambios exclusivamente en la documentación o histórico (ej: `docs: update technical manual and add interaction log`).
- **`chore`**: Tareas de mantenimiento, actualización de dependencias o bump de versiones (ej: `chore(release): bump version to 1.0.2`).
- **`test`**: Creación o modificación de suites de pruebas unitarias o de integración (ej: `test(pricing): add unit tests for rate calculation models`).
- **`refactor`**: Modificación del código que no añade funcionalidades ni repara errores (ej: `refactor(network): optimize payload serialization logic`).
- **`style`**: Formato de código, espacios en blanco o reglas de linter sin cambios de lógica (ej: `style: format Dart files following standard guidelines`).

---

## 2. Estándar de Nomenclatura de Ramas (Git Branching)

Las ramas de trabajo deben crearse siguiendo una estructura jerárquica clara:

| Prefijo | Propósito | Ejemplo |
| :--- | :--- | :--- |
| `feature/` | Desarrollo de nuevas capacidades o endpoints | `feature/carrier-pickup-api` |
| `bugfix/` | Reparación de problemas o bugs no críticos | `bugfix/token-refresh-race-condition` |
| `hotfix/` | Corrección crítica urgente sobre producción | `hotfix/unhandled-401-dio-error` |
| `docs/` | Documentación técnica o manuales | `docs/update-technical-manual` |
| `release/` | Preparación de una nueva versión del paquete | `release/v1.1.0` |

---

## 3. Mantenimiento del Histórico y Manual Técnico

1. **`docs/historico/HISTORICO_SOLICITUDES.md`**:
   - Debe actualizarse en cada interacción, registrando la solicitud del usuario, la fecha y las acciones/respuestas ejecutadas por el agente de forma correlativa.
2. **`docs/MANUAL_TECNICO.md`**:
   - Debe mantenerse alineado con cualquier nuevo repositorio, clase o cambio arquitectónico que se introduzca en el SDK.

---

## 4. Karpathy Guidelines

Todo agente o colaborador debe aplicar:
1. **Pensar antes de codificar:** Declarar supuestos explícitos y clarificar ambigüedades.
2. **Simplicidad ante todo:** Código mínimo y limpio sin abstracciones prematuras.
3. **Cambios quirúrgicos:** Tocar exclusivamente los archivos y líneas necesarios para la solicitud en curso.
4. **Ejecución orientada a objetivos:** Definir criterios de aceptación verificables antes de concluir.
