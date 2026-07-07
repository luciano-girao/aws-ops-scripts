#!/bin/bash
# =============================================================
# Script: s3-backup.sh
# Description: Realiza backup de diretorio local para S3
# Author: Luciano Girao
# Date: 2025
# Usage: ./s3-backup.sh /caminho/origem s3://meu-bucket/destino [--delete]
#
# AVISO DE SEGURANCA:
# O flag --delete remove arquivos do S3 que nao existem mais na origem.
# Use com extrema cautela. Por padrao, esta DESATIVADO neste script.
# Passe o flag --delete como 3o argumento para ativa-lo explicitamente.
# =============================================================

set -euo pipefail

SOURCE_DIR=${1:-"/var/www/html"}
S3_BUCKET=${2:-"s3://meu-bucket-backup"}
ENABLE_DELETE=${3:-""}
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

# Monta o comando de sync
# NOTA: --delete NAO e usado por padrao para proteger o backup de
# delecoes acidentais. Passe '--delete' como 3o argumento se necessario.
SYNC_CMD="aws s3 sync \"$SOURCE_DIR\" \"$S3_BUCKET/backup-$DATE/\" --storage-class STANDARD_IA"

if [ "$ENABLE_DELETE" = "--delete" ]; then
  echo "[AVISO] Flag --delete ativado. Arquivos removidos da origem serao deletados do S3."
  SYNC_CMD="$SYNC_CMD --delete"
fi

# Executa o sync
eval "$SYNC_CMD"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup concluido com sucesso!"
echo "Arquivos enviados para: $S3_BUCKET/backup-$DATE/"
