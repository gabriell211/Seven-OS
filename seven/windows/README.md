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

Wine 11.x is the initial runtime target because it supports the completed new
WoW64 architecture and NTSYNC integration.

The current bootstrap image installs the Seven integration layer. The Wine
runtime itself will be added to the desktop userspace once the graphical
Wayland/Vulkan dependency set is part of the Seven image.

Until the runtime is installed, `seven-winexec` fails explicitly instead of
silently pretending that a Windows program was executed.

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

## Diagnostics

```sh
seven-winexec --status
seven-winexec --prefix setup.exe
seven-winexec --version
```

## Scope

This layer targets normal Win32/Win64 desktop software. Windows kernel drivers,
antivirus drivers, kernel anti-cheat components and software that requires a
real Windows NT kernel are outside the compatibility guarantee.
