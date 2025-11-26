# Dotfiles da workstation Hyprland/Niri

Coleção de dotfiles e scripts para replicar meu ambiente Wayland no Fedora. O setup usa Hyprland como compositor principal (com Waybar, Rofi, Dunst etc.), mas também traz perfis para Niri e configs do LunarVim. Há ainda um script pós-instalação que automatiza a preparação do sistema com pacotes, Flatpaks, fontes, borg-backup e links simbólicos.

## Requisitos
- Fedora Workstation (testado a partir da release 39)
- Git e `curl` para clonar o repositório
- Acesso sudo (o script automatizado usa `dnf`, `systemctl`, `flatpak`, etc.)

> ⚠️ O `post-fedora.sh` instala muitos pacotes e habilita serviços. Revise as etapas antes de executar em produção.

## Estrutura
| Caminho | Descrição |
| --- | --- |
| `hypr/` | Hyprland + hyprpaper/hypridle/hyprlock. Inclui fontes, wallpapers (`hyprlock.png`, `pic.jpg`) e scripts auxiliares para o compositor.
| `niri/` | Configurações do compositor Niri para quem preferir um tiler puro Wayland.
| `waybar/` | Painel Waybar com módulos customizados e cores Catppuccin Mocha.
| `rofi/` | Temas, menu de aplicativos e integrações (launcher/powermenu/clipboard).
| `dunst/` | Notificações com tema minimalista e suporte a ícones Nerd Fonts.
| `lvim/` | Perfil do LunarVim/Neovim com plugins e ajustes para desenvolvimento full-stack.
| `script/` | Coleção de utilitários shell (monitor de bateria, screenshot, powermenu, clipboard, wallpaper, etc.).
| `post-fedora.sh` | Menu interativo para preparar o Fedora, instalar dependências, Flatpaks, Nerd Fonts, configurar asdf e restaurar dotfiles via symlink.

## Pós-instalação automatizada
1. `chmod +x post-fedora.sh`
2. `./post-fedora.sh`
3. Escolha as etapas desejadas no menu (ou use a opção **13** para rodar tudo de uma vez, exceto o backup Borg).

Principais etapas cobertas pelo script:
- Atualização do sistema e configuração de repositórios (Copr Hyprland, RPM Fusion, VS Code).
- Instalação dos grupos `development-tools` e `multimedia` + pacotes essenciais (Hyprland, Waybar, Dunst, Kitty, Neovim, Bluetooth, etc.).
- Flatpaks de produtividade (DBeaver, Postman, Proton apps, GIMP, OnlyOffice, Steam, etc.).
- Nerd Fonts completas diretamente do repositório oficial.
- Serviços habilitados: Bluetooth, power-profiles-daemon, SDDM.
- Links simbólicos para `~/.config/{hypr,niri,waybar,dunst,lvim}`.
- asdf com versões já definidas (Java Temurin, Node 22, Go 1.25, Rust stable, Ruby 3.4, Python 3.11, Neovim 0.10, etc.).
- Clone/execução do repositório `docker-files` pessoal.
- Etapa manual para restaurar backups via Borg (lista discos, monta repo, copia diretórios críticos e desmonta). Só execute quando tiver o repositório disponível.

## Instalação manual dos dotfiles
Se preferir não rodar o script completo:
```bash
git clone https://github.com/arturgso/dot-files.git ~/.dots
cd ~/.dots
mkdir -p ~/.config
ln -sfn ~/.dots/hypr ~/.config/hypr
ln -sfn ~/.dots/niri ~/.config/niri
ln -sfn ~/.dots/waybar ~/.config/waybar
ln -sfn ~/.dots/dunst ~/.config/dunst
ln -sfn ~/.dots/lvim ~/.config/lvim
```
Repita o processo para outros diretórios que quiser versionar (ex.: `rofi`). Reinicie o Hyprland/Niri ou relogue na sessão Wayland para carregar os novos ajustes.

## Scripts utilitários
Alguns scripts vivem em `script/` e podem ser chamados via keybinds do Hyprland/Waybar:
- `battery-monitor.sh`: alerta de bateria baixa integrado ao Dunst.
- `checkupdate.sh`: verifica atualizações e mostra contagem no Waybar.
- `powermenu.sh`, `launcher`: menus Rofi para desligar/suspender/abrir apps.
- `screenshot.sh`: captura select/monitor usando `grim` + `slurp`.
- `rofi-clipboard.sh`: histórico de clipboard com `cliphist`.
- `set_wallpaper.sh`: aplica wallpapers guardados em `hypr/`.

Adapte os paths ou permissões conforme necessidade e adicione ao `PATH` para facilitar o uso.

## Backup e restauração
A opção 10 do `post-fedora.sh` assume que existe um repositório Borg com a estrutura `backup-fedora-mriya`. Ela monta o disco selecionado, encontra o último snapshot e copia uma lista de diretórios críticos (fonts, SSH, projetos, configs). Revise o script antes de rodar e mantenha sua senha Borg à mão.
