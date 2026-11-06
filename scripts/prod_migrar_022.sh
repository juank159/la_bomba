#!/usr/bin/env bash
# Migración 022 en PRODUCCIÓN: columna para el token de notificaciones web.
# Uso:  bash backend/scripts/prod_migrar_022.sh
# Correr ANTES de subir el backend que la usa. Idempotente.
set -euo pipefail
export PGOPTIONS='-c client_min_messages=warning'

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB_URL="$(grep -E '^DATABASE_URL=' "$ROOT/.env" | head -1 | cut -d= -f2-)"
[ -n "$DB_URL" ] || { echo "No encontré DATABASE_URL en backend/.env"; exit 1; }

echo "== Migración 022 (token web)"
psql "$DB_URL" -v ON_ERROR_STOP=1 -q -f "$ROOT/src/migrations/022-web-push-token.sql"

echo "== Verificación"
psql "$DB_URL" -At -c "select 'columna webFcmToken: ' || coalesce((select data_type from information_schema.columns where table_name='users' and column_name='webFcmToken'), 'NO EXISTE');"
echo "LISTO."
