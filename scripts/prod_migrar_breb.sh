#!/usr/bin/env bash
# Respaldo + migraciones 020 y 021 en PRODUCCIÓN (Bre-B, caja a ciegas, pagos mixtos).
# Uso:  bash backend/scripts/prod_migrar_breb.sh
# Se detiene ante el primer error. Las migraciones son idempotentes.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DB_URL="$(grep -E '^DATABASE_URL=' "$ROOT/.env" | head -1 | cut -d= -f2-)"
[ -n "$DB_URL" ] || { echo "No encontré DATABASE_URL en backend/.env"; exit 1; }

export PGOPTIONS='-c client_min_messages=warning'

BACKUP_DIR="$HOME/Developer/la_bomba_backups"
mkdir -p "$BACKUP_DIR"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$BACKUP_DIR/prod_antes_breb_$STAMP.dump"

echo "== 1/4 Respaldo completo de producción → $BACKUP"
pg_dump "$DB_URL" -Fc -f "$BACKUP"
SIZE=$(wc -c < "$BACKUP")
[ "$SIZE" -gt 10000 ] || { echo "El respaldo quedó muy pequeño ($SIZE bytes). Me detengo."; exit 1; }
pg_restore -l "$BACKUP" > /dev/null
echo "   OK ($(du -h "$BACKUP" | cut -f1))"

echo "== 2/4 Migración 020 (Bre-B + caja a ciegas)"
psql "$DB_URL" -v ON_ERROR_STOP=1 -q -f "$ROOT/src/migrations/020-breb-y-cierre-ciego.sql"

echo "== 3/4 Migración 021 (pagos mixtos + relleno)"
psql "$DB_URL" -v ON_ERROR_STOP=1 -q -f "$ROOT/src/migrations/021-pagos-mixtos.sql"

echo "== 4/4 Verificación"
psql "$DB_URL" -At -F ' | ' -c "
select 'tablas nuevas', concat_ws(', ', to_regclass('breb_config'), to_regclass('breb_pending_charges'),
       to_regclass('breb_unmatched_emails'), to_regclass('vegetable_sale_payments'), to_regclass('invoice_payments'));
select 'ventas verduras / con partes', (select count(*) from vegetable_sales)::text || ' / ' ||
       (select count(distinct sale_id) from vegetable_sale_payments);
select 'facturas / con partes', (select count(*) from invoices)::text || ' / ' ||
       (select count(distinct invoice_id) from invoice_payments);
select 'método Bre-B', coalesce((select name from payment_methods where code='breb'), 'NO EXISTE');
"
echo
echo "LISTO. Respaldo guardado en: $BACKUP"
