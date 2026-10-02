#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEVEN_DIR="$ROOT_DIR/seven"
BUILD_ROOT="${SEVEN_BUILD_DIR:-${ROOT_DIR}-build}"
KERNEL_OUT="$BUILD_ROOT/kernel"
BUILDROOT_SRC="$BUILD_ROOT/buildroot"
BUILDROOT_OUT="$BUILD_ROOT/rootfs"
BUILDROOT_VERSION="${BUILDROOT_VERSION:-2026.08}"
JOBS="${JOBS:-$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null || echo 2)}"
SEVEN_BUILD_ISO="${SEVEN_BUILD_ISO:-1}"

LLVM_MINGW_VERSION="20260922"
LLVM_MINGW_ARCHIVE="llvm-mingw-${LLVM_MINGW_VERSION}-ucrt-ubuntu-22.04-x86_64.tar.xz"
LLVM_MINGW_URL="https://github.com/mstorsjo/llvm-mingw/releases/download/${LLVM_MINGW_VERSION}/${LLVM_MINGW_ARCHIVE}"
LLVM_MINGW_SHA256="bb7bb7654b33d5aa8712acb837c963b2e0c56352560c76105270a3268c665c21"
LLVM_MINGW_DEFAULT_DIR="$BUILD_ROOT/${LLVM_MINGW_ARCHIVE%.tar.xz}"
LLVM_MINGW_DIR="${SEVEN_LLVM_MINGW_DIR:-$LLVM_MINGW_DEFAULT_DIR}"
DOWNLOAD_DIR="$BUILD_ROOT/downloads"

die() {
    echo "[Seven] $*" >&2
    exit 1
}

require() {
    command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

verify_sha256() {
    local file="$1"
    local expected="$2"
    printf '%s  %s\n' "$expected" "$file" | sha256sum -c - >/dev/null 2>&1
}

prepare_llvm_mingw() {
    if [ -n "${SEVEN_LLVM_MINGW_DIR:-}" ]; then
        echo "[Seven] Using custom LLVM-MinGW: $LLVM_MINGW_DIR"
    else
        local archive="$DOWNLOAD_DIR/$LLVM_MINGW_ARCHIVE"

        mkdir -p "$DOWNLOAD_DIR"

        if [ -f "$archive" ] && ! verify_sha256 "$archive" "$LLVM_MINGW_SHA256"; then
            echo "[Seven] Cached LLVM-MinGW checksum mismatch; downloading it again."
            rm -f "$archive"
        fi

        if [ ! -f "$archive" ]; then
            echo "[Seven] Fetching LLVM-MinGW $LLVM_MINGW_VERSION..."
            rm -f "$archive.part"
            wget -O "$archive.part" "$LLVM_MINGW_URL"
            mv "$archive.part" "$archive"
        fi

        verify_sha256 "$archive" "$LLVM_MINGW_SHA256" || {
            rm -f "$archive"
            die "LLVM-MinGW SHA-256 verification failed."
        }

        if [ ! -x "$LLVM_MINGW_DIR/bin/i686-w64-mingw32-clang" ] || \
           [ ! -x "$LLVM_MINGW_DIR/bin/x86_64-w64-mingw32-clang" ]; then
            echo "[Seven] Extracting LLVM-MinGW..."
            rm -rf "$LLVM_MINGW_DIR"
            tar -xJf "$archive" -C "$BUILD_ROOT"
        fi
    fi

    [ -x "$LLVM_MINGW_DIR/bin/i686-w64-mingw32-clang" ] || \
        die "LLVM-MinGW i686 compiler not found in $LLVM_MINGW_DIR"
    [ -x "$LLVM_MINGW_DIR/bin/x86_64-w64-mingw32-clang" ] || \
        die "LLVM-MinGW x86_64 compiler not found in $LLVM_MINGW_DIR"

    export SEVEN_LLVM_MINGW_DIR="$LLVM_MINGW_DIR"
    export PATH="$LLVM_MINGW_DIR/bin:$PATH"
}

for cmd in git make gcc g++ bc bison flex perl python3 rsync cpio gzip patch tar wget file sha256sum xz; do
    require "$cmd"
done

mkdir -p "$BUILD_ROOT" "$KERNEL_OUT" "$BUILDROOT_OUT"

echo "[Seven] Configuring kernel..."
make -C "$ROOT_DIR" O="$KERNEL_OUT" x86_64_defconfig

"$ROOT_DIR/scripts/config" --file "$KERNEL_OUT/.config" \
    -e BLK_DEV_INITRD \
    -e DEVTMPFS \
    -e DEVTMPFS_MOUNT \
    -e TMPFS \
    -e PROC_FS \
    -e SYSFS \
    -e TTY \
    -e SERIAL_8250 \
    -e SERIAL_8250_CONSOLE \
    -e UNIX \
    -e INET \
    -e PACKET \
    -e VIRTIO \
    -e VIRTIO_PCI \
    -e VIRTIO_NET \
    -e VIRTIO_BLK \
    -e VIRTIO_INPUT \
    -e INPUT_EVDEV \
    -e DRM \
    -e DRM_VIRTIO_GPU \
    -m DRM_I915 \
    -m DRM_AMDGPU \
    -m DRM_NOUVEAU \
    -e CFG80211 \
    -e MAC80211 \
    -m IWLWIFI \
    -e RFKILL \
    -e BT \
    -e BT_HCIBTUSB \
    -e SND \
    -m SND_HDA_INTEL \
    -m SND_HDA_CODEC_GENERIC \
    -m SND_HDA_CODEC_HDMI \
    -m SND_USB_AUDIO \
    -e EXT4_FS \
    -e ACPI \
    -e ACPI_AC \
    -e ACPI_BATTERY \
    -e ACPI_BUTTON \
    -e ACPI_VIDEO \
    -e CPU_FREQ \
    -e CPU_FREQ_STAT \
    -e X86_INTEL_PSTATE \
    -e X86_AMD_PSTATE \
    -e PM \
    -e SUSPEND \
    -e HIBERNATION \
    -e CGROUPS \
    -e CGROUP_PIDS \
    -e CGROUP_SCHED \
    -e CGROUP_CPUACCT \
    -e INOTIFY_USER \
    -e FHANDLE \
    -e NET_NS \
    -e USER_NS \
    -e AUTOFS_FS \
    -e TMPFS_POSIX_ACL \
    -e TMPFS_XATTR \
    -e VT \
    -e VT_CONSOLE \
    -e FRAMEBUFFER_CONSOLE \
    -e BINFMT_SCRIPT \
    -e BINFMT_MISC \
    -e NTSYNC

make -C "$ROOT_DIR" O="$KERNEL_OUT" olddefconfig

for required in \
    CONFIG_BINFMT_MISC=y \
    CONFIG_NTSYNC=y \
    CONFIG_DRM=y \
    CONFIG_DRM_VIRTIO_GPU=y \
    CONFIG_CGROUPS=y \
    CONFIG_INOTIFY_USER=y \
    CONFIG_FHANDLE=y \
    CONFIG_VIRTIO_INPUT=y; do
    grep -qx "$required" "$KERNEL_OUT/.config" || \
        die "Required kernel feature missing: $required"
done

echo "[Seven] Building Seven Kernel and modules..."
make -C "$ROOT_DIR" O="$KERNEL_OUT" -j"$JOBS" bzImage modules

if [ ! -d "$BUILDROOT_SRC/.git" ]; then
    echo "[Seven] Fetching Buildroot $BUILDROOT_VERSION..."
    git clone --depth 1 --branch "$BUILDROOT_VERSION" \
        https://github.com/buildroot/buildroot.git "$BUILDROOT_SRC"
else
    echo "[Seven] Using existing Buildroot checkout."
fi

prepare_llvm_mingw

echo "[Seven] Enabling Wine 11 new WoW64 support..."
python3 "$SEVEN_DIR/scripts/patch-buildroot-wine.py" "$BUILDROOT_SRC"

echo "[Seven] Configuring Seven userspace..."
make -C "$BUILDROOT_SRC" \
    O="$BUILDROOT_OUT" \
    BR2_EXTERNAL="$SEVEN_DIR" \
    seven_x86_64_defconfig

for required in \
    BR2_PACKAGE_SEVEN_WIN=y \
    BR2_PACKAGE_WINE=y \
    BR2_PACKAGE_SEVEN_DESKTOP=y \
    BR2_PACKAGE_SEVEN_CORE_APPS=y \
    BR2_PACKAGE_FOOT=y \
    BR2_PACKAGE_NETWORK_MANAGER=y \
    BR2_PACKAGE_BLUEZ5_UTILS=y \
    BR2_PACKAGE_PIPEWIRE=y \
    BR2_PACKAGE_WIREPLUMBER=y \
    BR2_PACKAGE_KMOD_TOOLS=y \
    BR2_PACKAGE_QT6WAYLAND_COMPOSITOR=y \
    BR2_INIT_SYSTEMD=y \
    BR2_TARGET_GRUB2_X86_64_EFI=y \
    BR2_TARGET_ROOTFS_EXT2_4=y; do
    grep -qx "$required" "$BUILDROOT_OUT/.config" || \
        die "Required userspace feature missing: $required"
done

echo "[Seven] Building Seven userspace..."
make -C "$BUILDROOT_SRC" O="$BUILDROOT_OUT" -j"$JOBS"

echo "[Seven] Installing Seven Kernel into rootfs..."
install -D -m 0644 "$KERNEL_OUT/arch/x86/boot/bzImage" \
    "$BUILDROOT_OUT/target/boot/seven-kernel"

echo "[Seven] Installing Seven Kernel modules into rootfs..."
make -C "$ROOT_DIR" O="$KERNEL_OUT" \
    INSTALL_MOD_PATH="$BUILDROOT_OUT/target" \
    DEPMOD=true \
    modules_install

echo "[Seven] Building host depmod..."
make -C "$BUILDROOT_SRC" O="$BUILDROOT_OUT" host-kmod

KERNEL_RELEASE="$(make -s -C "$ROOT_DIR" O="$KERNEL_OUT" kernelrelease)"
DEPMOD=""
for candidate in \
    "$BUILDROOT_OUT/host/sbin/depmod" \
    "$BUILDROOT_OUT/host/bin/depmod"; do
    if [ -x "$candidate" ]; then
        DEPMOD="$candidate"
        break
    fi
done

[ -n "$DEPMOD" ] || die "Buildroot host depmod was not generated."

echo "[Seven] Generating module dependency database for $KERNEL_RELEASE..."
"$DEPMOD" -b "$BUILDROOT_OUT/target" "$KERNEL_RELEASE"

echo "[Seven] Regenerating root filesystems with Seven Kernel modules..."
make -C "$BUILDROOT_SRC" O="$BUILDROOT_OUT" rootfs-cpio rootfs-ext2

for required_file in \
    "$BUILDROOT_OUT/target/usr/bin/wine" \
    "$BUILDROOT_OUT/target/usr/bin/seven-winexec" \
    "$BUILDROOT_OUT/target/usr/bin/seven-wininstall" \
    "$BUILDROOT_OUT/target/usr/bin/seven-desktop" \
    "$BUILDROOT_OUT/target/usr/bin/seven-files" \
    "$BUILDROOT_OUT/target/usr/bin/seven-settings" \
    "$BUILDROOT_OUT/target/usr/bin/seven-monitor" \
    "$BUILDROOT_OUT/target/usr/bin/seven-store" \
    "$BUILDROOT_OUT/target/usr/bin/seven-terminal" \
    "$BUILDROOT_OUT/target/usr/bin/seven-install" \
    "$BUILDROOT_OUT/target/usr/lib/systemd/system/seven-desktop.service" \
    "$BUILDROOT_OUT/target/usr/lib/systemd/system/seven-pipewire.service" \
    "$BUILDROOT_OUT/target/usr/lib/systemd/system/seven-wireplumber.service"; do
    if [[ "$required_file" == *.service ]]; then
        [ -f "$required_file" ] || die "Required systemd unit missing: $required_file"
    else
        [ -x "$required_file" ] || die "Required runtime file missing: $required_file"
    fi
done

echo "[Seven] Creating UEFI/GPT system image..."
bash "$SEVEN_DIR/scripts/create-uefi-image.sh" \
    "$BUILDROOT_OUT" \
    "$KERNEL_OUT/arch/x86/boot/bzImage" \
    "$SEVEN_DIR"

IMAGES="$BUILD_ROOT/images"
mkdir -p "$IMAGES"

cp "$KERNEL_OUT/arch/x86/boot/bzImage" "$IMAGES/seven-kernel"
cp "$BUILDROOT_OUT/images/rootfs.cpio.gz" "$IMAGES/seven-initramfs.cpio.gz"
cp "$BUILDROOT_OUT/images/rootfs.ext2" "$IMAGES/rootfs.ext2"
cp "$BUILDROOT_OUT/images/seven-os.img" "$IMAGES/seven-os.img"

if [ "$SEVEN_BUILD_ISO" = "1" ]; then
    echo "[Seven] Creating self-contained Live ISO..."
    bash "$SEVEN_DIR/make-iso.sh"
fi

echo
echo "Seven OS artifacts:"
echo "  Kernel:     $IMAGES/seven-kernel"
echo "  Initramfs:  $IMAGES/seven-initramfs.cpio.gz"
echo "  Root FS:    $IMAGES/rootfs.ext2"
echo "  UEFI image: $IMAGES/seven-os.img"
if [ "$SEVEN_BUILD_ISO" = "1" ]; then
    echo "  Live ISO:   $IMAGES/seven-os-live.iso"
fi
echo
echo "Windows compatibility:"
echo "  Wine:       $BUILDROOT_OUT/target/usr/bin/wine"
echo "  WinExec:    $BUILDROOT_OUT/target/usr/bin/seven-winexec"
echo "  WinInstall: $BUILDROOT_OUT/target/usr/bin/seven-wininstall"
echo "Desktop:"
echo "  Desktop:    $BUILDROOT_OUT/target/usr/bin/seven-desktop"
echo
echo "Run:"
echo "  Console: bash seven/run-qemu.sh --serial"
echo "  Desktop: bash seven/run-qemu-gui.sh"
echo "  UEFI:    bash seven/run-qemu-uefi.sh"
