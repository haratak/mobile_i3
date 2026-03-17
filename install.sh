#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#   termux-omarchy
#   Arch Linux + i3wm + Neovim + Catppuccin on Android
#   No root required.
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
TOTAL_STEPS=10
CURRENT_STEP=0
START_TIME=$(date +%s)

print_banner() {
  clear
  echo -e "${MAUVE}${BOLD}"
  echo '  ╔══════════════════════════════════════════════════════╗'
  echo '  ║                                                      ║'
  echo '  ║    ✦  termux-omarchy                                 ║'
  echo '  ║                                                      ║'
  echo '  ║    Arch Linux · i3wm · Neovim · Catppuccin Mocha    ║'
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

# proot内でArchコマンドを実行するヘルパー
arch() {
  proot-distro login archlinux -- bash -c "$1"
}

# ── Preflight ─────────────────────────────────────────────────
print_banner
echo -e "  ${GRAY}インストール内容:${RESET}"
echo ""
echo -e "  ${MAUVE}・${RESET} Arch Linux          (proot-distro)"
echo -e "  ${MAUVE}・${RESET} i3wm                (タイリングWM / X11)"
echo -e "  ${MAUVE}・${RESET} Polybar             (ステータスバー)"
echo -e "  ${MAUVE}・${RESET} Rofi                (アプリランチャー)"
echo -e "  ${MAUVE}・${RESET} Alacritty           (ターミナル)"
echo -e "  ${MAUVE}・${RESET} Neovim + LazyVim    (エディタ)"
echo -e "  ${MAUVE}・${RESET} Fish + Starship      (シェル)"
echo -e "  ${MAUVE}・${RESET} Catppuccin Mocha     (テーマ統一)"
echo -e "  ${MAUVE}・${RESET} Git, Node, Python, Go, Rust (開発ツール)"
echo ""
echo -e "  ${GRAY}必要空き容量: 約5GB  /  目安時間: 20〜40分${RESET}"
echo ""

# Termux-X11 チェック
if ! pkg list-installed 2>/dev/null | grep -q termux-x11; then
  warn "Termux-X11 が未インストールです"
  warn "https://github.com/termux/termux-x11/releases からAPKをインストールしてください"
  echo ""
fi

read -p "  Enterキーでインストール開始... " _
echo ""

# ═══════════════════════════════════════════════════════════════
# STEP 1 — Termux パッケージ更新
# ═══════════════════════════════════════════════════════════════
step "Termux パッケージを更新中"

pkg update -y -o Dpkg::Options::="--force-confnew" 2>/dev/null
pkg upgrade -y -o Dpkg::Options::="--force-confnew" 2>/dev/null
ok "Termux 更新完了"

# ═══════════════════════════════════════════════════════════════
# STEP 2 — Termux 必須パッケージ
# ═══════════════════════════════════════════════════════════════
step "Termux 必須パッケージをインストール中"

pkg install -y \
  proot-distro \
  x11-repo \
  termux-x11-nightly \
  pulseaudio \
  wget curl git
ok "必須パッケージ完了"

# ═══════════════════════════════════════════════════════════════
# STEP 3 — Arch Linux インストール
# ═══════════════════════════════════════════════════════════════
step "Arch Linux をインストール中 (proot-distro)"

if proot-distro list 2>/dev/null | grep -q "archlinux.*installed"; then
  info "Arch Linux はすでにインストール済みです"
else
  proot-distro install archlinux
  ok "Arch Linux インストール完了"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 4 — Arch 初期化 + X11/i3 パッケージ
# ═══════════════════════════════════════════════════════════════
step "X11 環境と i3wm をインストール中"

arch "
  pacman-key --init 2>/dev/null || true
  pacman-key --populate archlinux 2>/dev/null || true
  pacman -Syu --noconfirm 2>/dev/null || true

  pacman -S --noconfirm --needed \
    xorg-server \
    xorg-xinit \
    xorg-xrandr \
    xorg-xsetroot \
    xorg-xrdb \
    xterm \
    i3-wm \
    i3status \
    i3lock \
    polybar \
    rofi \
    dunst \
    picom \
    feh \
    xclip \
    xdotool \
    scrot \
    autorandr \
    dbus
"
ok "X11 + i3wm インストール完了"

# ═══════════════════════════════════════════════════════════════
# STEP 5 — GUIアプリ
# ═══════════════════════════════════════════════════════════════
step "GUIアプリをインストール中"

arch "
  pacman -S --noconfirm --needed \
    alacritty \
    chromium \
    imv \
    mpv \
    evince \
    pavucontrol \
    noto-fonts \
    noto-fonts-emoji \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols
"
ok "GUIアプリ完了"

# ═══════════════════════════════════════════════════════════════
# STEP 6 — 開発ツール
# ═══════════════════════════════════════════════════════════════
step "開発ツールをインストール中"

arch "
  pacman -S --noconfirm --needed \
    neovim \
    git \
    git-delta \
    lazygit \
    fish \
    starship \
    tmux \
    zoxide \
    fzf \
    ripgrep \
    fd \
    bat \
    eza \
    htop \
    btop \
    fastfetch \
    base-devel \
    nodejs \
    npm \
    python \
    python-pip \
    go \
    rustup
"
ok "開発ツール完了"

# ═══════════════════════════════════════════════════════════════
# STEP 7 — Catppuccin テーマ適用
# ═══════════════════════════════════════════════════════════════
step "Catppuccin Mocha テーマを適用中"

arch "
mkdir -p \
  /root/.config/i3 \
  /root/.config/polybar \
  /root/.config/rofi/themes \
  /root/.config/dunst \
  /root/.config/alacritty \
  /root/.config/fish \
  /root/.config/picom \
  /root/Pictures/Wallpapers

# ── i3 config ─────────────────────────────────────────────────
cat > /root/.config/i3/config << 'I3EOF'
set \$rosewater #f5e0dc
set \$mauve     #cba6f7
set \$red       #f38ba8
set \$green     #a6e3a1
set \$blue      #89b4fa
set \$text      #cdd6f4
set \$subtext0  #a6adc8
set \$overlay0  #6c7086
set \$surface1  #45475a
set \$surface0  #313244
set \$base      #1e1e2e

set \$mod Mod4
set \$term alacritty
set \$menu rofi -show drun

font pango:JetBrainsMono Nerd Font 11
default_border pixel 2
default_floating_border pixel 2
gaps inner 10
gaps outer 4
smart_gaps on
smart_borders on

client.focused          \$mauve    \$base \$text    \$rosewater \$mauve
client.focused_inactive \$overlay0 \$base \$text    \$rosewater \$overlay0
client.unfocused        \$surface1 \$base \$subtext0 \$rosewater \$surface1
client.urgent           \$red      \$base \$text    \$red       \$red
client.background       \$base

exec_always --no-startup-id polybar --reload main &
exec_always --no-startup-id picom --daemon
exec_always --no-startup-id dunst
exec --no-startup-id feh --bg-fill ~/Pictures/Wallpapers/wallpaper.png

bindsym \$mod+Return       exec \$term
bindsym \$mod+space        exec \$menu
bindsym \$mod+q            kill
bindsym \$mod+Shift+c      reload
bindsym \$mod+Shift+r      restart
bindsym \$mod+Shift+e      exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'

bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right
bindsym \$mod+Shift+h move left
bindsym \$mod+Shift+j move down
bindsym \$mod+Shift+k move up
bindsym \$mod+Shift+l move right

bindsym \$mod+b split h
bindsym \$mod+v split v
bindsym \$mod+f fullscreen toggle
bindsym \$mod+Shift+space floating toggle
bindsym \$mod+a focus parent

bindsym \$mod+s layout stacking
bindsym \$mod+w layout tabbed
bindsym \$mod+e layout toggle split

bindsym \$mod+1 workspace number 1
bindsym \$mod+2 workspace number 2
bindsym \$mod+3 workspace number 3
bindsym \$mod+4 workspace number 4
bindsym \$mod+5 workspace number 5
bindsym \$mod+Shift+1 move container to workspace number 1
bindsym \$mod+Shift+2 move container to workspace number 2
bindsym \$mod+Shift+3 move container to workspace number 3
bindsym \$mod+Shift+4 move container to workspace number 4
bindsym \$mod+Shift+5 move container to workspace number 5

bindsym \$mod+r mode 'resize'
mode 'resize' {
  bindsym h resize shrink width 10 px or 10 ppt
  bindsym j resize grow height 10 px or 10 ppt
  bindsym k resize shrink height 10 px or 10 ppt
  bindsym l resize grow width 10 px or 10 ppt
  bindsym Return mode 'default'
  bindsym Escape mode 'default'
}

bindsym Print exec --no-startup-id scrot ~/Pictures/screenshot_\$(date +%Y%m%d_%H%M%S).png
I3EOF

# ── Polybar ───────────────────────────────────────────────────
cat > /root/.config/polybar/config.ini << 'PBEOF'
[colors]
base     = #1e1e2e
surface0 = #313244
overlay0 = #6c7086
text     = #cdd6f4
subtext0 = #a6adc8
mauve    = #cba6f7
blue     = #89b4fa
green    = #a6e3a1
yellow   = #f9e2af
red      = #f38ba8
peach    = #fab387
teal     = #94e2d5

[bar/main]
width            = 100%
height           = 32
background       = \${colors.base}
foreground       = \${colors.text}
line-size        = 2
padding-left     = 2
padding-right    = 2
module-margin    = 1
separator        = |
separator-foreground = \${colors.overlay0}
font-0           = JetBrainsMono Nerd Font:style=Regular:size=11;2
modules-left     = i3 xwindow
modules-center   = date
modules-right    = cpu memory battery pulseaudio

[module/i3]
type                        = internal/i3
label-focused               = %index%
label-focused-foreground    = \${colors.mauve}
label-focused-background    = \${colors.surface0}
label-focused-padding       = 2
label-unfocused             = %index%
label-unfocused-foreground  = \${colors.overlay0}
label-unfocused-padding     = 2
label-urgent                = %index%
label-urgent-foreground     = \${colors.red}
label-urgent-padding        = 2

[module/xwindow]
type            = internal/xwindow
label           = %title:0:60:...%
label-foreground = \${colors.subtext0}

[module/date]
type            = internal/date
interval        = 1
date            = %H:%M
date-alt        = %Y-%m-%d %H:%M:%S
label           = 󰥔 %date%
label-foreground = \${colors.blue}

[module/cpu]
type            = internal/cpu
interval        = 2
label           = 󰘚 %percentage:2%%
label-foreground = \${colors.teal}

[module/memory]
type            = internal/memory
interval        = 2
label           = 󰍛 %percentage_used:2%%
label-foreground = \${colors.mauve}

[module/battery]
type                        = internal/battery
battery                     = BAT0
adapter                     = AC
label-charging              = 󰂄 %percentage%%
label-discharging           = 󰁹 %percentage%%
label-full                  = 󰁹 Full
label-charging-foreground   = \${colors.green}
label-discharging-foreground = \${colors.yellow}

[module/pulseaudio]
type                    = internal/pulseaudio
label-volume            = 󰕾 %percentage%%
label-muted             = 󰝟 Muted
label-volume-foreground = \${colors.peach}
label-muted-foreground  = \${colors.overlay0}
PBEOF

# ── Rofi ──────────────────────────────────────────────────────
cat > /root/.config/rofi/themes/catppuccin-mocha.rasi << 'ROFIEOF'
* { bg: #1e1e2e; bg-alt: #313244; fg: #cdd6f4; fg-alt: #6c7086; accent: #cba6f7; }
window { background-color: @bg; border: 2px solid; border-color: @accent; border-radius: 10px; width: 420px; }
mainbox { background-color: transparent; padding: 12px; }
inputbar { background-color: @bg-alt; border-radius: 8px; padding: 8px 12px; margin-bottom: 10px; children: [prompt,entry]; }
prompt { text-color: @accent; margin-right: 8px; }
entry { text-color: @fg; placeholder: 'Search...'; placeholder-color: @fg-alt; }
listview { background-color: transparent; lines: 8; columns: 1; spacing: 4px; }
element { background-color: transparent; padding: 8px 12px; border-radius: 6px; }
element selected { background-color: @bg-alt; text-color: @accent; }
element-text { text-color: inherit; }
ROFIEOF

cat > /root/.config/rofi/config.rasi << 'RCEOF'
configuration { modi: \"drun,run,window\"; font: \"JetBrainsMono Nerd Font 12\"; show-icons: true; }
@theme \"/root/.config/rofi/themes/catppuccin-mocha.rasi\"
RCEOF

# ── Dunst ─────────────────────────────────────────────────────
cat > /root/.config/dunst/dunstrc << 'DEOF'
[global]
  font             = JetBrainsMono Nerd Font 11
  frame_color      = #cba6f7
  background       = #1e1e2e
  foreground       = #cdd6f4
  corner_radius    = 8
  padding          = 12
  horizontal_padding = 12
  width            = 320
  offset           = 12x48
[urgency_normal]
  frame_color = #89b4fa
[urgency_critical]
  foreground  = #f38ba8
  frame_color = #f38ba8
DEOF

# ── Picom ─────────────────────────────────────────────────────
cat > /root/.config/picom/picom.conf << 'PCEOF'
backend = \"glx\";
vsync = true;
corner-radius = 10;
shadow = true;
shadow-radius = 12;
shadow-opacity = 0.5;
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
opacity-rule = [ \"92:class_g = 'Alacritty'\" ];
PCEOF

# ── Alacritty ─────────────────────────────────────────────────
cat > /root/.config/alacritty/alacritty.toml << 'AEOF'
[window]
padding     = { x = 16, y = 12 }
opacity     = 0.95
decorations = \"None\"

[font]
normal = { family = \"JetBrainsMono Nerd Font\", style = \"Regular\" }
bold   = { family = \"JetBrainsMono Nerd Font\", style = \"Bold\" }
size   = 13.0

[colors.primary]
background = \"#1e1e2e\"
foreground = \"#cdd6f4\"

[colors.cursor]
cursor = \"#f5e0dc\"
text   = \"#1e1e2e\"

[colors.normal]
black   = \"#45475a\"
red     = \"#f38ba8\"
green   = \"#a6e3a1\"
yellow  = \"#f9e2af\"
blue    = \"#89b4fa\"
magenta = \"#f5c2e7\"
cyan    = \"#94e2d5\"
white   = \"#bac2de\"

[colors.bright]
black   = \"#585b70\"
red     = \"#f38ba8\"
green   = \"#a6e3a1\"
yellow  = \"#f9e2af\"
blue    = \"#89b4fa\"
magenta = \"#f5c2e7\"
cyan    = \"#94e2d5\"
white   = \"#a6adc8\"
AEOF

# ── Fish ──────────────────────────────────────────────────────
cat > /root/.config/fish/config.fish << 'FISHEOF'
if status is-interactive
  starship init fish | source
  zoxide init fish | source

  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --icons --level=2'
  alias cat='bat --style=auto'
  alias vim='nvim'
  alias vi='nvim'
  alias g='git'
  alias lg='lazygit'

  fastfetch
end
FISHEOF

chsh -s /usr/bin/fish root 2>/dev/null || true

# ── Starship ──────────────────────────────────────────────────
cat > /root/.config/starship.toml << 'SSEOF'
format = \"\$username\$directory\$git_branch\$git_status\$cmd_duration\$line_break\$character\"
palette = \"catppuccin_mocha\"

[palettes.catppuccin_mocha]
mauve = \"#cba6f7\"
blue  = \"#89b4fa\"
green = \"#a6e3a1\"
red   = \"#f38ba8\"
yellow = \"#f9e2af\"
text  = \"#cdd6f4\"

[username]
show_always = true
style_user  = \"bold mauve\"
format      = \"[\$user](\$style) \"

[directory]
style            = \"bold blue\"
truncation_length = 3
format           = \"[\$path](\$style) \"

[git_branch]
symbol = \" \"
style  = \"bold green\"
format = \"[\$symbol\$branch](\$style) \"

[git_status]
style  = \"bold red\"
format = \"([\$all_status\$ahead_behind](\$style)) \"

[character]
success_symbol = \"[❯](bold mauve)\"
error_symbol   = \"[❯](bold red)\"
SSEOF

# ── tmux ──────────────────────────────────────────────────────
cat > /root/.tmux.conf << 'TMUXEOF'
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
"

ok "テーマ適用完了"

# ═══════════════════════════════════════════════════════════════
# STEP 8 — LazyVim
# ═══════════════════════════════════════════════════════════════
step "Neovim + LazyVim をインストール中"

arch "
  rm -rf /root/.config/nvim /root/.local/share/nvim /root/.local/state/nvim /root/.cache/nvim
  git clone https://github.com/LazyVim/starter /root/.config/nvim --depth=1
  rm -rf /root/.config/nvim/.git
  nvim --headless '+Lazy! sync' +qa 2>/dev/null || true
"

ok "LazyVim 完了"

# ═══════════════════════════════════════════════════════════════
# STEP 9 — Git 設定
# ═══════════════════════════════════════════════════════════════
step "Git / 開発環境を設定中"

echo ""
read -p "  Git ユーザー名: " GIT_NAME
read -p "  Git メールアドレス: " GIT_EMAIL
echo ""

arch "
  git config --global user.name        '${GIT_NAME}'
  git config --global user.email       '${GIT_EMAIL}'
  git config --global core.pager       'delta'
  git config --global delta.navigate   true
  git config --global delta.line-numbers true
  git config --global pull.rebase      true
  git config --global init.defaultBranch main
  git config --global alias.st  status
  git config --global alias.co  checkout
  git config --global alias.lg  'log --oneline --graph --decorate'
"

ok "Git 設定完了"

# ═══════════════════════════════════════════════════════════════
# STEP 10 — 起動スクリプト生成
# ═══════════════════════════════════════════════════════════════
step "起動スクリプトを生成中"

cat > ~/start-omarchy.sh << 'STARTEOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "  ✦ termux-omarchy を起動中..."

export XDG_RUNTIME_DIR="${TMPDIR}"

# PulseAudio (音声)
pulseaudio --start \
  --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
  --exit-idle-time=-1 2>/dev/null || true

# Termux-X11 起動
termux-x11 :1 -xstartup "" &
sleep 2

echo "  → Termux-X11 アプリを開いてください"
echo ""

# proot 内で i3 を起動 (--shared-tmp でWaylandソケットを共有)
DISPLAY=:1 \
PULSE_SERVER=127.0.0.1 \
proot-distro login archlinux --shared-tmp -- bash -c "
  export DISPLAY=:1
  export PULSE_SERVER=127.0.0.1
  export XDG_RUNTIME_DIR=/tmp
  eval \$(dbus-launch --sh-syntax 2>/dev/null) || true
  exec i3
"
STARTEOF
chmod +x ~/start-omarchy.sh

cat > ~/stop-omarchy.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
pkill -f "i3"         2>/dev/null || true
pkill -f "termux-x11" 2>/dev/null || true
pulseaudio --kill      2>/dev/null || true
echo "  ✦ termux-omarchy を停止しました"
STOPEOF
chmod +x ~/stop-omarchy.sh

cat > ~/omarchy-shell.sh << 'SHELLEOF'
#!/data/data/com.termux/files/usr/bin/bash
exec proot-distro login archlinux --shared-tmp -- fish
SHELLEOF
chmod +x ~/omarchy-shell.sh

ok "起動スクリプト生成完了"

# ═══════════════════════════════════════════════════════════════
# 完了
# ═══════════════════════════════════════════════════════════════
ELAPSED=$(( $(date +%s) - START_TIME ))
MINS=$(( ELAPSED / 60 ))
SECS=$(( ELAPSED % 60 ))

print_banner
echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "  ${GREEN}${BOLD}✦ インストール完了！ (${MINS}分 ${SECS}秒)${RESET}"
echo -e "${GRAY}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${MAUVE}${BOLD}使い方:${RESET}"
echo -e "  ${BLUE}bash ~/start-omarchy.sh${RESET}   デスクトップ起動"
echo -e "  ${BLUE}bash ~/omarchy-shell.sh${RESET}   Arch / Fish シェル"
echo -e "  ${BLUE}bash ~/stop-omarchy.sh${RESET}    停止"
echo ""
echo -e "  ${MAUVE}${BOLD}キーバインド (i3wm):${RESET}"
echo -e "  ${GRAY}Super + Enter${RESET}            ターミナル (Alacritty)"
echo -e "  ${GRAY}Super + Space${RESET}            ランチャー (Rofi)"
echo -e "  ${GRAY}Super + Q${RESET}                ウィンドウを閉じる"
echo -e "  ${GRAY}Super + H/J/K/L${RESET}          フォーカス移動"
echo -e "  ${GRAY}Super + Shift+H/J/K/L${RESET}    ウィンドウ移動"
echo -e "  ${GRAY}Super + 1〜5${RESET}              ワークスペース切替"
echo -e "  ${GRAY}Super + F${RESET}                フルスクリーン"
echo -e "  ${GRAY}Super + R${RESET}                リサイズモード"
echo ""
echo -e "  ${PINK}✦ Beautiful Arch Linux on your Android. Enjoy!${RESET}"
echo ""
