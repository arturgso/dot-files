#!/usr/bin/env bash

set -euo pipefail

awww_bin="$HOME/.cargo/bin/awww"
awww_daemon="$HOME/.cargo/bin/awww-daemon"

shopt -s nullglob
default_image=""
for candidate in "$HOME"/.default.*; do
  lower_name=${candidate,,}
  if [[ $lower_name =~ \.(png|jpe?g|webp|bmp)$ ]]; then
    default_image="$candidate"
    break
  fi
done
shopt -u nullglob

if [[ -z $default_image ]]; then
  echo "Nenhuma imagem .default.* encontrada na home." >&2
  exit 1
fi

"$awww_daemon" &

sleep 0.5

"$awww_bin" img "$default_image"
