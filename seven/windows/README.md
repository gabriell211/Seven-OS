# Seven Windows Compatibility

Seven OS supports a Windows compatibility architecture in userspace instead of
placing the Windows ABI inside the Seven Kernel.

## Components

`seven-winexec` is the stable entry point for Windows applications. It:

- accepts `.exe` and `.msi` files;
- routes MSI packages through `msiexec`;
- creates an isolated Wine prefix for each application/installer path;
- allows the desktop launcher to reuse an existing prefix through
  `SEVEN_WINDOWS_PREFIX`;
- keeps Wine menu generation disabled so Seven Desktop owns application
  integration;
- exposes `--status`, `--prefix` and `--version` diagnostics.

At boot, `S40seven-win` mounts `binfmt_misc` and registers handlers for PE
executables and MSI packages.

## Kernel support

The Seven kernel build enables:

```text
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=y
CONFIG_NTSYNC=y
```

`NTSYNC` provides kernel primitives that a compatible Wine runtime can use to
implement Windows NT synchronization more efficiently.

## Runtime

The compatibility entry point is intentionally separated from the Wine
runtime. This keeps the Seven interface stable while allowing the runtime to be
upgraded independently.

Seven currently targets **Wine 11.0**. Buildroot 2026.08 ships Wine 11.0 but
normally restricts its target package to i386. During the Seven build,
`scripts/patch-buildroot-wine.py` applies a narrow, version-aware adjustment
that enables the package for the Seven x86_64 target and configures Wine's new
WoW64 build with:

```text
--enable-archs=x86_64,i386
--with-mingw=llvm-mingw
```

The build downloads a pinned LLVM-MinGW 20260922 UCRT toolchain, validates its
SHA-256, and exposes both the i686 and x86_64 PE compilers to Wine. This lets a
64-bit Seven userspace build the PE components needed for both Win32 and Win64
applications without requiring a 32-bit Seven userspace.

The resulting image is required to contain `/usr/bin/wine`,
`/usr/bin/seven-winexec` and `/usr/bin/seven-wininstall`. The build aborts
if any of them is missing.

This is the initial non-graphical runtime foundation. Wayland, Vulkan, audio,
fonts and gaming-specific integrations will be enabled as the Seven Desktop
stack is added.

## Prefix layout

By default:

```text
~/.local/share/seven/windows/apps/
└── <application>-<path-id>/
    ├── drive_c/
    ├── dosdevices/
    ├── system.reg
    ├── user.reg
    └── userdef.reg
```

A Seven Desktop launcher can bind an installed application to an existing
prefix:

```sh
SEVEN_WINDOWS_PREFIX="$HOME/.local/share/seven/windows/apps/example" \
  seven-winexec "/path/to/program.exe"
```

This prevents one Windows application's registry and dependencies from
corrupting another application's environment.

## Usage

```sh
# Install Windows software
seven-wininstall setup.exe
seven-wininstall package.msi

# Execute a Windows application
seven-winexec application.exe

# Inspect compatibility status and prefix selection
seven-winexec --status
seven-winexec --prefix setup.exe
seven-winexec --version
```

## Scope

This layer targets normal Win32/Win64 desktop software. Windows kernel drivers,
antivirus drivers, kernel anti-cheat components and software that requires a
real Windows NT kernel are outside the compatibility guarantee.
