#!/usr/bin/env bash

## Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements (mesma lógica sua)
prompt='Screenshot'
mesg="DIR: `xdg-user-dir PICTURES`/Screenshots"

if [[ "$theme" == *'type-1'* ]]; then
    list_col='1'
    list_row='5'
    win_width='400px'
elif [[ "$theme" == *'type-3'* ]]; then
    list_col='1'
    list_row='5'
    win_width='120px'
elif [[ "$theme" == *'type-5'* ]]; then
    list_col='1'
    list_row='5'
    win_width='520px'
elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
    list_col='5'
    list_row='1'
    win_width='670px'
fi

layout=`grep 'USE_ICON' ${theme} | cut -d'=' -f2`
if [[ "$layout" == 'NO' ]]; then
    option_1=" Capture Desktop"
    option_2=" Capture Area"
    option_3=" Capture Window"
    option_4=" Capture in 5s"
    option_5=" Capture in 10s"
else
    option_1=""
    option_2=""
    option_3=""
    option_4=""
    option_5=""
fi

rofi_cmd() {
    rofi -theme-str "window {width: $win_width;}" \
         -theme-str "listview {columns: $list_col; lines: $list_row;}" \
         -theme-str 'textbox-prompt-colon {str: "";}' \
         -dmenu \
         -p "$prompt" \
         -mesg "$mesg" \
         -markup-rows \
         -theme ${theme}
}

run_rofi() {
    echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
}

# Cria diretório, mas note que com grimshot não necessariamente precisa você especificar, mas vamos manter
dir="$(xdg-user-dir PICTURES)/Screenshots"
if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
fi

# Notificação + abrir visualizador (se desejar)
notify_view() {
    local notify_cmd='dunstify -u low --replace=699'
    ${notify_cmd} "Screenshot Ready."
    # exemplo: abrir com viewnior ou outro visualizador
    viewnior "$1" &
}

# As funções de captura agora usando grimshot
shot_now() {
    # salva e copia ao mesmo tempo
    grimshot --notify savecopy screen "$dir/Screenshot_$(date +%Y-%m-%d-%H-%M-%S).png"
    # Optional: se quiser mostrar
    # notify_view <arquivo>
}

shot_area() {
    grimshot --notify savecopy area "$dir/Screenshot_$(date +%Y-%m-%d-%H-%M-%S).png"
}

shot_window() {
    grimshot --notify savecopy window "$dir/Screenshot_$(date +%Y-%m-%d-%H-%M-%S).png"
}

shot_5s() {
    grimshot --notify --wait 5 savecopy screen "$dir/Screenshot_$(date +%Y-%m-%d-%H-%M-%S).png"
}

shot_10s() {
    grimshot --notify --wait 10 savecopy screen "$dir/Screenshot_$(date +%Y-%m-%d-%H-%M-%S).png"
}

run_cmd() {
    case "$1" in
        '--opt1') shot_now ;;
        '--opt2') shot_area ;;
        '--opt3') shot_window ;;
        '--opt4') shot_5s ;;
        '--opt5') shot_10s ;;
    esac
}

chosen="$(run_rofi)"
case ${chosen} in
    $option_1) run_cmd --opt1 ;;
    $option_2) run_cmd --opt2 ;;
    $option_3) run_cmd --opt3 ;;
    $option_4) run_cmd --opt4 ;;
    $option_5) run_cmd --opt5 ;;
esac

