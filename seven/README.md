# Seven OS system layer

The Linux-derived kernel lives at the repository root and is the Seven Kernel.

This directory contains the Seven-specific system layer that does not belong inside the kernel itself: userspace identity, root filesystem overlays, reproducible image configuration, and boot tooling.

## First milestone

The current milestone builds:

- the Seven Kernel directly from this repository;
- a minimal x86_64 userspace;
- BusyBox init and core utilities through Buildroot;
- a Seven-branded root filesystem;
- an initramfs image;
- a QEMU-bootable Seven OS developer environment.

Buildroot is used only to produce the initial userspace/toolchain/root filesystem. It does not replace the kernel in this repository.

## Build

On a Linux development host with the standard kernel and Buildroot dependencies installed:

```bash
bash seven/build.sh
```

Artifacts are written outside the source tree by default:

```text
../Seven-OS-build/images/seven-kernel
../Seven-OS-build/images/seven-initramfs.cpio.gz
```

Boot the result with:

```bash
bash seven/run-qemu.sh
```

The first boot target is intentionally small. Desktop graphics, Wayland, audio, NetworkManager, package management, installer, recovery and the Seven Desktop will be layered onto this reproducible base.
