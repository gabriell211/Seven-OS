#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
KERNEL="$BUILD_ROOT/images/seven-kernel"
INITRAMFS="$BUILD_ROOT/images/seven-initramfs.cpio.gz"
MODE="${1:-desktop}"
DISPLAY_BACKEND="${SEVEN_QEMU_DISPLAY:-gtk}"

die() {
    echo "[Seven] $*" >&2
    exit 1
}

command -v qemu-system-x86_64 >/dev/null 2>&1 || die "qemu-system-x86_64 is required."
[ -f "$KERNEL" ] || die "Seven kernel not found. Run: bash seven/build.sh"
[ -f "$INITRAMFS" ] || die "Seven initramfs not found. Run: bash seven/build.sh"

KVM_ARGS=()
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_ARGS=(-enable-kvm -cpu host)
fi

COMMON_ARGS=(
    "${KVM_ARGS[@]}"
    -m 4096
    -smp 4
    -kernel "$KERNEL"
    -initrd "$INITRAMFS"
    -append "console=tty0 console=ttyS0 rdinit=/sbin/init"
    -nic user,model=virtio-net-pci
    -device virtio-keyboard-pci
    -device virtio-tablet-pci
    -no-reboot
)

case "$MODE" in
    desktop|"")
        exec qemu-system-x86_64             "${COMMON_ARGS[@]}"             -device virtio-vga-gl             -display "$DISPLAY_BACKEND,gl=on"             -serial mon:stdio
        ;;
    --software|software)
        exec qemu-system-x86_64             "${COMMON_ARGS[@]}"             -device virtio-vga             -display "$DISPLAY_BACKEND"             -serial mon:stdio
        ;;
    --serial|serial)
        exec qemu-system-x86_64             "${COMMON_ARGS[@]}"             -display none             -nographic
        ;;
    *)
        cat >&2 <<'EOF'
Usage:
  bash seven/run-qemu.sh
  bash seven/run-qemu.sh --software
  bash seven/run-qemu.sh --serial

Environment:
  SEVEN_QEMU_DISPLAY=gtk|sdl|...
EOF
        exit 2
        ;;
esac
