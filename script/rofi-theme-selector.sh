#!/usr/bin/env bash

set -euo pipefail

DOTS_DIR="${HOME}/.dots"
ROFI_DIR="${DOTS_DIR}/rofi"
COLORS_DIR="${ROFI_DIR}/colors"

if [[ ! -d "$COLORS_DIR" ]]; then
  echo "Diretório de cores não encontrado: $COLORS_DIR" >&2
  exit 1
fi

shopt -s nullglob
declare -a COLOR_FILES=("$COLORS_DIR"/*.rasi)
shopt -u nullglob

if ((${#COLOR_FILES[@]} == 0)); then
  echo "Nenhum arquivo .rasi encontrado em $COLORS_DIR" >&2
  exit 1
fi

mapfile -t THEMES < <(
  for path in "${COLOR_FILES[@]}"; do
    name="$(basename "${path}")"
    printf '%s\n' "${name%.rasi}"
  done | sort -f
)

extract_color() {
  local file="$1" key="$2" value=""
  if command -v rg >/dev/null 2>&1; then
    value="$(rg -m1 -oP "${key}:[^#]*#\\K[0-9A-Fa-f]{6}" "$file" 2>/dev/null || true)"
  else
    value="$(grep -i -m1 "${key}:" "$file" 2>/dev/null | sed -E 's/.*#([0-9A-Fa-f]{6}).*/\1/' || true)"
  fi

  if [[ -z "$value" ]]; then
    value="000000"
  fi

  printf '#%s' "$value"
}

color_block() {
  local hex="${1#\#}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  printf '\033[48;2;%d;%d;%dm  \033[0m' "$r" "$g" "$b"
}

print_menu() {
  printf 'Temas disponíveis:\n'
  local idx=0
  for theme in "${THEMES[@]}"; do
    local file="${COLORS_DIR}/${theme}.rasi"
    local bg fg sel act urg
    bg="$(extract_color "$file" background)"
    fg="$(extract_color "$file" foreground)"
    sel="$(extract_color "$file" selected)"
    act="$(extract_color "$file" active)"
    urg="$(extract_color "$file" urgent)"
    printf '%2d) %-14s %s%-9s %s%-9s %s%-9s %s%-9s %s%-9s\n' \
      $((idx + 1)) "$theme" \
      "$(color_block "$bg")" "$bg" \
      "$(color_block "$fg")" "$fg" \
      "$(color_block "$sel")" "$sel" \
      "$(color_block "$act")" "$act" \
      "$(color_block "$urg")" "$urg"
    ((idx += 1))
  done
}

select_theme() {
  local choice=""
  read -r -p $'\nEscolha um tema (número ou nome, ENTER para sair): ' choice

  if [[ -z "$choice" ]]; then
    echo ""
    return 0
  fi

  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    local index=$((choice - 1))
    if ((index >= 0 && index < ${#THEMES[@]})); then
      echo "${THEMES[$index]}"
      return 0
    fi
  else
    local lowered
    lowered="$(tr '[:upper:]' '[:lower:]' <<< "$choice")"
    for theme in "${THEMES[@]}"; do
      if [[ "$(tr '[:upper:]' '[:lower:]' <<< "$theme")" == "$lowered" ]]; then
        echo "$theme"
        return 0
      fi
    done
  fi

  echo "Seleção inválida: $choice" >&2
  return 1
}

gather_target_files() {
  if command -v rg >/dev/null 2>&1; then
    rg -l --no-heading '@import[^\n]*rofi/colors' "$ROFI_DIR"
  else
    grep -RIl -E 'rofi/colors/[^"]+\.rasi' "$ROFI_DIR"
  fi
}

apply_theme() {
  local theme="$1"
  local import_line="@import \"~/.dots/rofi/colors/${theme}.rasi\""
  mapfile -t targets < <(gather_target_files)

  if ((${#targets[@]} == 0)); then
    echo "Nenhum arquivo usa @import de cores dentro de $ROFI_DIR" >&2
    exit 1
  fi

  for file in "${targets[@]}"; do
    ROFI_TARGET_IMPORT="$import_line" perl -0pi -e 'my $line = $ENV{"ROFI_TARGET_IMPORT"};
      s|(^\s*)(?:\@import\s+)+"[^"\n]*rofi/colors/[^"\n]+\.rasi"|$1$line|gm;' "$file"
    printf 'Atualizado: %s\n' "$file"
  done

  printf '\nTema aplicado: %s\n' "$theme"
}

print_menu
selected_theme="$(select_theme)"

if [[ -z "$selected_theme" ]]; then
  echo "Nenhuma alteração realizada."
  exit 0
fi

apply_theme "$selected_theme"
