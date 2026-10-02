#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
KERNEL="$BUILD_ROOT/images/seven-kernel"
INITRAMFS="$BUILD_ROOT/images/seven-initramfs.cpio.gz"

command -v qemu-system-x86_64 >/dev/null 2>&1 || {
    echo "qemu-system-x86_64 is required." >&2
    exit 1
}

[ -f "$KERNEL" ] || {
    echo "Seven kernel not found. Run: bash seven/build.sh" >&2
    exit 1
}

[ -f "$INITRAMFS" ] || {
    echo "Seven initramfs not found. Run: bash seven/build.sh" >&2
    exit 1
}

KVM_ARGS=()
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_ARGS=(-enable-kvm -cpu host)
fi

exec qemu-system-x86_64     "${KVM_ARGS[@]}"     -m 2048     -smp 2     -kernel "$KERNEL"     -initrd "$INITRAMFS"     -append "console=ttyS0 rdinit=/sbin/init"     -nic user,model=e1000     -nographic     -no-reboot
