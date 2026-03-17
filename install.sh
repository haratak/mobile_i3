#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#   mobile-i3
#   i3wm + Neovim + Catppuccin on Android (Termux native)
#   No root required. No proot.
# ============================================================

set -euo pipefail

# ── Colors (Catppuccin Mocha) ─────────────────────────────────
RESET='\033[0m'
BOLD='\033[1m'
MAUVE='\033[38;5;183m'
BLUE='\033[38;5;111m'
GREEN='\033[38;5;114m'
YELLOW='\033[38;5;221m'
RED='\033[38;5;210m'
GRAY='\033[38;5;245m'
PINK='\033[38;5;213m'

# ── Progress ──────────────────────────────────────────────────
TOTAL_STEPS=6
CURRENT_STEP=0
START_TIME=$(date +%s)

print_banner() {
  clear
  echo -e "${MAUVE}${BOLD}"
  echo '  ╔══════════════════════════════════════════════════════╗'
  echo '  ║                                                      ║'
  echo '  ║    ✦  mobile-i3                                      ║'
  echo '  ║                                                      ║'
  echo '  ║    i3wm · Neovim · Catppuccin Mocha on Termux       ║'
  echo '  ║                                                      ║'
  echo '  ╚══════════════════════════════════════════════════════╝'
  echo -e "${RESET}"
}

progress() {
  local pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
  local filled=$(( pct * 42 / 100 ))
  local empty=$(( 42 - filled ))
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=0; i<empty; i++)); do bar+="░"; done
  echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "  ${MAUVE}[${bar}] ${pct}%${RESET}"
  echo -e "  ${BLUE}Step ${CURRENT_STEP}/${TOTAL_STEPS}: $1${RESET}"
  echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  print_banner
  progress "$1"
}

ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }
info() { echo -e "  ${BLUE}→${RESET} $1"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
fail() { echo -e "\n  ${RED}✗ ERROR: $1${RESET}\n"; exit 1; }

# ── Preflight ─────────────────────────────────────────────────
print_banner
echo -e "  ${GRAY}Components to install:${RESET}"
echo ""
echo -e "  ${MAUVE}・${RESET} i3wm                (tiling WM / X11)"
echo -e "  ${MAUVE}・${RESET} Polybar             (status bar)"
echo -e "  ${MAUVE}・${RESET} Rofi                (app launcher)"
echo -e "  ${MAUVE}・${RESET} Neovim              (editor)"
echo -e "  ${MAUVE}・${RESET} Bash + Starship      (shell)"
echo -e "  ${MAUVE}・${RESET} Catppuccin Mocha     (unified theme)"
echo ""
echo -e "  ${GRAY}Required space: ~1GB  /  Estimated time: 5-10 min${RESET}"
echo ""

# Termux-X11 check
if ! pkg list-installed 2>/dev/null | grep -q termux-x11; then
  warn "Termux-X11 is not installed"
  warn "Please install the APK from https://github.com/termux/termux-x11/releases"
  echo ""
fi

echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 1 — Update Termux + install x11-repo
# ═══════════════════════════════════════════════════════════════
step "Updating Termux packages"

pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null
pkg upgrade -y -o Dpkg::Options::="--force-confnew" 2>/dev/null
pkg install -y x11-repo
ok "Termux update complete"

# ═══════════════════════════════════════════════════════════════
# STEP 2 — X11 + i3 packages
# ═══════════════════════════════════════════════════════════════
step "Installing X11 environment and i3wm"

pkg install -y \
  termux-x11-nightly \
  pulseaudio \
  i3 \
  polybar \
  rofi \
  dunst \
  feh \
  xterm \
  xorg-xrandr \
  xclip \
  dbus
ok "X11 + i3wm complete"

# ═══════════════════════════════════════════════════════════════
# STEP 3 — Dev tools
# ═══════════════════════════════════════════════════════════════
step "Installing dev tools"

pkg install -y \
  neovim \
  git \
  git-delta \
  lazygit \
  starship \
  tmux \
  zoxide \
  fzf \
  ripgrep \
  fd \
  bat \
  eza \
  htop \
  fastfetch \
  nodejs \
  python \
  golang \
  rust
ok "Dev tools complete"

# ═══════════════════════════════════════════════════════════════
# STEP 4 — Fonts
# ═══════════════════════════════════════════════════════════════
step "Installing fonts"

# Install JetBrains Mono Nerd Font
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
  curl -sL "$FONT_URL" | tar xJ -C "$FONT_DIR" 2>/dev/null || {
    warn "Font download failed, using system default"
  }
fi
ok "Fonts complete"

# ═══════════════════════════════════════════════════════════════
# STEP 5 — Apply Catppuccin theme + configs
# ═══════════════════════════════════════════════════════════════
step "Applying Catppuccin Mocha theme"

mkdir -p \
  "$HOME/.config/i3" \
  "$HOME/.config/polybar" \
  "$HOME/.config/rofi/themes" \
  "$HOME/.config/dunst"

# ── i3 config ─────────────────────────────────────────────────
cat > "$HOME/.config/i3/config" << 'I3EOF'
set $rosewater #f5e0dc
set $mauve     #cba6f7
set $red       #f38ba8
set $green     #a6e3a1
set $blue      #89b4fa
set $text      #cdd6f4
set $subtext0  #a6adc8
set $overlay0  #6c7086
set $surface1  #45475a
set $surface0  #313244
set $base      #1e1e2e

set $mod Mod1
set $term xterm
set $menu rofi -show drun

font pango:JetBrainsMono Nerd Font 11
default_border pixel 2
default_floating_border pixel 2
gaps inner 0
gaps outer 0

client.focused          $mauve    $base $text    $rosewater $mauve
client.focused_inactive $overlay0 $base $text    $rosewater $overlay0
client.unfocused        $surface1 $base $subtext0 $rosewater $surface1
client.urgent           $red      $base $text    $red       $red
client.background       $base

exec_always --no-startup-id polybar --reload main &
exec_always --no-startup-id dunst

bindsym $mod+Return       exec $term
bindsym $mod+space        exec $menu
bindsym $mod+q            kill
bindsym $mod+Shift+c      reload
bindsym $mod+Shift+r      restart
bindsym $mod+Shift+e      exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'

bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

bindsym $mod+b split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle
bindsym $mod+Shift+space floating toggle
bindsym $mod+a focus parent

bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+Shift+1 move container to workspace number 1
bindsym $mod+Shift+2 move container to workspace number 2
bindsym $mod+Shift+3 move container to workspace number 3
bindsym $mod+Shift+4 move container to workspace number 4
bindsym $mod+Shift+5 move container to workspace number 5

bindsym $mod+r mode 'resize'
mode 'resize' {
  bindsym h resize shrink width 10 px or 10 ppt
  bindsym j resize grow height 10 px or 10 ppt
  bindsym k resize shrink height 10 px or 10 ppt
  bindsym l resize grow width 10 px or 10 ppt
  bindsym Return mode 'default'
  bindsym Escape mode 'default'
}
I3EOF

# ── Polybar ───────────────────────────────────────────────────
cat > "$HOME/.config/polybar/config.ini" << 'PBEOF'
[colors]
base     = #1e1e2e
surface0 = #313244
overlay0 = #6c7086
text     = #cdd6f4
subtext0 = #a6adc8
mauve    = #cba6f7
teal     = #94e2d5
peach    = #fab387

[bar/main]
width            = 100%
height           = 32
background       = ${colors.base}
foreground       = ${colors.text}
line-size        = 2
padding-left     = 2
padding-right    = 2
module-margin    = 1
separator        = |
separator-foreground = ${colors.overlay0}
font-0           = JetBrainsMono Nerd Font:style=Regular:size=11;2
modules-left     = i3 xwindow
modules-center   =
modules-right    = cpu memory

[module/i3]
type                        = internal/i3
label-focused               = %index%
label-focused-foreground    = ${colors.mauve}
label-focused-background    = ${colors.surface0}
label-focused-padding       = 2
label-unfocused             = %index%
label-unfocused-foreground  = ${colors.overlay0}
label-unfocused-padding     = 2

[module/xwindow]
type            = internal/xwindow
label           = %title:0:60:...%
label-foreground = ${colors.subtext0}

[module/cpu]
type            = internal/cpu
interval        = 10
label           = 󰘚 %percentage:2%%
label-foreground = ${colors.teal}

[module/memory]
type            = internal/memory
interval        = 10
label           = 󰍛 %percentage_used:2%%
label-foreground = ${colors.mauve}
PBEOF

# ── Rofi ──────────────────────────────────────────────────────
cat > "$HOME/.config/rofi/themes/catppuccin-mocha.rasi" << 'ROFIEOF'
* { bg: #1e1e2e; bg-alt: #313244; fg: #cdd6f4; fg-alt: #6c7086; accent: #cba6f7; }
window { background-color: @bg; border: 2px solid; border-color: @accent; border-radius: 10px; width: 420px; }
mainbox { background-color: transparent; padding: 12px; }
inputbar { background-color: @bg-alt; border-radius: 8px; padding: 8px 12px; margin-bottom: 10px; children: [prompt,entry]; }
prompt { text-color: @accent; margin-right: 8px; }
entry { text-color: @fg; placeholder: "Search..."; placeholder-color: @fg-alt; }
listview { background-color: transparent; lines: 8; columns: 1; spacing: 4px; }
element { background-color: transparent; padding: 8px 12px; border-radius: 6px; }
element selected { background-color: @bg-alt; text-color: @accent; }
element-text { text-color: inherit; }
ROFIEOF

cat > "$HOME/.config/rofi/config.rasi" << 'RCEOF'
configuration { modi: "drun,run,window"; font: "JetBrainsMono Nerd Font 12"; show-icons: true; }
@theme "~/.config/rofi/themes/catppuccin-mocha.rasi"
RCEOF

# ── Dunst ─────────────────────────────────────────────────────
cat > "$HOME/.config/dunst/dunstrc" << 'DEOF'
[global]
  font             = JetBrainsMono Nerd Font 11
  frame_color      = "#cba6f7"
  background       = "#1e1e2e"
  foreground       = "#cdd6f4"
  corner_radius    = 8
  padding          = 12
  horizontal_padding = 12
  width            = 320
  offset           = 12x48
[urgency_normal]
  frame_color = "#89b4fa"
[urgency_critical]
  foreground  = "#f38ba8"
  frame_color = "#f38ba8"
DEOF

# ── Bash config ──────────────────────────────────────────────
grep -q 'starship init bash' "$HOME/.bashrc" 2>/dev/null || cat >> "$HOME/.bashrc" << 'BASHRCEOF'

# Starship prompt
eval "$(starship init bash)"
# Zoxide
eval "$(zoxide init bash)"
# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza --tree --icons --level=2'
alias cat='bat --style=auto'
alias vim='nvim'
alias vi='nvim'
alias g='git'
alias lg='lazygit'
BASHRCEOF

# ── Starship ──────────────────────────────────────────────────
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'SSEOF'
format = "$username$directory$git_branch$git_status$cmd_duration$line_break$character"
palette = "catppuccin_mocha"

[palettes.catppuccin_mocha]
mauve = "#cba6f7"
blue  = "#89b4fa"
green = "#a6e3a1"
red   = "#f38ba8"
yellow = "#f9e2af"
text  = "#cdd6f4"

[username]
show_always = true
style_user  = "bold mauve"
format      = "[$user]($style) "

[directory]
style            = "bold blue"
truncation_length = 3
format           = "[$path]($style) "

[git_branch]
symbol = " "
style  = "bold green"
format = "[$symbol$branch]($style) "

[git_status]
style  = "bold red"
format = "([$all_status$ahead_behind]($style)) "

[character]
success_symbol = "[❯](bold mauve)"
error_symbol   = "[❯](bold red)"
SSEOF

# ── tmux ──────────────────────────────────────────────────────
cat > "$HOME/.tmux.conf" << 'TMUXEOF'
set -g  default-terminal   'tmux-256color'
set -ag terminal-overrides ',*:Tc'
set -g  prefix             C-a
unbind  C-b
bind    C-a send-prefix
set -g  mouse              on
set -g  base-index         1
set -g  escape-time        0
set -g  status-style             'bg=#1e1e2e,fg=#cdd6f4'
set -g  status-left              '#[fg=#cba6f7,bold] ✦ #S '
set -g  status-right             '#[fg=#89b4fa] %H:%M '
set -g  window-status-current-style 'fg=#cba6f7,bold'
set -g  pane-active-border-style    'fg=#cba6f7'
set -g  mode-keys          vi
TMUXEOF

# ── Git config ────────────────────────────────────────────────
git config --global core.pager       'delta'
git config --global delta.navigate   true
git config --global delta.line-numbers true
git config --global pull.rebase      true
git config --global init.defaultBranch main

ok "Theme and configs applied"

# ═══════════════════════════════════════════════════════════════
# STEP 6 — Generate launch scripts
# ═══════════════════════════════════════════════════════════════
step "Generating launch scripts"

cat > "$HOME/start-i3.sh" << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "  ✦ Starting mobile-i3..."

export XDG_RUNTIME_DIR="${TMPDIR}"

# PulseAudio
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1 2>/dev/null || true

# Start Termux-X11
termux-x11 :1 -xstartup "" &
sleep 2

echo "  → Please open the Termux-X11 app"
echo ""

export DISPLAY=:1

# Auto-detect screen resolution
SCREEN_RES=$(xrandr 2>/dev/null | grep ' connected' | grep -oP '\d+x\d+' | head -1)
if [ -n "$SCREEN_RES" ]; then
  xrandr --output $(xrandr | grep ' connected' | awk '{print $1}') --mode "$SCREEN_RES" 2>/dev/null || true
fi

eval $(dbus-launch --sh-syntax 2>/dev/null) || true
exec i3
STARTEOF
chmod +x "$HOME/start-i3.sh"

cat > "$HOME/stop-i3.sh" << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
pkill -f "i3"         2>/dev/null || true
pkill -f "polybar"    2>/dev/null || true
pkill -f "termux-x11" 2>/dev/null || true
pulseaudio --kill      2>/dev/null || true
echo "  ✦ mobile-i3 stopped"
STOPEOF
chmod +x "$HOME/stop-i3.sh"

ok "Launch scripts generated"

# ═══════════════════════════════════════════════════════════════
# Done
# ═══════════════════════════════════════════════════════════════
ELAPSED=$(( $(date +%s) - START_TIME ))
MINS=$(( ELAPSED / 60 ))
SECS=$(( ELAPSED % 60 ))

print_banner
echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}${BOLD}✦ Installation complete! (${MINS}m ${SECS}s)${RESET}"
echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${MAUVE}${BOLD}Usage:${RESET}"
echo -e "  ${BLUE}bash ~/start-i3.sh${RESET}      Start desktop"
echo -e "  ${BLUE}bash ~/stop-i3.sh${RESET}       Stop"
echo ""
echo -e "  ${MAUVE}${BOLD}Keybindings (i3wm):${RESET}"
echo -e "  ${GRAY}Alt + Enter${RESET}              Terminal"
echo -e "  ${GRAY}Alt + Space${RESET}              Launcher (Rofi)"
echo -e "  ${GRAY}Alt + Q${RESET}                  Close window"
echo -e "  ${GRAY}Alt + H/J/K/L${RESET}            Focus navigation"
echo -e "  ${GRAY}Alt + Shift+H/J/K/L${RESET}      Move window"
echo -e "  ${GRAY}Alt + 1-5${RESET}                Switch workspace"
echo -e "  ${GRAY}Alt + F${RESET}                  Fullscreen"
echo -e "  ${GRAY}Alt + R${RESET}                  Resize mode"
echo ""
echo -e "  ${PINK}✦ i3wm on your Android. Enjoy!${RESET}"
echo ""
