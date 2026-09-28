#!/usr/bin/env bash
set -euo pipefail
SOURCE_HOST=${SOURCE_HOST:-127.0.0.1}; SOURCE_DB=${SOURCE_DB:-demo}; DEST_HOST=${DEST_HOST:-127.0.0.1}; DEST_DB=${DEST_DB:-demo_replica}
mysqldump -h "$SOURCE_HOST" -u root -p "$SOURCE_DB" > /tmp/source.sql
mysql -h "$DEST_HOST" -u root -p -e "CREATE DATABASE IF NOT EXISTS \`$DEST_DB\`"
mysql -h "$DEST_HOST" -u root -p "$DEST_DB" < /tmp/source.sql
rm -f /tmp/source.sql
echo 'Copie logique terminée.'
