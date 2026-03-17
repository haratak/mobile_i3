# mobile-i3

> i3wm on Android — no root, no proot, native Termux.

**i3wm · Polybar · Neovim · Catppuccin Mocha**

---

## What you get

| Layer          | Tool                           |
| -------------- | ------------------------------ |
| Window Manager | i3wm                           |
| Bar            | Polybar                        |
| Launcher       | Rofi                           |
| Editor         | Neovim                         |
| Shell          | Bash + Starship                |
| Theme          | Catppuccin Mocha (unified)     |
| Dev tools      | Git, Node.js, Python, Go, Rust |

Runs directly on Termux — no proot-distro, no Arch Linux layer.

---

## Requirements

|            |                                                                                       |
| ---------- | ------------------------------------------------------------------------------------- |
| Android    | 7.0+                                                                                  |
| Termux     | [GitHub releases](https://github.com/termux/termux-app/releases) — **not Play Store** |
| Termux-X11 | [GitHub releases](https://github.com/termux/termux-x11/releases)                      |
| Storage    | ~1 GB free                                                                            |

---

## Install

Open Termux and run:

```bash
curl -sL https://raw.githubusercontent.com/haratak/mobile_i3/master/install.sh | bash
```

Takes about 5–10 minutes.

---

## Usage

```bash
bash ~/start-i3.sh      # Start desktop
bash ~/stop-i3.sh       # Stop
```

Open **Termux-X11 app** after running `start-i3.sh` to see the desktop.

---

## Keybindings (i3wm)

| Key                       | Action                    |
| ------------------------- | ------------------------- |
| `Ctrl+Alt + Enter`             | Terminal                  |
| `Ctrl+Alt + Space`             | Launcher (Rofi)           |
| `Ctrl+Alt + Q`                 | Close window              |
| `Ctrl+Alt + H/J/K/L`           | Focus left/down/up/right  |
| `Ctrl+Alt + Shift + H/J/K/L`   | Move window               |
| `Ctrl+Alt + 1–5`               | Switch workspace          |
| `Ctrl+Alt + F`                 | Fullscreen                |
| `Ctrl+Alt + R`                 | Resize mode               |
| `Ctrl+Alt + B/V`               | Split horizontal/vertical |
| `Ctrl+Alt + Shift + C`         | Reload config             |

---

## License

MIT
