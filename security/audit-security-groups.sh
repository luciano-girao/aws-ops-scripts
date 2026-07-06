#!/bin/bash
# =============================================================
# audit-security-groups.sh
# Audita Security Groups na AWS e reporta regras expostas
# para 0.0.0.0/0 (acesso público irrestrito)
# Autor: Luciano Girão | github.com/luciano-girao
# =============================================================

set -euo pipefail

REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
OUTPUT_FILE="sg-audit-report-$(date +%Y%m%d-%H%M%S).txt"

echo "================================================"
echo " AWS Security Group Audit"
echo " Região: $REGION"
echo " Data: $(date)"
echo "================================================"
echo ""

# Lista todos os Security Groups
SGS=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
  --output text)

if [ -z "$SGS" ]; then
  echo "[AVISO] Nenhum Security Group encontrado na região $REGION"
  exit 0
fi

echo "[INFO] Verificando regras com acesso público irrestrito (0.0.0.0/0)..."
echo ""

FLAGS=0

while IFS=$'\t' read -r SG_ID SG_NAME SG_DESC; do

  # Verifica regras de entrada com CIDR 0.0.0.0/0
  OPEN_PORTS=$(aws ec2 describe-security-groups \
    --region "$REGION" \
    --group-ids "$SG_ID" \
    --query 'SecurityGroups[0].IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]].[FromPort,ToPort,IpProtocol]' \
    --output text)

  if [ -n "$OPEN_PORTS" ]; then
    FLAGS=$((FLAGS + 1))
    echo "[ALERTA] SG: $SG_ID ($SG_NAME)"
    echo "  Descrição: $SG_DESC"
    echo "  Portas abertas para 0.0.0.0/0:"
    while IFS=$'\t' read -r FROM_PORT TO_PORT PROTOCOL; do
      if [ "$FROM_PORT" = "None" ]; then
        echo "    - Protocolo: $PROTOCOL (todas as portas)"
      else
        echo "    - Porta(s): $FROM_PORT-$TO_PORT | Protocolo: $PROTOCOL"
      fi
    done <<< "$OPEN_PORTS"
    echo ""
  fi

done <<< "$SGS"

echo "================================================"
if [ $FLAGS -eq 0 ]; then
  echo "[OK] Nenhuma regra com acesso irrestrito encontrada."
else
  echo "[RESUMO] $FLAGS Security Group(s) com exposição pública detectados."
  echo "[RECOMENDAÇÃO] Restrinja as regras ao menor CIDR necessário."
fi
echo "================================================"
