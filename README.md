# mobile-i3

> Beautiful, minimal dev environment on Android — no root required.

Arch Linux + i3wm desktop on Android via Termux. No root required.

**Arch Linux · i3wm · Neovim · Catppuccin Mocha**

---

## What you get

| Layer          | Tool                           |
| -------------- | ------------------------------ |
| OS             | Arch Linux (proot)             |
| Window Manager | i3wm                           |
| Bar            | Polybar                        |
| Launcher       | Rofi                           |
| Terminal       | Alacritty                      |
| Editor         | Neovim + LazyVim               |
| Shell          | Bash + Starship                |
| Theme          | Catppuccin Mocha (unified)     |
| Notifications  | dunst                          |
| Compositor     | picom                          |
| Dev tools      | Git, Node.js, Python, Go, Rust |

No desktop icons. No file manager. Just workspaces and your terminal.

---

## Requirements

|            |                                                                                       |
| ---------- | ------------------------------------------------------------------------------------- |
| Android    | 7.0+                                                                                  |
| Termux     | [GitHub releases](https://github.com/termux/termux-app/releases) — **not Play Store** |
| Termux-X11 | [GitHub releases](https://github.com/termux/termux-x11/releases)                      |
| Storage    | ~5 GB free                                                                            |

---

## Install

Open Termux and run:

```bash
curl -sL https://raw.githubusercontent.com/haratak/mobile_i3/master/install.sh | bash
```

Takes 20–40 minutes depending on connection speed.

---

## Usage

```bash
bash ~/start-i3.sh      # Start desktop
bash ~/arch-shell.sh    # Open Arch/Bash shell
bash ~/stop-i3.sh       # Stop
```

Open **Termux-X11 app** after running `start-i3.sh` to see the desktop.

---

## Keybindings (i3wm)

| Key                       | Action                    |
| ------------------------- | ------------------------- |
| `Super + Enter`           | Terminal (Alacritty)      |
| `Super + Space`           | Launcher (Rofi)           |
| `Super + Q`               | Close window              |
| `Super + H/J/K/L`         | Focus left/down/up/right  |
| `Super + Shift + H/J/K/L` | Move window               |
| `Super + 1–5`             | Switch workspace          |
| `Super + F`               | Fullscreen                |
| `Super + R`               | Resize mode               |
| `Super + B/V`             | Split horizontal/vertical |
| `Super + Shift + C`       | Reload config             |
| `Print`                   | Screenshot                |

---

## Why i3 instead of Hyprland/Sway?

Hyprland and Sway are Wayland compositors. Wayland requires kernel-level socket management that proot cannot provide — they crash immediately with `XDG_RUNTIME_DIR` errors. i3 runs on X11 via Termux-X11, which works reliably on Android without root.

---

## License

MIT
