#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../backups"
mkdir -p "${BACKUP_DIR}"

DB_SERVICE="${DB_SERVICE:-db}"
DB_USER="${DB_USER:-appadmin}"
DB_NAME="${DB_NAME:-appdb}"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.dump"

echo "Backing up '${DB_NAME}' from service '${DB_SERVICE}' -> ${BACKUP_FILE}"

docker compose exec -T "${DB_SERVICE}" \
  pg_dump -U "${DB_USER}" -d "${DB_NAME}" -F c > "${BACKUP_FILE}"

echo "Backup complete: ${BACKUP_FILE} ($(du -h "${BACKUP_FILE}" | cut -f1))"
