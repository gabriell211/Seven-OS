#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -ne 3 ]; then
    echo "usage: create-uefi-image.sh <buildroot-output> <seven-kernel> <seven-dir>" >&2
    exit 2
fi

BUILDROOT_OUT="$(cd "$1" && pwd)"
KERNEL="$(readlink -f "$2")"
SEVEN_DIR="$(cd "$3" && pwd)"
IMAGES="$BUILDROOT_OUT/images"
HOST="$BUILDROOT_OUT/host"
TMP="$BUILDROOT_OUT/genimage.tmp"

[ -x "$HOST/bin/genimage" ] || {
    echo "genimage was not built." >&2
    exit 1
}

[ -f "$IMAGES/rootfs.ext2" ] || {
    echo "rootfs.ext2 was not generated." >&2
    exit 1
}

[ -f "$IMAGES/efi-part/EFI/BOOT/bootx64.efi" ] || {
    echo "GRUB EFI image was not generated." >&2
    exit 1
}

cp "$KERNEL" "$IMAGES/seven-kernel"
cp "$SEVEN_DIR/board/seven/grub-efi.cfg" "$IMAGES/efi-part/EFI/BOOT/grub.cfg"

rm -rf "$TMP"
rm -f "$IMAGES/seven-efi.vfat" "$IMAGES/seven-os.img"

"$HOST/bin/genimage"     --rootpath "$BUILDROOT_OUT/target"     --tmppath "$TMP"     --inputpath "$IMAGES"     --outputpath "$IMAGES"     --config "$SEVEN_DIR/board/seven/genimage-efi.cfg"

[ -f "$IMAGES/seven-os.img" ] || {
    echo "Seven UEFI disk image was not generated." >&2
    exit 1
}

echo "[Seven] UEFI disk image: $IMAGES/seven-os.img"
