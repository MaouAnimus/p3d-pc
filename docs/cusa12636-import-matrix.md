# Matriz de Importaciones y Servicios del Huésped (CUSA12636)

Este documento audita y contrasta las importaciones reales del ejecutable de PS4 de ***Persona 3: Dancing in Moonlight*** (`CUSA12636`, `eboot.bin` / `boot-linked.bin`) frente a las implementaciones efectivas en la capa de compatibilidad de PC (`engine/src/runtime*.c` y `link_modules.py`).

---

## 1. Resumen Estadístico de Enlace y Resolución

| Categoría | Cantidad | Descripción |
| :--- | :--- | :--- |
| **Imports del ejecutable SELF/ELF** | **532** | Símbolos importados declarados en las cabeceras ELF del juego (`analysis.json`). |
| **Puntos de enlace dinámico (Relocations)** | **622** | Relocalizaciones de importación analizadas en el binario (`link.json`). |
| **Enlace nativo PRX (`link_modules.py`)** | **153** | Exportaciones resueltas e inyectadas desde `libc.prx` y `libSceFios2.prx`. |
| **Resolución en tiempo de ejecución (`runtime_resolve`)** | **469** | Símbolos resueltos por NID y módulo en el runtime C y capa GPU Vulkan. |
| **Imports no resueltos en el arranque** | **0** | El 100% de las dependencias requeridas para iniciar el motor se resuelven satisfactoriamente. |

---

## 2. Clasificación de Implementación por Módulo

Para evitar confusiones entre "enlazado" y "funcionalmente completo", las 42 bibliotecas importadas se clasifican según su fidelidad de comportamiento:

1. **Resuelto por Enlace Nativo:** Implementado mediante el código original del módulo PRX de PS4 o shim nativo directo.
2. **Contrato Funcional Completo:** Implementado en el runtime host con lógica activa de emulación de llamada y estado.
3. **Contrato Simplificado / Stub Seguro:** Funciones que devuelven estado desconectado, finalización automática o código de error controlado para evitar bloqueos del juego.
4. **No Requerido / Periférico Ausente:** Periféricos opcionales (VR, cámara) que se reportan como no conectados.

---

## 3. Matriz Detallada por Módulos de Sistema

| Módulo PS4 | Imports (NID) | Estado de Implementación | Backend Host / Estrategia |
| :--- | :---: | :--- | :--- |
| `libkernel` | 128 | **Contrato Funcional** | Memoria virtual (`VirtualAlloc2`), pthreads, semáforos, mutexes, rwlocks, timers de alta resolución y TLS. |
| `libSceGnmDriver` | 97 | **Contrato Funcional** | Traducción de comandos GNM/PM4 a **Vulkan 1.3** (`gpu/` / `vk_rasterizer.cpp`). |
| `libSceAudioOut` | 5 | **Contrato Funcional** | Streams de audio **SDL3** con remuestreo flotante a 48 kHz y emulación de reloj de búfer. |
| `libScePad` | 6 | **Contrato Funcional** | Muestreo de eventos de mando con **SDL3** y fallback de teclado configurable. |
| `libSceAjm` | 11 | **Contrato Funcional** | Descompresión de audio ATRAC9 mediante `LibAtrac9` y MP3 mediante `FFmpeg`. |
| `libSceSaveData` | 7 | **Contrato Funcional** | Persistencia en disco local bajo la ruta `/savedata0` (`user/savedata/`). |
| `libSceVideodec` | 6 | **Contrato Funcional** | Decodificación de flujos de vídeo para CRI Sofdec2 / MPV (`runtime_videodec.c`). |
| `libSceFiber` | 6 | **Contrato Funcional** | Planificación de fibras cooperativas de usuario (`runtime_fiber.c`). |
| `libSceRtc` | 5 | **Contrato Funcional** | Reloj de tiempo real sincronizado con el reloj del host (`runtime_rtc.c`). |
| `libSceUserService` | 5 | **Contrato Funcional** | Simulación de usuario local activo (`User ID 1`, nombre "Player"). |
| `libSceAppContent` | 4 | **Contrato Funcional** | Proveedor offline del juego base (`runtime_content.c`). |
| `libSceVideoOut` | 16 | **Contrato Funcional** | Sincronización vertical vblank a 60 Hz y registro de swapchain. |
| `libSceSysmodule` | 3 | **Contrato Funcional** | Carga dinámica simulada de módulos con conteo de referencias. |
| `libScePosix` | 5 | **Contrato Funcional** | Claves thread-specific (`pthread_key_*`) mapeadas a la ABI huésped. |
| `libSceSystemService` | 6 | **Contrato Funcional** | Manejo de eventos de energía, foco de ventana y ocultamiento de splash screen. |
| `libSceHmd` | 19 | *Stub Seguro* | PS VR reportado como desconectado de forma segura. |
| `libSceVrTracker` | 11 | *Stub Seguro* | Seguimiento VR reportado como inactivo. |
| `libSceHmdSetupDialog`| 5 | *Stub Seguro* | Diálogo de configuración VR auto-completado. |
| `libSceCamera` | 8 | *Stub Seguro* | PlayStation Camera reportada como no disponible. |
| `libSceMouse` | 4 | *Stub Seguro* | Ratón auxiliar reportado como inactivo. |
| `libSceNpMatching2` | 17 | *Stub Seguro (Offline)* | Multijugador online desactivado; devuelve estado offline. |
| `libSceNpTus` | 14 | *Stub Seguro (Offline)* | Almacenamiento de usuario en red desactivado. |
| `libSceNpManager` | 12 | *Stub Seguro (Offline)* | Estado de PSN reportado como no iniciado (`NP_SIGNED_OUT`). |
| `libSceNpScore` | 10 | *Stub Seguro (Offline)* | Marcadores en línea desactivados. |
| `libSceNpWebApi` | 7 | *Stub Seguro (Offline)* | Llamadas REST/Web de PlayStation Network desactivadas. |
| `libSceNpTrophy` | 6 | *Stub Seguro (Offline)* | Sistema de trofeos de PSN simulado en modo desconectado. |
| `libSceNpCommerce` | 5 | *Stub Seguro (Offline)* | Tienda PlayStation Store reportada como inaccesible. |
| `libSceSigninDialog` | 5 | *Stub Seguro (Offline)* | Diálogo de inicio de sesión en PSN cancelado/cerrado de inmediato. |
| `libSceNetCtl` | 5 | *Stub Seguro (Offline)* | Controlador de red reporta cable desconectado (`NET_CTL_NOT_CONNECTED`). |
| `libSceNet` | 3 | *Stub Seguro (Offline)* | Sockets de red devuelven `NET_ENETUNREACH`. |
| `libSceHttp` / `libSceSsl` | 2 | *Stub Seguro (Offline)* | Conexiones seguras devuelven error de red. |
| `libSceMsgDialog` | 5 | *Stub Seguro* | Diálogos de texto auto-aceptados de inmediato sin UI nativa. |
| `libSceSaveDataDialog`| 4 | *Stub Seguro* | Diálogos de guardado auto-completados usando la ranura por defecto. |
| `libSceErrorDialog` | 4 | *Stub Seguro* | Diálogo de error del sistema auto-descartado. |
| `libScePlayGoDialog` | 2 | *Stub Seguro* | PlayGo reporta el juego 100% instalado localmente. |
| `libSceCommonDialog` | 2 | *Stub Seguro* | Gestor de diálogos comunes inicializado en modo inmediato. |
| `libSceScreenShot` | 3 | *Stub Seguro* | Capturas de pantalla de sistema redirigidas a no-op. |
| `libSceSharePlay` | 2 | *Stub Seguro* | Función SharePlay reportada como no compatible. |
| `libSceDiscMap` | 2 | *Stub Seguro* | Mapeo de disco físico reportado como instalación completa. |
| `libSceLibcInternal` | 1 | **Contrato Funcional** | Bandera global interna requerida por `libSceFios2`. |
| `libSceLibcInternalExt`| 1 | *Stub Seguro* | Traza de depuración de heap de libc ignorada. |

---

## 4. Conclusiones de la Auditoría

1. **Cobertura de Inicio:** La totalidad de los subsistemas requeridos para la carga del binario, la decodificación de vídeo CRI Mana, el renderizado de gráficos Vulkan, el audio WASAPI/SDL3 y el bucle de eventos están cubiertos con contratos funcionales.
2. **Limitaciones Documentadas:** Las dependencias marcadas como *Stub Seguro* garantizan que el juego continúe ejecutándose sin crashear al toparse con servicios online o diálogos de consola, pero confirman que el juego opera en un entorno estrictamente **offline y monousuario**.
3. **Puntos Críticos para Fases Posteriores:** Si el juego requiere diálogos interactivos complejos durante la personalización de partidas o modos adicionales que dependan de interfaces de sistema, se requerirá implementar una capa visual de diálogos sobre la ventana del juego.
