#!/bin/bash
# =============================================================
# create-lab-instance.sh
# Cria uma instancia EC2 Amazon Linux 2 para uso em laboratorios
# Autor: Luciano Girao | github.com/luciano-girao
# Uso: ./create-lab-instance.sh [nome-da-instancia]
# =============================================================

set -euo pipefail

INSTANCE_NAME=${1:-"lab-instance"}
REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
INSTANCE_TYPE="t2.micro"

# AMI Amazon Linux 2 (us-east-1) - atualize conforme a regiao
AMI_ID=$(aws ec2 describe-images \
  --region "$REGION" \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
             "Name=state,Values=available" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text)

echo "================================================"
echo " Criando instancia EC2 para laboratorio"
echo " Nome:          $INSTANCE_NAME"
echo " Tipo:          $INSTANCE_TYPE"
echo " AMI:           $AMI_ID"
echo " Regiao:        $REGION"
echo "================================================"

INSTANCE_ID=$(aws ec2 run-instances \
  --region "$REGION" \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME},{Key=Purpose,Value=lab},{Key=CreatedBy,Value=script}]" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo ""
echo "[OK] Instancia criada: $INSTANCE_ID"
echo "[INFO] Aguardando estado 'running'..."

aws ec2 wait instance-running \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "[OK] Instancia em execucao!"
echo "     ID:        $INSTANCE_ID"
echo "     IP Publico: $PUBLIC_IP"
echo "[LEMBRE-SE] Execute './start-stop-instance.sh stop $INSTANCE_ID' ao finalizar."
