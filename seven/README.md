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


## Windows application compatibility

The base image now includes the `seven-win` integration package and enables
the kernel primitives required for Windows compatibility:

- `CONFIG_NTSYNC=y`
- `CONFIG_BINFMT_MISC=y`
- `seven-winexec`
- PE/MSI `binfmt_misc` registration
- isolated per-application runtime prefixes

The Wine runtime is deliberately kept replaceable behind `seven-winexec`.
The bootstrap build is now configured for Wine 11.0's new WoW64 architecture,
with PE support for both x86_64 and i386 through a pinned LLVM-MinGW toolchain.
`seven-wininstall` is the installation entry point for `.exe` and `.msi`
packages. The current runtime is intentionally non-graphical; Wayland/Vulkan,
audio and gaming integrations will be layered on in Phase 2.

The full Wine cross-build and real executable smoke test remain part of the
end-to-end image validation milestone.

See [windows/README.md](windows/README.md).
