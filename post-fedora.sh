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

# Funções de cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Função de delay e espaçamento
pause() {
  sleep 1
  echo
}

# -------------------
# Atualização do sistema
# -------------------
echo -e "${BLUE}Atualizando sistema...${NC}"
sudo dnf upgrade --refresh -y
pause

# -------------------
# Adicionando Copr e RPM Fusion
# -------------------
echo -e "${BLUE}Adicionando Copr e RPM Fusion...${NC}"
sudo dnf copr enable solopasha/hyprland -y
pause

echo -e "${YELLOW}Baixando pacotes RPM Fusion...${NC}"
curl -LO https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-43.noarch.rpm
curl -LO https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-43.noarch.rpm
sudo dnf install -y rpmfusion-free-release-43.noarch.rpm rpmfusion-nonfree-release-43.noarch.rpm
rm -f rpmfusion-*-release-43.noarch.rpm
pause

echo -e "${GREEN}Copr e RPM Fusion habilitados${NC}"
pause

# -------------------
# Instalando grupos padrão
# -------------------
echo -e "${BLUE}Instalando grupos padrão...${NC}"
sudo dnf group install -y development-tools
sudo dnf group install -y multimedia
pause

echo -e "${GREEN}Grupos instalados${NC}"
pause

# -------------------
# Pacotes essenciais
# -------------------
ESSENTIAL_PACKAGES=(
  fuse-devel xdg-desktop-portal-wlr xdg-desktop-portal-gtk xdg-utils
  lz4-devel cliphist nmtui ImageMagick mint-themes-gtk3 mint-themes-gtk4
  openssl-devel zlib-devel libyaml-devel libffi-devel readline-devel bzip2-devel
  gdbm-devel sqlite-devel ncurses-devel make gcc autoconf automake libtool pkgconfig
  mscore-fonts-all blueman niri hyprlock hypridle hyprpicker hyprshot waybar fastfetch kitty code
  dunst neovim mousepad nwg-look rofi bat cloc git zsh
  pipewire pipewire-pulseaudio pulseaudio bluetooth power-profiles-daemon flatpak docker borg
)

# Instalação dos pacotes
echo -e "${BLUE}Instalando pacotes essenciais...${NC}"
for pkg in "${ESSENTIAL_PACKAGES[@]}"; do
  echo -e "Instalando: ${YELLOW}$pkg${NC}"
  if [[ "$pkg" == "code" ]]; then
    echo -e "${BLUE}Configurando repositório do VS Code...${NC}"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf check-update
  fi
  sudo dnf install -y "$pkg"
  pause
 done
pause

# -------------------
# Habilitando serviços essenciais (exceto SDDM)
# -------------------
ESSENTIAL_SERVICES=(pipewire pipewire-pulseaudio pulseaudio bluetooth power-profiles-daemon)

echo -e "${BLUE}Habilitando serviços essenciais...${NC}"
for svc in "${ESSENTIAL_SERVICES[@]}"; do
  sudo systemctl enable "$svc" --now
  echo -e "${GREEN}$svc habilitado e iniciado${NC}"
  pause
 done

# -------------------
# Instalando Docker
# -------------------
echo -e "${BLUE}Instalando Docker...${NC}"
sudo dnf -y install dnf-plugins-core
sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker --now
pause

echo -e "${GREEN}Docker instalado e habilitado${NC}"
pause

# -------------------
# Instalando Nerd Fonts via GitHub
# -------------------
read -p "Deseja instalar as Nerd Fonts? (s/N): " install_fonts
if [[ "$install_fonts" =~ ^[Ss]$ ]]; then
    echo -e "${BLUE}Instalando Nerd Fonts...${NC}"
    NERD_FONTS_URL="https://codeload.github.com/ryanoasis/nerd-fonts/zip/refs/heads/master"
    curl -L -o nerd-fonts.zip "$NERD_FONTS_URL"
    unzip nerd-fonts.zip -d nerd-fonts
    (cd nerd-fonts && ./install.sh)
    rm -rf nerd-fonts nerd-fonts.zip
    pause
    echo -e "${GREEN}Nerd Fonts instaladas${NC}"
    pause
else
    echo -e "${YELLOW}Pular instalação das Nerd Fonts${NC}"
    pause
fi

# -------------------
# Instalando Flatpaks
# -------------------
echo -e "${BLUE}Instalando Flatpak e configurando Flathub...${NC}"
sudo dnf install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
pause

FLATPAKS=(
  com.dec05eba.gpu_screen_recorder
  com.discordapp.Discord
  com.getpostman.Postman
  com.github.IsmaelMartinez.teams_for_linux
  com.github.tchx84.Flatseal
  com.github.unrud.VideoDownloader
  com.protonvpn.www
  com.rtosta.zapzap
  com.spotify.Client
  com.valvesoftware.Steam
  io.dbeaver.DBeaverCommunity
  io.gitlab.theevilskeleton.Upscaler
  it.mijorus.gearlever
  me.proton.Mail
  me.proton.Pass
  one.ablaze.floorp
  org.gimp.GIMP
  org.gnome.World.PikaBackup
  org.inkscape.Inkscape
  org.mozilla.Thunderbird
  org.onlyoffice.desktopeditors
  org.prismlauncher.PrismLauncher
  org.qbittorrent.QBittorrent
  org.videolan.VLC
  rest.insomnia.Insomnia
)

for fpk in "${FLATPAKS[@]}"; do
    echo -e "Instalando Flatpak: ${YELLOW}$fpk${NC}"
    flatpak install -y flathub "$fpk"
    pause
 done
pause

# -------------------
# Criando links simbólicos para configs
# -------------------
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

for folder in niri waybar dunst; do
  if [ -d "$folder" ]; then
    ln -sfn "$(pwd)/$folder" "$CONFIG_DIR/$folder"
    echo -e "${GREEN}Link simbólico criado para $folder${NC}"
    pause
  fi
 done

# -------------------
# Habilitar SDDM após confirmação do usuário
# -------------------
read -p "Deseja habilitar e iniciar o SDDM agora? (s/N): " enable_sddm
if [[ "$enable_sddm" =~ ^[Ss]$ ]]; then
    sudo systemctl enable sddm --now
    echo -e "${GREEN}SDDM habilitado e iniciado${NC}"
else
    echo -e "${YELLOW}SDDM não será habilitado neste momento${NC}"
fi

# -------------------
# Borg Backup
# -------------------
echo -e "${BLUE}Configurando Borg Backup...${NC}"
read -p "Deseja configurar o backup com Borg? (s/N): " setup_borg
if [[ "$setup_borg" =~ ^[Ss]$ ]]; then
    echo -e "${BLUE}Listando dispositivos disponíveis...${NC}"
    lsblk
    read -p "Digite o dispositivo a ser usado para o backup (ex: /dev/sdX): " backup_disk

    # Criar ponto de montagem temporário
    MOUNT_DIR="/mnt/backup_borg"
    sudo mkdir -p "$MOUNT_DIR"
    sudo mount "$backup_disk" "$MOUNT_DIR" || { echo -e "${RED}Falha ao montar o disco${NC}"; exit 1; }

    # Solicitar senha e montar repositório Borg
    read -sp "Digite a senha de encriptação do Borg: " BORG_PASS
    echo
    export BORG_PASSPHRASE="$BORG_PASS"

    REPO_PATH="$MOUNT_DIR/backup-fedora-mriya"
    borg mount "$REPO_PATH" /mnt/borg_mount || { echo -e "${RED}Falha ao montar o repositório Borg${NC}"; exit 1; }

    # Pastas e arquivos a restaurar
    ITEMS=(.var Projetos .wakatime .ssh Cofre Documents Pictures Postman Scripts Vault Videos .oh-my-zsh .themes .icons .default.png .zshrc .gitconfig .wakatime.cfg)
    for item in "${ITEMS[@]}"; do
        src="/mnt/borg_mount/$item"
        dest="$HOME/$item"
        if [ -e "$src" ]; then
            cp -r "$src" "$dest"
            echo -e "${GREEN}Restaurado $item para $dest${NC}"
            pause
        fi
    done

    # Desmontar Borg e disco
    borg umount /mnt/borg_mount
    sudo umount "$MOUNT_DIR"
    sudo rmdir "$MOUNT_DIR"
    echo -e "${GREEN}Backup restaurado com sucesso${NC}"
fi

