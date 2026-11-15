#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import os
import traceback
from pathlib import Path

def _show_fatal_error(msg: str):
    log_path = Path(__file__).resolve().parent / "launcher_crash.log"
    try:
        with open(log_path, "w", encoding="utf-8") as f:
            f.write(msg)
    except Exception:
        pass
    if sys.platform == "win32":
        try:
            import ctypes
            ctypes.windll.user32.MessageBoxW(0, msg, "Persona 3 Dancing - Error en Launcher", 0x10)
        except Exception:
            pass

sys.path.insert(0, str(Path(__file__).resolve().parent))

if __name__ == "__main__":
    try:
        from p3d_launcher import main
        main()
    except Exception as e:
        _show_fatal_error(f"Error fatal al iniciar el launcher:\n\n{traceback.format_exc()}")
        sys.exit(1)
