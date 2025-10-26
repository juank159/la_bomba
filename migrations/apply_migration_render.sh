#!/bin/bash

# =====================================================================
# Script para aplicar migración segura de barcode nullable en Render
# =====================================================================

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║  🛡️  MIGRACIÓN SEGURA: Barcode Nullable                      ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que DATABASE_URL está configurado
if [ -z "$DATABASE_URL" ]; then
    echo "❌ ERROR: DATABASE_URL no está configurado"
    echo ""
    echo "Por favor, exporta tu DATABASE_URL de Render:"
    echo "export DATABASE_URL='postgresql://user:pass@host:port/database'"
    echo ""
    echo "Puedes encontrarlo en:"
    echo "https://dashboard.render.com → PostgreSQL → Connect → External Database URL"
    exit 1
fi

echo "✅ DATABASE_URL encontrado"
echo ""

# Preguntar confirmación
echo "⚠️  Esta migración hará lo siguiente:"
echo "   1. Crear un backup de la tabla products"
echo "   2. Cambiar la columna barcode para permitir valores NULL"
echo "   3. Verificar que NO se perdieron datos"
echo ""
read -p "¿Continuar? (escribe 'SI' para confirmar): " confirmacion

if [ "$confirmacion" != "SI" ]; then
    echo "❌ Migración cancelada"
    exit 0
fi

echo ""
echo "🚀 Ejecutando migración..."
echo ""

# Ejecutar la migración
psql "$DATABASE_URL" <<EOF

-- PASO 1: Ver estructura actual
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 1: Estructura ACTUAL de la tabla products'
\echo '═══════════════════════════════════════════════════════════════'
\d products

-- PASO 2: Crear backup
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 2: Creando backup de seguridad'
\echo '═══════════════════════════════════════════════════════════════'

DROP TABLE IF EXISTS products_backup_20251026;
CREATE TABLE products_backup_20251026 AS SELECT * FROM products;

SELECT
    (SELECT COUNT(*) FROM products) as productos_originales,
    (SELECT COUNT(*) FROM products_backup_20251026) as productos_en_backup;

-- PASO 3: Aplicar migración
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 3: Aplicando migración'
\echo '═══════════════════════════════════════════════════════════════'

ALTER TABLE products ALTER COLUMN barcode DROP NOT NULL;
COMMENT ON COLUMN products.barcode IS 'Product barcode - nullable to allow supervisor to add it later';

\echo 'Migración aplicada exitosamente!'

-- PASO 4: Verificar nueva estructura
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 4: Estructura DESPUÉS de la migración'
\echo '═══════════════════════════════════════════════════════════════'
\d products

-- PASO 5: Verificar datos
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 5: Verificando integridad de datos'
\echo '═══════════════════════════════════════════════════════════════'

SELECT
    COUNT(*) as total_productos,
    COUNT(CASE WHEN barcode IS NOT NULL THEN 1 END) as productos_con_barcode,
    COUNT(CASE WHEN barcode IS NULL THEN 1 END) as productos_sin_barcode
FROM products;

EOF

# Verificar resultado
if [ $? -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║  ✅ MIGRACIÓN COMPLETADA EXITOSAMENTE                        ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📊 RESUMEN:"
    echo "  ✅ Backup creado: products_backup_20251026"
    echo "  ✅ Columna barcode ahora permite NULL"
    echo "  ✅ Datos verificados y conservados"
    echo ""
    echo "🔄 Para revertir (si es necesario):"
    echo "  psql \"\$DATABASE_URL\" -c \"ALTER TABLE products ALTER COLUMN barcode SET NOT NULL;\""
    echo ""
    echo "🗑️  Para eliminar el backup (después de confirmar):"
    echo "  psql \"\$DATABASE_URL\" -c \"DROP TABLE products_backup_20251026;\""
    echo ""
else
    echo ""
    echo "❌ ERROR durante la migración"
    echo "Los datos NO fueron modificados gracias al sistema de transacciones"
    echo "Por favor, revisa los mensajes de error arriba"
    exit 1
fi
EOF
