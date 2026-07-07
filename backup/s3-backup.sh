#!/bin/bash
# =============================================================
# Script: s3-backup.sh
# Description: Realiza backup de diretorio local para S3
# Author: Luciano Girao
# Date: 2025
# Usage: ./s3-backup.sh /caminho/origem s3://meu-bucket/destino
# =============================================================

set -euo pipefail

SOURCE_DIR=${1:-"/var/www/html"}
S3_BUCKET=${2:-"s3://meu-bucket-backup"}
DATE=$(date '+%Y-%m-%d')
LOG_FILE="/var/log/s3-backup.log"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando backup..."
echo "Origem : $SOURCE_DIR"
echo "Destino: $S3_BUCKET/backup-$DATE/"

# Verifica se AWS CLI esta disponivel
if ! command -v aws &>/dev/null; then
  echo "ERRO: AWS CLI nao encontrado. Instale antes de continuar."
  exit 1
fi

# Verifica se o diretorio existe
if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERRO: Diretorio '$SOURCE_DIR' nao encontrado."
  exit 1
fi

# Faz o sync para o S3
aws s3 sync "$SOURCE_DIR" "$S3_BUCKET/backup-$DATE/" \
  --delete \
  --storage-class STANDARD_IA

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup concluido com sucesso!"
echo "Arquivos enviados para: $S3_BUCKET/backup-$DATE/"
