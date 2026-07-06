#!/bin/bash
# =============================================================
# start-stop-instance.sh
# Inicia ou para uma instancia EC2 por ID
# Autor: Luciano Girao | github.com/luciano-girao
# Uso: ./start-stop-instance.sh [start|stop] [instance-id]
# =============================================================

set -euo pipefail

ACTION=${1:-""}
INSTANCE_ID=${2:-""}
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}

if [ -z "$ACTION" ] || [ -z "$INSTANCE_ID" ]; then
  echo "Uso: $0 [start|stop] [instance-id]"
  echo "  Exemplo: $0 stop i-0abc123456789"
  exit 1
fi

if [[ "$ACTION" != "start" && "$ACTION" != "stop" ]]; then
  echo "[ERRO] Acao invalida: '$ACTION'. Use 'start' ou 'stop'."
  exit 1
fi

echo "[INFO] Buscando instancia $INSTANCE_ID..."

CURRENT_STATE=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' \
  --output text)

echo "[INFO] Estado atual: $CURRENT_STATE"

if [ "$ACTION" = "stop" ]; then
  if [ "$CURRENT_STATE" = "stopped" ]; then
    echo "[AVISO] Instancia ja esta parada."
    exit 0
  fi
  echo "[INFO] Parando instancia $INSTANCE_ID..."
  aws ec2 stop-instances --region "$REGION" --instance-ids "$INSTANCE_ID" > /dev/null
  aws ec2 wait instance-stopped --region "$REGION" --instance-ids "$INSTANCE_ID"
  echo "[OK] Instancia parada com sucesso."
else
  if [ "$CURRENT_STATE" = "running" ]; then
    echo "[AVISO] Instancia ja esta em execucao."
    exit 0
  fi
  echo "[INFO] Iniciando instancia $INSTANCE_ID..."
  aws ec2 start-instances --region "$REGION" --instance-ids "$INSTANCE_ID" > /dev/null
  aws ec2 wait instance-running --region "$REGION" --instance-ids "$INSTANCE_ID"
  PUBLIC_IP=$(aws ec2 describe-instances \
    --region "$REGION" \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)
  echo "[OK] Instancia iniciada. IP Publico: $PUBLIC_IP"
fi
