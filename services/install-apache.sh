#!/bin/bash
# =============================================================
# install-apache.sh
# Instala e configura o Apache HTTP Server no Amazon Linux 2
# Autor: Luciano Girao | github.com/luciano-girao
# =============================================================

set -euo pipefail

echo "[INFO] Iniciando instalacao do Apache..."

# Atualiza pacotes
yum update -y

# Instala Apache
yum install -y httpd

# Inicia e habilita na inicializacao
systemctl start httpd
systemctl enable httpd

# Cria pagina de teste
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>Lab Apache - $(hostname)</title></head>
<body>
  <h1>Apache rodando com sucesso!</h1>
  <p>Servidor: $(hostname -f)</p>
  <p>IP: $(curl -s http://checkip.amazonaws.com)</p>
</body>
</html>
EOF

# Verifica status
STATUS=$(systemctl is-active httpd)
echo "[OK] Apache instalado e ativo: $STATUS"
echo "[INFO] Acesse: http://$(curl -s http://checkip.amazonaws.com)"
