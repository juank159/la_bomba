-- =====================================================================
-- MIGRACIÓN SEGURA: Hacer barcode nullable en productos
-- Fecha: 2025-10-26
-- IMPORTANTE: Esta migración NO afecta datos existentes
-- =====================================================================

-- PASO 1: Verificar estructura actual
-- Esto mostrará cómo está la columna barcode ANTES de la migración
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 1: Verificando estructura ACTUAL de la tabla products'
\echo '═══════════════════════════════════════════════════════════════'
\d products

-- PASO 2: Crear tabla de backup de seguridad
-- Esto guardará una copia de todos los productos antes de la migración
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 2: Creando backup de seguridad (products_backup_20251026)'
\echo '═══════════════════════════════════════════════════════════════'

-- Eliminar backup anterior si existe
DROP TABLE IF EXISTS products_backup_20251026;

-- Crear backup con todos los datos actuales
CREATE TABLE products_backup_20251026 AS
SELECT * FROM products;

-- Verificar que el backup tiene los mismos datos
\echo 'Backup creado. Verificando cantidad de registros:'
SELECT
    (SELECT COUNT(*) FROM products) as productos_originales,
    (SELECT COUNT(*) FROM products_backup_20251026) as productos_en_backup;

-- PASO 3: Ejecutar la migración
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 3: Ejecutando migración (hacer barcode nullable)'
\echo '═══════════════════════════════════════════════════════════════'

-- Esta es la migración principal - Solo cambia la restricción
ALTER TABLE products
ALTER COLUMN barcode DROP NOT NULL;

-- Agregar comentario explicativo
COMMENT ON COLUMN products.barcode IS 'Product barcode - nullable to allow supervisor to add it later';

\echo 'Migración ejecutada exitosamente!'

-- PASO 4: Verificar que la migración se aplicó correctamente
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 4: Verificando estructura DESPUÉS de la migración'
\echo '═══════════════════════════════════════════════════════════════'
\d products

-- PASO 5: Verificar que NO se perdieron datos
\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo 'PASO 5: Verificando que NO se perdieron datos'
\echo '═══════════════════════════════════════════════════════════════'

SELECT
    COUNT(*) as total_productos,
    COUNT(CASE WHEN barcode IS NOT NULL THEN 1 END) as productos_con_barcode,
    COUNT(CASE WHEN barcode IS NULL THEN 1 END) as productos_sin_barcode
FROM products;

\echo ''
\echo '═══════════════════════════════════════════════════════════════'
\echo '✅ MIGRACIÓN COMPLETADA EXITOSAMENTE'
\echo '═══════════════════════════════════════════════════════════════'
\echo ''
\echo '📊 RESUMEN:'
\echo '  - Backup guardado en: products_backup_20251026'
\echo '  - Columna barcode ahora permite valores NULL'
\echo '  - Todos los datos existentes se conservaron'
\echo ''
\echo '🔄 Si necesitas revertir la migración, ejecuta:'
\echo '  ALTER TABLE products ALTER COLUMN barcode SET NOT NULL;'
\echo ''
\echo '🗑️  Para eliminar el backup cuando estés seguro:'
\echo '  DROP TABLE products_backup_20251026;'
\echo ''
