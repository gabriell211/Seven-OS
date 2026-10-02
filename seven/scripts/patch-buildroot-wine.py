#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys


def fail(message: str) -> None:
    print(f"[Seven] Buildroot Wine patch failed: {message}", file=sys.stderr)
    raise SystemExit(1)


def patch_config(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")

    if "depends on BR2_i386 || BR2_x86_64" in text:
        return False

    needle = "depends on BR2_i386\n"
    if needle not in text:
        fail(f"unexpected Wine Config.in format: {path}")

    text = text.replace(
        needle,
        "depends on BR2_i386 || BR2_x86_64\n",
        1,
    )
    path.write_text(text, encoding="utf-8")
    return True


def patch_makefile(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    marker = "# Seven OS: enable 64-bit Wine target for the new WoW64 architecture."

    if marker in text:
        return False

    disable_line = "\t--disable-win64 \\\n"
    if disable_line not in text:
        fail(f"expected --disable-win64 option not found: {path}")

    text = text.replace(disable_line, "", 1)

    eval_line = "$(eval $(autotools-package))"
    if eval_line not in text:
        fail(f"autotools package marker not found: {path}")

    block = f"""
{marker}
ifeq ($(BR2_x86_64),y)
WINE_CONF_OPTS += --enable-win64
else
WINE_CONF_OPTS += --disable-win64
endif

"""

    text = text.replace(eval_line, block + eval_line, 1)
    path.write_text(text, encoding="utf-8")
    return True


def main() -> int:
    if len(sys.argv) != 2:
        print(
            "usage: patch-buildroot-wine.py <buildroot-source>",
            file=sys.stderr,
        )
        return 2

    root = Path(sys.argv[1]).resolve()
    config = root / "package" / "wine" / "Config.in"
    makefile = root / "package" / "wine" / "wine.mk"

    if not config.is_file() or not makefile.is_file():
        fail("Wine package was not found in the selected Buildroot tree")

    config_changed = patch_config(config)
    makefile_changed = patch_makefile(makefile)

    if config_changed or makefile_changed:
        print("[Seven] Buildroot Wine package patched for x86_64/WoW64.")
    else:
        print("[Seven] Buildroot Wine package already supports Seven x86_64.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
