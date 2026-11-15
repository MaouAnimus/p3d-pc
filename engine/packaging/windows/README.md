# Persona 3: Dancing in Moonlight — Windows Packaging & Build

The compatibility runtime builds and runs natively on 64-bit Windows 10 (1903+) / 11 using MSYS2 with the Clang64 toolchain.

## Build Requirements

Install [MSYS2](https://www.msys2.org) (`winget install MSYS2.MSYS2`), open the **MSYS2 CLANG64** shell, and install the required dependencies:

```bash
pacman -S --needed git patch \
  mingw-w64-clang-x86_64-{toolchain,cmake,ninja,pkgconf,python} \
  mingw-w64-clang-x86_64-{vulkan-headers,vulkan-loader,vulkan-memory-allocator,glslang} \
  mingw-w64-clang-x86_64-{sdl3,fmt,boost,robin-map,xxhash,ffmpeg,zydis} \
  mingw-w64-clang-x86_64-{spirv-tools,spirv-headers,spirv-cross}
```

Third-party dependencies (`magic_enum`, `miniz`, `xbyak`) are located under `gpu/third_party/`.

## Compiling the Runtime

From an MSYS2 CLANG64 shell in the project root:

```bash
ninja -C engine/out/gpu p3d
```

This compiles the main compatibility binary:
- `engine/out/gpu/p3d.exe` (deployed to root as `p3d.exe` and `bin/p3d_engine.exe`).

## Standalone Executables & Launcher

The repository provides two dedicated Windows entry points:
- **`p3d_launcher.exe`:** Modern GUI settings interface (Qt / PySide6) for display mode, resolution, anisotropic filtering, and audio settings.
- **`Jugar.exe`:** Direct launch executable that starts the game immediately with the parameters saved in `p3d.ini`.

To rebuild the launcher executables:
```powershell
powershell -ExecutionPolicy Bypass -File tools/build_launchers.ps1
```

## ISA Rewrite for Legacy Processors

For processors without native support for the `MOVBE` instruction (such as older AMD FX or Kaveri/Steamroller APUs), an ISA rewrite table (`isa-rewrite.bin`) is provided to patch instructions into fast native jumps (`JMP`) in executable memory without relying on CPU exceptions or kernel traps.
