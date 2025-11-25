#!/bin/bash

BASE_DIR="$HOME/Docker"
NETWORK_NAME="shared-network"

echo "Criando docker network: $NETWORK_NAME"
docker network create "$NETWORK_NAME" 2>/dev/null || echo "Rede já existe, seguindo..."

echo "Procurando projetos em $BASE_DIR..."
for dir in "$BASE_DIR"/*/; do
    [ -d "$dir" ] || continue

    echo "--------------------------------------"
    echo "Entrando na pasta: $dir"

    # Verifica arquivos possíveis de compose
    if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/docker-compose.yaml" ] \
        || [ -f "$dir/compose.yml" ] || [ -f "$dir/compose.yaml" ]; then

        echo "Arquivo docker-compose encontrado. Subindo containers..."
        (cd "$dir" && docker compose up -d)

    else
        echo "Nenhum arquivo docker-compose encontrado. Pulando..."
    fi
done

echo "Finalizado!"

