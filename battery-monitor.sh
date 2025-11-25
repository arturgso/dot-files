#!/bin/bash

# Configurações
BATTERY_PATH="/sys/class/power_supply/BAT0"
NOTIFY_TIMEOUT=5000
SUSPEND_LEVEL=10
WARNING_LEVELS=(100 50 25)
LOCKFILE="/tmp/battery-monitor.lock"

# Verificar se outra instância está rodando
if [ -e "$LOCKFILE" ]; then
    exit 0
fi

# Criar lock file
touch "$LOCKFILE"

# Função para garantir remoção do lock ao sair
cleanup() {
    rm -f "$LOCKFILE"
}
trap cleanup EXIT

# Função para obter status da bateria
get_battery_status() {
    local capacity
    local status
    
    # Tentar diferentes caminhos possíveis para bateria
    if [ -d "$BATTERY_PATH" ]; then
        capacity=$(cat "${BATTERY_PATH}/capacity" 2>/dev/null)
        status=$(cat "${BATTERY_PATH}/status" 2>/dev/null)
    elif [ -d "/sys/class/power_supply/BAT1" ]; then
        BATTERY_PATH="/sys/class/power_supply/BAT1"
        capacity=$(cat "${BATTERY_PATH}/capacity" 2>/dev/null)
        status=$(cat "${BATTERY_PATH}/status" 2>/dev/null)
    else
        echo "Bateria não encontrada"
        exit 1
    fi
    
    echo "$capacity $status"
}

# Função para enviar notificação
send_notification() {
    local level="$1"
    local message="$2"
    local urgency="$3"
    
    # Verificar se o usuário está logado graphicalmente
    if [ -n "$DISPLAY" ] && command -v notify-send >/dev/null 2>&1; then
        export DISPLAY=:0
        export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
        
        notify-send -u "$urgency" -t "$NOTIFY_TIMEOUT" \
            "Bateria ${level}%" "$message"
    fi
    
    # Também registrar no syslog
    logger "Battery Monitor: $message"
}

# Função para suspender o sistema
suspend_system() {
    logger "Battery Monitor: Bateria crítica (${SUSPEND_LEVEL}%), suspendendo sistema"
    
    # Enviar notificação crítica
    send_notification "$SUSPEND_LEVEL" "Bateria crítica! Suspensão automática em 10 segundos." "critical"
    
    # Esperar um pouco antes de suspender
    sleep 10
    
    # Verificar novamente o nível antes de suspender
    current_status=$(get_battery_status)
    current_capacity=$(echo "$current_status" | cut -d' ' -f1)
    
    if [ "$current_capacity" -le "$SUSPEND_LEVEL" ]; then
        # Suspender o sistema (escolha o método apropriado para sua distribuição)
        if systemctl --user list-unit-files | grep -q suspend.target; then
            systemctl suspend
        elif command -v pm-suspend >/dev/null 2>&1; then
            pm-suspend
        elif command -v zzz >/dev/null 2>&1; then
            zzz
        else
            logger "Battery Monitor: Erro - Comando de suspensão não encontrado"
        fi
    fi
}

# Arquivo para rastrear notificações já enviadas
STATE_FILE="/tmp/battery-monitor-state"

# Inicializar arquivo de estado se não existir
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

# Ler último nível notificado
last_notified=$(cat "$STATE_FILE")

# Obter status atual
battery_status=$(get_battery_status)
capacity=$(echo "$battery_status" | cut -d' ' -f1)
status=$(echo "$battery_status" | cut -d' ' -f2)

# Só agir se a bateria estiver descarregando
if [ "$status" != "Discharging" ]; then
    # Resetar estado quando estiver carregando
    if [ "$status" = "Charging" ] || [ "$status" = "Full" ]; then
        echo "0" > "$STATE_FILE"
    fi
    exit 0
fi

# Verificar níveis de alerta
for level in "${WARNING_LEVELS[@]}"; do
    if [ "$capacity" -le "$level" ] && [ "$last_notified" -lt "$level" ]; then
        case $level in
            100)
                send_notification "$level" "Bateria completamente carregada." "normal"
                ;;
            50)
                send_notification "$level" "Bateria em 50%. Considere conectar o carregador." "normal"
                ;;
            25)
                send_notification "$level" "Bateria em 25%. Conecte o carregador em breve." "critical"
                ;;
        esac
        echo "$level" > "$STATE_FILE"
        break
    fi
done

# Verificar suspensão automática
if [ "$capacity" -le "$SUSPEND_LEVEL" ] && [ "$last_notified" -gt "$SUSPEND_LEVEL" ]; then
    suspend_system
    echo "$SUSPEND_LEVEL" > "$STATE_FILE"
fi

exit 0
