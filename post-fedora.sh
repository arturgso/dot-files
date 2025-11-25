#!/usr/bin/env bash

echo "
▄███████▄  ▄██████▄     ▄████████     ███           ▄█  ███▄▄▄▄      ▄████████     ███        ▄████████  ▄█        ▄█       
  ███    ███ ███    ███   ███    ███ ▀█████████▄      ███  ███▀▀▀██▄   ███    ███ ▀█████████▄   ███    ███ ███       ███       
  ███    ███ ███    ███   ███    █▀     ▀███▀▀██      ███▌ ███   ███   ███    █▀     ▀███▀▀██   ███    ███ ███       ███       
  ███    ███ ███    ███   ███            ███   ▀      ███▌ ███   ███   ███            ███   ▀   ███    ███ ███       ███       
▀█████████▀  ███    ███ ▀███████████     ███          ███▌ ███   ███ ▀███████████     ███     ▀███████████ ███       ███       
  ███        ███    ███          ███     ███          ███  ███   ███          ███     ███       ███    ███ ███       ███       
  ███        ███    ███    ▄█    ███     ███          ███  ███   ███    ▄█    ███     ███       ███    ███ ███▌    ▄ ███▌    ▄ 
 ▄████▀       ▀██████▀   ▄████████▀     ▄████▀        █▀    ▀█   █▀   ▄████████▀     ▄████▀     ███    █▀  █████▄▄██ █████▄▄██ 
                                                                                                           ▀         ▀         "


set -u
IFS=$'\n'

#Adicionar copr

echo "Adicionando Copr necessários"

sudo dnf copr enable solopasha/hyprland -y
echo "Copr's habilitados"

# -------------------
# Configuração (suas listas)
# -------------------
DEV_PKGS=(
  openssl-devel zlib-devel libyaml-devel libffi-devel readline-devel bzip2-devel
  gdbm-devel sqlite-devel ncurses-devel fuse-devel lz4-devel
  gcc make autoconf automake libtool pkgconfig
  neovim kitty zsh git
)

FONTS=(
  mscore-fonts-all
)

DESKTOP=(
  niri hyprlock hypridle hyprpicker hyprshot waybar rofi dunst
  xdg-desktop-portal-wlr xdg-portal-desktop-gtk wl-wayland nwg-look xdg-utils
  mint-themes-gtk3 mint-themes-gtk4 cloc cliphist bat nmtui fastfetch ImageMagick
  blueman nemo mousepad
)

LOGFILE="install.log"
FAILED=()
SKIPPED=()
INSTALLED=()

# -------------------
# Preparação: sudo keepalive
# -------------------
sudo -v || { echo "sudo sem sucesso. Verifique permissões." ; exit 1; }
( while true; do sudo -v; sleep 60; done ) 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

cleanup() {
  kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}
trap cleanup EXIT

# -------------------
# Prepara log e remove duplicatas preservando ordem
# -------------------
: > "$LOGFILE"

ALL=( "${DEV_PKGS[@]}" "${FONTS[@]}" "${DESKTOP[@]}" )
uniq_list=()
declare -A seen
for p in "${ALL[@]}"; do
  [ -z "$p" ] && continue
  if [ -z "${seen[$p]:-}" ]; then
    uniq_list+=("$p")
    seen[$p]=1
  fi
done

TOTAL=${#uniq_list[@]}

echo "== Iniciando instalações ($TOTAL pacotes) ==" | tee -a "$LOGFILE"

# -------------------
# Função de instalação por pacote
# -------------------
install_pkg() {
    local pkg="$1"
    local index="$2"
    local total="$3"

    echo "[ $index/$total ] Instalando: $pkg"

    if sudo dnf install -y "$pkg" &>> "$LOGFILE"; then
        echo "✓ Sucesso: $pkg"
        INSTALLED+=("$pkg")
    else
        echo "✗ Falhou:  $pkg (ver $LOGFILE)"
        FAILED+=("$pkg")
    fi
}

# -------------------
# Loop principal
# -------------------
CURRENT=0

for pkg in "${uniq_list[@]}"; do
  CURRENT=$(( CURRENT + 1 ))
  install_pkg "$pkg" "$CURRENT" "$TOTAL"
done

echo
echo "=== Resumo ==="
echo "Total pacotes processados: $TOTAL"
echo "Instalados agora: ${#INSTALLED[@]}"
echo "Pulados (já instalados): ${#SKIPPED[@]}"
echo "Falharam: ${#FAILED[@]}"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo
  echo "Pacotes que falharam:"
  for f in "${FAILED[@]}"; do
    echo " - $f"
  done
  echo
  echo "Confira $LOGFILE para erros completos."
else
  echo "Nenhuma falha detectada!"
fi

exit 0
