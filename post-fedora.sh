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


#Adicionar copr

echo "Adicionado Copr necessários"

sudo dnf copr enable solopasha/hyprland -y
echo "Copr's habilitados"

DEV_PKGS=(
  # Bibliotecas de Dev
  openssl-devel
  zlib-devel
  libyaml-devel
  libffi-devel
  readline-devel
  bzip2-devel
  gdbm-devel
  sqlite-devel
  ncurses-devel
  fuse-devel
  lz4-devel

  # Ferramentas de Build
  gcc
  make
  autoconf
  automake
  libtool
  pkgconfig

  # Terminal, Shell e texto
  neovim
  kitty
  zsh
  git
)

FONTS=(
  mscore-fonts-all
)

DESKTOP=(
  niri
  hyprlock
  hypridle
  hyprpicker
  hyprshot
  waybar
  rofi
  dunst
  xdg-desktop-portal-wlr
  xdg-portal-desktop-gtk
  wl-wayland
  nwg-look
  xdg-utils
  mint-themes-gtk3
  mint-themes-gtk4
  cloc
  cliphist
  bat
  nmtui
  fastfetch
  ImageMagick
  blueman
  nemo
  mousepad
)

install() {
  local pkg=$1
  echo "Instalando $pkg"
  sudo dnf install -y "$pkg"
}

echo "== Instalar bibliotecas e softwares auxiliares de desenvolvimento =="

for program in "${DEV_PKGS[@]}"; do
  install "$program"
done

echo "== Instalar softwares para o desktop =="

for program in "${DESKTOP[@]}"; do
  install "$program"
done

echo "== Instalação concluída =="
exit 0

