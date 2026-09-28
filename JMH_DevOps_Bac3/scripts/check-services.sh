#!/usr/bin/env bash
set -euo pipefail
echo '=== Docker ==='
systemctl is-active --quiet docker && echo '[OK] Docker' || echo '[KO] Docker'
echo '=== Conteneurs ==='
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
echo '=== HTTP ==='
for url in http://localhost:8080 http://localhost:8081; do curl -fsS --max-time 5 "$url" >/dev/null 2>&1 && echo "[OK] $url" || echo "[INFO] $url indisponible"; done
