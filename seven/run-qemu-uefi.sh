#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
IMAGE="$BUILD_ROOT/images/seven-os.img"

command -v qemu-system-x86_64 >/dev/null 2>&1 || {
    echo "qemu-system-x86_64 is required." >&2
    exit 1
}

[ -f "$IMAGE" ] || {
    echo "Seven UEFI image not found. Run: bash seven/build.sh" >&2
    exit 1
}

OVMF="${OVMF_CODE:-}"
if [ -z "$OVMF" ]; then
    for candidate in         /usr/share/OVMF/OVMF_CODE.fd         /usr/share/edk2/x64/OVMF_CODE.fd         /usr/share/edk2/ovmf/OVMF_CODE.fd; do
        if [ -f "$candidate" ]; then
            OVMF="$candidate"
            break
        fi
    done
fi

[ -n "$OVMF" ] && [ -f "$OVMF" ] || {
    echo "OVMF firmware not found. Set OVMF_CODE=/path/to/OVMF_CODE.fd" >&2
    exit 1
}

KVM_ARGS=()
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_ARGS=(-enable-kvm -cpu host)
fi

exec qemu-system-x86_64     "${KVM_ARGS[@]}"     -m 4096     -smp 4     -drive "if=pflash,format=raw,readonly=on,file=$OVMF"     -drive "file=$IMAGE,format=raw,if=virtio"     -device virtio-vga     -device qemu-xhci     -device usb-tablet     -nic user,model=virtio-net-pci     -no-reboot
