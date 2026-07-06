#!/bin/bash
# =============================================================
# list-instances.sh
# Lista instancias EC2 com ID, nome, estado e IP publico
# Autor: Luciano Girao | github.com/luciano-girao
# Uso: ./list-instances.sh [regiao]
# =============================================================

set -euo pipefail

REGION=${1:-${AWS_DEFAULT_REGION:-"us-east-1"}}

echo "================================================"
echo " Instancias EC2 | Regiao: $REGION"
echo "================================================"
printf "%-22s %-20s %-12s %-16s %s\n" "INSTANCE-ID" "NOME" "ESTADO" "IP PUBLICO" "TIPO"
echo "-----------------------------------------------------------------------"

aws ec2 describe-instances \
  --region "$REGION" \
  --query 'Reservations[*].Instances[*].[
    InstanceId,
    Tags[?Key==`Name`].Value | [0],
    State.Name,
    PublicIpAddress,
    InstanceType
  ]' \
  --output text | while IFS=$'\t' read -r ID NAME STATE IP TYPE; do
    NAME=${NAME:-"(sem nome)"}
    IP=${IP:-"N/A"}
    STATE_LABEL="$STATE"
    printf "%-22s %-20s %-12s %-16s %s\n" "$ID" "$NAME" "$STATE_LABEL" "$IP" "$TYPE"
done

echo "================================================"
