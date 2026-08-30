# Omarchy X3D Mode

An Omarchy bar widget for switching the Linux AMD X3D scheduler preference
between the cache CCD and the frequency CCD.

- `3D` means the cache CCD is preferred.
- `GHz` means the frequency CCD is preferred.
- Left-click switches modes using a Polkit authorization prompt.
- Right-click refreshes the displayed state.

## Requirements

- Omarchy with the Quickshell-based bar
- A supported dual-CCD AMD Ryzen X3D processor
- The `amd_x3d_mode` sysfs interface at
  `/sys/devices/platform/AMDI0101:00/amd_x3d_mode`

## Installation

```bash
omarchy plugin add https://github.com/xela-io/omarchy-x3d-mode.git --enable --yes
```

## Removal

```bash
omarchy plugin remove xela.x3d-mode --yes
```
