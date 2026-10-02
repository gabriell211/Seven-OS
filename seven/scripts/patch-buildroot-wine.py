#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys


CURRENT_MARKER = "# Seven OS: Wine 11 new WoW64 x86_64/i386 integration v2."
PREVIOUS_MARKER = "# Seven OS: enable Wine 11 new WoW64 on the x86_64 target."
FIRST_MARKER = "# Seven OS: enable 64-bit Wine target for the new WoW64 architecture."

CURRENT_BLOCK = f"""{CURRENT_MARKER}
ifeq ($(BR2_x86_64),y)
WINE_CONF_ENV += PATH="$(SEVEN_LLVM_MINGW_DIR)/bin:$(BR_PATH)"
WINE_CONF_OPTS += --enable-archs=x86_64,i386 --with-mingw=llvm-mingw
else
WINE_CONF_OPTS += --disable-win64 --without-mingw
endif

"""

PREVIOUS_BLOCK = f"""{PREVIOUS_MARKER}
ifeq ($(BR2_x86_64),y)
WINE_CONF_OPTS += --enable-archs=x86_64,i386 --with-mingw=llvm-mingw
else
WINE_CONF_OPTS += --disable-win64 --without-mingw
endif

"""

FIRST_BLOCK = f"""{FIRST_MARKER}
ifeq ($(BR2_x86_64),y)
WINE_CONF_OPTS += --enable-win64
else
WINE_CONF_OPTS += --disable-win64
endif

"""


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

    if CURRENT_MARKER in text:
        return False

    if PREVIOUS_MARKER in text:
        if PREVIOUS_BLOCK not in text:
            fail(f"previous Seven Wine patch has unexpected shape: {path}")
        text = text.replace(PREVIOUS_BLOCK, CURRENT_BLOCK, 1)
        path.write_text(text, encoding="utf-8")
        return True

    # Migrate the first Seven prototype, which still left the target
    # --without-mingw option in WINE_CONF_OPTS.
    if FIRST_MARKER in text:
        if FIRST_BLOCK not in text:
            fail(f"first Seven Wine patch has unexpected shape: {path}")

        target_without_mingw = "\t--without-mingw \\\n"
        if target_without_mingw not in text:
            fail(f"target --without-mingw option not found during migration: {path}")

        text = text.replace(target_without_mingw, "", 1)
        text = text.replace(FIRST_BLOCK, CURRENT_BLOCK, 1)
        path.write_text(text, encoding="utf-8")
        return True

    disable_win64 = "\t--disable-win64 \\\n"
    without_mingw = "\t--without-mingw \\\n"

    if disable_win64 not in text:
        fail(f"expected --disable-win64 option not found: {path}")
    if without_mingw not in text:
        fail(f"expected --without-mingw option not found: {path}")

    # Remove only the target Wine options. HOST_WINE_CONF_OPTS has its own
    # --without-mingw later in the file and must remain untouched.
    text = text.replace(disable_win64, "", 1)
    text = text.replace(without_mingw, "", 1)

    eval_line = "$(eval $(autotools-package))"
    if eval_line not in text:
        fail(f"autotools package marker not found: {path}")

    text = text.replace(eval_line, CURRENT_BLOCK + eval_line, 1)
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
        print("[Seven] Buildroot Wine package patched for x86_64 new WoW64.")
    else:
        print("[Seven] Buildroot Wine package already supports Seven new WoW64.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
