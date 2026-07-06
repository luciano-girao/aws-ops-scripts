# aws-ops-scripts

> Scripts Bash focados em operações AWS: automação de EC2, segurança e infraestrutura em nuvem.

![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

---

## 📌 Sobre o projeto

Repositório com scripts Bash voltados para operações do dia a dia em ambientes AWS. O objetivo é demonstrar práticas de automação, segurança e provisionamento de infraestrutura usando AWS CLI e Shell Script.

Ideal para estudo de **Cloud Operations**, **NOC** e **Cloud Support**.

---

## 📂 Estrutura do repositório

```
aws-ops-scripts/
├── ec2/
│   ├── create-lab-instance.sh       # Cria instância EC2 para laboratório
│   ├── start-stop-instance.sh       # Inicia ou para instância por ID
│   └── list-instances.sh            # Lista instâncias com status
├── security/
│   ├── close-open-ports.sh          # Fecha portas expostas em Security Groups
│   ├── audit-security-groups.sh     # Audita regras de SG e gera relatório
│   └── enable-mfa-check.sh          # Verifica usuários IAM sem MFA
├── services/
│   ├── install-apache.sh            # Instala e configura Apache no EC2
│   └── install-nginx.sh             # Instala e configura Nginx no EC2
└── README.md
```

---

## 🚀 Scripts principais

### ec2/create-lab-instance.sh
Cria uma instância EC2 Amazon Linux 2 para uso em laboratórios, com tags de identificação automáticas.

**Pré-requisitos:** AWS CLI configurado, permissões EC2

```bash
#!/bin/bash
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t2.micro \
  --key-name minha-chave \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=lab-instance}]'
```

---

### security/close-open-ports.sh
Verifica Security Groups com portas sensíveis expostas para `0.0.0.0/0` (SSH 22, RDP 3389) e revoga as regras.

```bash
#!/bin/bash
SG_ID=$1
aws ec2 revoke-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
echo "Porta 22 fechada para acesso público no SG: $SG_ID"
```

---

### security/enable-mfa-check.sh
Lista todos os usuários IAM que **não possuem MFA habilitado**, útil para auditorias de segurança.

```bash
#!/bin/bash
echo "Usuários IAM sem MFA:"
aws iam list-users --query 'Users[*].UserName' --output text | tr '\t' '\n' | while read user; do
  mfa=$(aws iam list-mfa-devices --user-name "$user" --query 'MFADevices' --output text)
  if [ -z "$mfa" ]; then
    echo "  - $user"
  fi
done
```

---

## 🛠️ Pré-requisitos

- AWS CLI v2 instalado e configurado (`aws configure`)
- Usuário/role IAM com as permissões necessárias
- Bash (Linux/macOS ou WSL no Windows)

---

## 📚 O que aprendi com esse projeto

- Automação de tarefas repetitivas com AWS CLI + Bash
- Boas práticas de segurança: MFA, portas fechadas, princípio do menor privilégio
- Provisionamento rápido de ambientes de laboratório
- Troubleshooting de conectividade via Security Groups

---

## 👤 Autor

**Luciano Henrique Morais Girão**  
[LinkedIn](https://www.linkedin.com/in/lucianogirao) • [GitHub](https://github.com/lucianowtp1-stack)
