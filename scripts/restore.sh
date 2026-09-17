#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/../backups"

DB_SERVICE="${DB_SERVICE:-db}"
DB_USER="${DB_USER:-appadmin}"
RESTORE_DB_NAME="${RESTORE_DB_NAME:-appdb_restore_test}"

BACKUP_FILE="${1:-$(ls -t "${BACKUP_DIR}"/backup_*.dump 2>/dev/null | head -n1)}"

if [[ -z "${BACKUP_FILE}" || ! -f "${BACKUP_FILE}" ]]; then
  echo "No backup file found. Usage: ./scripts/restore.sh [path/to/backup.dump]" >&2
  exit 1
fi

echo "Restoring $(basename "${BACKUP_FILE}") into fresh database '${RESTORE_DB_NAME}'..."

docker compose exec -T "${DB_SERVICE}" dropdb -U "${DB_USER}" --if-exists "${RESTORE_DB_NAME}"
docker compose exec -T "${DB_SERVICE}" createdb -U "${DB_USER}" "${RESTORE_DB_NAME}"
docker compose exec -T "${DB_SERVICE}" pg_restore -U "${DB_USER}" -d "${RESTORE_DB_NAME}" < "${BACKUP_FILE}"

echo "Restore complete into '${RESTORE_DB_NAME}'."
echo
echo "Verify with:"
echo "  docker compose exec ${DB_SERVICE} psql -U ${DB_USER} -d ${RESTORE_DB_NAME} -c \"SELECT COUNT(*) FROM hotel_bookings;\""
