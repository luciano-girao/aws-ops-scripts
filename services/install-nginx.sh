#!/bin/bash
# =============================================================
# Script: install-nginx.sh
# Description: Instala e configura o servidor web NGINX na EC2
# Author: Luciano Girao
# Date: 2025
# =============================================================

set -euo pipefail

LOG_FILE="/var/log/install-nginx.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Iniciando instalacao do NGINX..."

# Atualiza pacotes
yum update -y

# Instala NGINX
amazon-linux-extras install nginx1 -y || yum install -y nginx

# Inicia e habilita na inicializacao
systemctl start nginx
systemctl enable nginx

# Cria pagina de teste
cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Lab NGINX - $(hostname)</title></head>
<body>
  <h1>NGINX rodando com sucesso!</h1>
  <p>Servidor: $(hostname -f)</p>
  <p>IP: $(curl -s http://checkip.amazonaws.com)</p>
</body>
</html>
EOF

# Verifica status
STATUS=$(systemctl is-active nginx)
if [ "$STATUS" = "active" ]; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] NGINX instalado com sucesso! Status: $STATUS"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERRO: NGINX nao iniciou corretamente."
  exit 1
fi
