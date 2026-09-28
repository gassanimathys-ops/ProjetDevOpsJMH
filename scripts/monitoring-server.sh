#!/usr/bin/env bash
set -euo pipefail
if [[ $EUID -ne 0 ]]; then echo 'Lancez avec sudo/root.'; exit 1; fi
apt-get update
apt-get install -y docker.io docker-compose-plugin curl ca-certificates
systemctl enable --now docker 2>/dev/null || systemctl enable --now docker
mkdir -p /opt/jmh-monitoring
cp docker-compose.yml /opt/jmh-monitoring/ 2>/dev/null || true
cd /opt/jmh-monitoring
if [[ ! -f docker-compose.yml ]]; then echo 'Copiez docker/zabbix/docker-compose.yml ici.'; exit 1; fi
docker compose up -d
docker compose ps
