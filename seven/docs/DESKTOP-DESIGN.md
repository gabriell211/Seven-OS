# Seven Desktop visual specification

The current Seven Desktop direction is based on the approved Seven OS reference
layout supplied during development.

## Branding contract

- The product name is **Seven OS**.
- The shell logo must render **SEVEN OS**, never **SEVEN ON**.
- Search placeholders, About/System pages, boot UI, installer and recovery must use **Seven OS** consistently.
- The visual reference may show an older **Seven On** label; that label is intentionally replaced by **Seven OS** in the implementation.

## Core composition

- persistent left navigation rail;
- thin system status bar across the top;
- large desktop/home workspace in the center;
- contextual widgets on the right;
- floating centered dock on the bottom;
- dark translucent panels;
- blue/cyan primary glow with restrained violet accents;
- rounded corners and thin luminous borders;
- application windows live inside the Wayland compositor, not inside a web UI.

## Layout contract

At 1536×864 the reference proportions are approximately:

- left rail: 164 px;
- top bar: 48 px;
- right rail: 248 px;
- dock: 590×66 px;
- central application area reserves all four shell regions.

All measurements scale with the physical output. The desktop must remain usable
at 1280×720 and scale cleanly to 4K.

## UX principles

1. Seven OS must look recognizably different from Windows, macOS and stock
   Linux desktop environments.
2. Glass effects are decorative and must never reduce text contrast.
3. Core controls must remain keyboard accessible.
4. System information shown in the UI must come from real system state.
5. Unimplemented applications must report that they are unavailable instead of
   presenting fake data.
6. Native Seven applications and Windows applications share the same compositor
   and launcher model.

## Implementation

The shell is implemented with Qt Quick and Qt Wayland Compositor.

The compositor owns the Wayland display and creates real `ShellSurfaceItem`
instances for connected xdg-shell clients. The sidebar, dock, status bar and
widgets are compositor-level UI rendered above the wallpaper and outside the
reserved client work area.
