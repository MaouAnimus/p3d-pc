# Persona 3: Dancing in Moonlight — PC Compatibility Runtime

[![Platform](https://img.shields.io/badge/Platform-Windows%20x64-blue.svg)](https://microsoft.com/windows)
[![API](https://img.shields.io/badge/Graphics-Vulkan%201.3-red.svg)](https://www.vulkan.org/)
[![License](https://img.shields.io/badge/License-GPL--2.0-green.svg)](LICENSE)
[![Audio](https://img.shields.io/badge/Audio-SDL3%20Streams-purple.svg)]()
[![Input](https://img.shields.io/badge/Input-SDL3%20Gamepad-orange.svg)]()

<a href="https://recomplauncher.com"><picture><source media="(prefers-color-scheme: dark)" srcset="https://recomplauncher.com/assets/press/launcher/badge-light.svg"><img alt="Get it on RecompLauncher" src="https://recomplauncher.com/assets/press/launcher/badge-dark.svg" height="48"></picture></a>

Runtime experimental de compatibilidad para Windows x64 de ***Persona 3: Dancing in Moonlight*** (`CUSA12636`).

El proyecto combina la **ejecución directa de código de máquina huésped x86-64 en la CPU del PC** con una **capa de compatibilidad de servicios de sistema PS4 a nivel de host** y la **traducción dinámica de comandos de GPU GNM a Vulkan 1.3**.

> **English Summary:**  
> `p3d-pc` is an experimental Windows x64 compatibility runtime for *Persona 3: Dancing in Moonlight* (PS4, Title ID `CUSA12636`). It explores direct execution of the original PS4 x86-64 machine code on host CPUs, paired with host-side implementations of selected PlayStation 4 system services and translation of GNM/PM4 graphics commands to Vulkan 1.3. Requires user-provided game files.

---

## 🔬 Estado Experimental y Alcance del Runtime

Este proyecto se encuentra en **desarrollo activo**. La compatibilidad es parcial y depende de los contratos de servicios implementados, la CPU del host y el controlador Vulkan:

- **Ejecución directa de código huésped:** Las instrucciones x86-64 del juego corren de forma nativa sobre la CPU host (Intel/AMD). No es un emulador de CPU interpretado ni JIT, pero sí requiere adaptación de ABI, manejo de TLS, emulación de llamadas al sistema y, en CPUs sin instrucción `MOVBE` (como AMD Kaveri/Steamroller), reescritura estática de instrucciones mediante tablas ISA (`isa-rewrite.bin`).
- **Servicios de sistema intencionalmente acotados:**
  - **Entorno offline y monousuario:** Se emula un único usuario local (`User ID 1`). La red (`NetCtl`) se reporta como desconectada y PlayStation Network (`PSN`) como no iniciada.
  - **Diálogos de sistema:** Diálogos comunes (`libSceMsgDialog`, `libSceSaveDataDialog`) se resuelven con contratos automáticos inmediatos; no se dibuja la interfaz gráfica de usuario del sistema operativo de PS4.
  - **Contenido y PlayGo:** El proveedor de `AppContent` opera en perfil offline del juego base; no se implementa montaje dinámico de DLC comerciales ni descargas.
- **Gráficos Vulkan 1.3:** Traductor de comandos de GPU Liverpool (GNM/PM4) a Vulkan con soporte de sombreadores cel-shading y renderizado dinámico (`VK_KHR_dynamic_rendering`).
- **Audio y Entrada sobre SDL3:**
  - `libSceAudioOut` implementado sobre streams de audio de **SDL3** (remuestreo estéreo flotante a 48 kHz con control de cola).
  - `libScePad` implementado sobre el subsistema de mandos de **SDL3** (PlayStation, Xbox, DirectInput) con mapeo alternativo en teclado.

---

## 🏛️ Estructura del Repositorio: Separación de Proyectos

El repositorio alberga dos líneas de trabajo que no deben confundirse:

1. **Línea Principal — Runtime de Compatibilidad (`engine/` / `p3d.exe`):**  
   El motor principal. Carga el ejecutable original de PS4 `CUSA12636` (`eboot.bin` -> `boot-linked.bin`), enlaza las dependencias dinámicas por NID (`link_modules.py`), implementa las APIs del sistema en `engine/src/runtime.c` y traduce el flujo de comandos gráficos a Vulkan 1.3.
2. **Línea Secundaria — Recreación Arcade Nativa (`native/`):**  
   Proyecto histórico de investigación desarrollado en C++20 y Direct3D 11. No ejecuta el ejecutable de PS4, sino que recrea la mecánica rítmica de la canción "Burn My Dread" utilizando los modelos 3D y pistas de audio previamente extraídos de los paquetes CPK.

---

## 🎮 Controles

### Modo Diálogo / Menús / Historia
| Acción | Teclado | Mando (PlayStation / Xbox) |
| :--- | :--- | :--- |
| **Avanzar Diálogo / Aceptar** | <kbd>Enter</kbd> / <kbd>X</kbd> / <kbd>K</kbd> / <kbd>↓</kbd> | Cruz / <kbd>A</kbd> |
| **Cancelar / Volver** | <kbd>Backspace</kbd> / <kbd>Z</kbd> / <kbd>L</kbd> | Círculo / <kbd>B</kbd> |
| **Modo Automático** | <kbd>I</kbd> / <kbd>↑</kbd> | Triángulo / <kbd>Y</kbd> |
| **Saltar / Acelerar Diálogo** | <kbd>E</kbd> / <kbd>3</kbd> | <kbd>R1</kbd> |

### Modo Ritmo (Gameplay de Baile)
| Acción | Teclado | Mando (PlayStation / Xbox) |
| :--- | :--- | :--- |
| **Notas Izquierda (Arriba / Izq / Abajo)** | <kbd>W</kbd>, <kbd>A</kbd>, <kbd>S</kbd> | D-Pad (<kbd>↑</kbd>, <kbd>←</kbd>, <kbd>↓</kbd>) |
| **Notas Derecha (Arriba / Der / Abajo)** | <kbd>I</kbd>, <kbd>L</kbd>, <kbd>K</kbd> o Flechas | Triángulo, Círculo, Cruz (<kbd>Y</kbd>, <kbd>B</kbd>, <kbd>A</kbd>) |
| **Scratch / Anillo Fever** | <kbd>Espacio</kbd> / <kbd>Shift</kbd> | <kbd>L1</kbd> / <kbd>R1</kbd> o Sticks analógicos |
| **Pausa** | <kbd>Escape</kbd> / <kbd>P</kbd> | Options / Start |

---

## 📦 Instrucciones de Instalación y Uso (BYOG)

> [!IMPORTANT]  
> Este repositorio **NO** distribuye código con derechos de autor, imágenes de disco, binarios propietarios ni assets comerciales de Atlus o SEGA. Se requiere que el usuario aporte su propia copia legítima del juego de PS4 (*Bring Your Own Game*).

### 1. Clonar el Repositorio
```bash
git clone https://github.com/MaouAnimus/p3d-pc.git
cd p3d-pc
```

### 2. Aportar los Archivos del Juego
Coloca tu volcado de PS4 en la carpeta raíz del proyecto bajo el nombre `CUSA12636`:
```
p3d-pc/
├── CUSA12636/
│   ├── eboot.bin
│   ├── data/
│   │   ├── data.cpk
│   │   └── ps4.cpk
│   └── sce_sys/
├── p3d_launcher.exe
├── Jugar.exe
└── ...
```

### 3. Iniciar el Juego y Configuración
El flujo de usuario opera exclusivamente a través de ejecutables nativos:
- **Launcher con Interfaz Gráfica (Recomendado):** Haz doble clic en [`p3d_launcher.exe`](p3d_launcher.exe) para abrir la interfaz, ajustar opciones de vídeo/controles y pulsar **▶ JUGAR**. (Requiere Python 3.10+ con PySide6 en el entorno host; conserva los scripts auxiliares `p3d_launcher.py`, `p3d_launcher.pyw`, `p3d_settings.py` y `design/launcher/`).
- **Jugar con Ajustes Guardados:** Haz doble clic en [`Jugar.exe`](Jugar.exe) para iniciar de forma directa e inmediata con la configuración de [`p3d.ini`](p3d.ini), sin abrir la interfaz gráfica.
- **Línea de Comandos / RecompLauncher:** Admite el parámetro `--game <ruta>` o `--app0 <ruta>` y `--play` para integrarse con lanzadores externos.

### 4. Ajustes Gráficos y Limitador de Tasa de Cuadros
- Los ajustes se guardan en [`p3d.ini`](p3d.ini) con **Guardar ajustes** o al iniciar el juego.
- La resolución interna de renderizado de Persona 3 Dancing es nativa a **1080p (1920×1080)**.
- El reloj de sincronización se mantiene a **60 Hz** (con selector de 60 FPS y límite reducido de 30 FPS). Desbloquear la tasa de cuadros global altera la velocidad del juego y las secuencias introductorias; tasas mayores (120/144 FPS) requerirán desacoplar el bucle de simulación rítmica del bucle de renderizado.

---

## 📚 Documentación Técnica y Auditorías

- [Diario de Trabajo de Ingeniería Inversa (Worklog)](docs/worklog.md)
- [Matriz de Imports y Servicios del Huésped CUSA12636](docs/cusa12636-import-matrix.md)
- [Auditoría del Launcher y Ajustes de Rendimiento](docs/launcher-settings-audit.md)

---

## ⚖️ Aviso Legal

Este proyecto es una investigación independiente de código limpio (*clean-room engineering*) con fines de preservación digital e interoperabilidad de software sobre la arquitectura x86-64 y la API Vulkan.

*Persona*, *Persona 3: Dancing in Moonlight*, sus personajes, marcas registradas, diálogos, cinemáticas y bandas sonoras son propiedad intelectual exclusiva de **ATLUS / SEGA**. Este proyecto no está respaldado, asociado ni autorizado por ATLUS ni SEGA.
