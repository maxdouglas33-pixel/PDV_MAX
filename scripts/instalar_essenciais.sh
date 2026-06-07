#!/bin/bash

# =====================================================================
# SCRIPT DE CONFIGURAÇÃO INICIAL - CONTAS PAGAR CONNECT
# Sistema: Ubuntu Server 24.04 LTS
# Foco: Atualização, Timezone (Belém) e Sincronização NTP (NTP.br)
# =====================================================================

echo "=========================================="
echo "1. Atualizando as listas de pacotes e o sistema..."
echo "=========================================="
apt-get update -y && apt-get upgrade -y

echo "=========================================="
echo "2. Instalando o htop, ntpsec e ntpsec-ntpdate..."
echo "=========================================="
# No Ubuntu 24.04, o 'ntp' clássico foi substituído pelo 'ntpsec'
apt-get install -y htop ntpsec ntpsec-ntpdate

echo "=========================================="
echo "3. Configurando o Timezone para America/Belem..."
echo "=========================================="
timedatectl set-timezone America/Belem
echo "Timezone atualizado para:"
timedatectl

echo "=========================================="
echo "4. Realizando a primeira sincronização forçada com ntp.br..."
echo "=========================================="
systemctl stop ntpsec
ntpdate a.ntp.br
systemctl start ntpsec

echo "=========================================="
echo "5. Configurando os servidores do NTP.br no ntp.conf..."
echo "=========================================="
# O caminho correto no Ubuntu 24.04 é /etc/ntpsec/ntp.conf
ARCHIVE_CONF="/etc/ntpsec/ntp.conf"

if [ -f "$ARCHIVE_CONF" ]; then
    # Faz backup do arquivo original por segurança
    cp "$ARCHIVE_CONF" "${ARCHIVE_CONF}.bak"

    # Comenta os servidores padrões do Ubuntu pool
    sed -i 's/^pool /# pool /g' "$ARCHIVE_CONF"
    sed -i 's/^server /# server /g' "$ARCHIVE_CONF"

    # Adiciona os servidores do NTP.br no topo do arquivo
    sed -i '1s/^/server a.ntp.br iburst\nserver b.ntp.br iburst\nserver c.ntp.br iburst\n\n/' "$ARCHIVE_CONF"
    
    echo "Arquivo ntp.conf atualizado com sucesso!"
else
    echo "[ERRO] Arquivo de configuração em $ARCHIVE_CONF não encontrado."
fi

echo "=========================================="
echo "6. Reiniciando o serviço NTP para aplicar as mudanças..."
echo "=========================================="
systemctl restart ntpsec

echo "=========================================="
echo "Status do serviço NTP:"
echo "=========================================="
systemctl status ntpsec --no-pager

echo "=========================================="
echo "Script finalizado com sucesso!"
echo "=========================================="
