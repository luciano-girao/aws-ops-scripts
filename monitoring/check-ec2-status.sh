#!/bin/bash
# =============================================================
# Script: check-ec2-status.sh
# Description: Verifica status de instancias EC2 via AWS CLI
# Author: Luciano Girao
# Date: 2025
# Usage: ./check-ec2-status.sh [--region us-east-1]
# =============================================================

set -euo pipefail

REGION=${1:-us-east-1}

echo "================================================"
echo " EC2 Instance Status Report"
echo " Region: $REGION"
echo " Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================================"

# Lista todas instancias com nome, ID, tipo, estado e IP
aws ec2 describe-instances \
  --region "$REGION" \
  --query 'Reservations[*].Instances[*].{
    Name: Tags[?Key==`Name`]|[0].Value,
    ID: InstanceId,
    Type: InstanceType,
    State: State.Name,
    PublicIP: PublicIpAddress,
    PrivateIP: PrivateIpAddress
  }' \
  --output table

# Conta instancias por estado
echo ""
echo "--- Resumo ---"
RUNNING=$(aws ec2 describe-instances --region "$REGION" \
  --filters Name=instance-state-name,Values=running \
  --query 'length(Reservations[*].Instances[*])' \
  --output text)

STOPPED=$(aws ec2 describe-instances --region "$REGION" \
  --filters Name=instance-state-name,Values=stopped \
  --query 'length(Reservations[*].Instances[*])' \
  --output text)

echo "Rodando : $RUNNING"
echo "Paradas : $STOPPED"
echo "================================================"
