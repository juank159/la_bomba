#!/bin/bash
# Script de verificación pre-producción
# Ejecuta este script antes de desplegar a producción

echo "======================================================================"
echo "  VERIFICACIÓN PRE-PRODUCCIÓN - Sistema de Productos"
echo "======================================================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Contador de verificaciones
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

check_pass() {
    echo -e "${GREEN}✅ PASS${NC} - $1"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC} - $1"
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC} - $1"
}

echo "1. Verificando contenedor de Docker..."
if docker ps | grep -q "pedidos_db"; then
    check_pass "Contenedor pedidos_db está corriendo"
else
    check_fail "Contenedor pedidos_db NO está corriendo"
    exit 1
fi
echo ""

echo "2. Verificando conexión a la base de datos..."
if docker exec pedidos_db psql -U postgres -d pedidos_db -c "SELECT 1;" > /dev/null 2>&1; then
    check_pass "Conexión a base de datos exitosa"
else
    check_fail "No se puede conectar a la base de datos"
    exit 1
fi
echo ""

echo "3. Verificando integridad de productos..."
PRODUCT_COUNT=$(docker exec pedidos_db psql -U postgres -d pedidos_db -t -c "SELECT COUNT(*) FROM products WHERE \"isActive\" = true;")
PRODUCT_COUNT=$(echo $PRODUCT_COUNT | tr -d ' ')
if [ "$PRODUCT_COUNT" -gt 0 ]; then
    check_pass "Productos activos en BD: $PRODUCT_COUNT"
else
    check_fail "No hay productos activos en la BD"
fi
echo ""

echo "4. Verificando unicidad de barcodes..."
BARCODE_CHECK=$(docker exec pedidos_db psql -U postgres -d pedidos_db -t -c "
    SELECT COUNT(*) FROM (
        SELECT barcode, COUNT(*) as cnt
        FROM products
        GROUP BY barcode
        HAVING COUNT(*) > 1
    ) duplicates;
")
BARCODE_CHECK=$(echo $BARCODE_CHECK | tr -d ' ')
if [ "$BARCODE_CHECK" -eq 0 ]; then
    check_pass "Todos los barcodes son únicos"
else
    check_fail "Hay $BARCODE_CHECK barcodes duplicados en la BD"
fi
echo ""

echo "5. Verificando relaciones con order_items..."
ORDER_ITEMS=$(docker exec pedidos_db psql -U postgres -d pedidos_db -t -c "SELECT COUNT(*) FROM order_items WHERE product_id IS NOT NULL;")
ORDER_ITEMS=$(echo $ORDER_ITEMS | tr -d ' ')

BROKEN_RELATIONS=$(docker exec pedidos_db psql -U postgres -d pedidos_db -t -c "
    SELECT COUNT(*)
    FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.id
    WHERE oi.product_id IS NOT NULL AND p.id IS NULL;
")
BROKEN_RELATIONS=$(echo $BROKEN_RELATIONS | tr -d ' ')

if [ "$BROKEN_RELATIONS" -eq 0 ]; then
    check_pass "Todas las relaciones order_items -> products están intactas ($ORDER_ITEMS items)"
else
    check_fail "Hay $BROKEN_RELATIONS relaciones rotas entre order_items y products"
fi
echo ""

echo "6. Verificando productos sin precio..."
NO_PRICE=$(docker exec pedidos_db psql -U postgres -d pedidos_db -t -c "SELECT COUNT(*) FROM products WHERE precioa = 0 AND \"isActive\" = true;")
NO_PRICE=$(echo $NO_PRICE | tr -d ' ')
if [ "$NO_PRICE" -eq 0 ]; then
    check_pass "Todos los productos tienen precio válido"
else
    check_warn "Hay $NO_PRICE productos activos con precio 0 (revisar si es intencional)"
fi
echo ""

echo "7. Verificando existencia de backup..."
if ls backup_products_*.sql 1> /dev/null 2>&1; then
    LATEST_BACKUP=$(ls -t backup_products_*.sql | head -1)
    BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)
    check_pass "Backup disponible: $LATEST_BACKUP ($BACKUP_SIZE)"
else
    check_fail "No se encontró backup de seguridad"
fi
echo ""

echo "8. Verificando logs de importación..."
if ls import_log_*.txt 1> /dev/null 2>&1; then
    LATEST_LOG=$(ls -t import_log_*.txt | head -1)
    LOG_ERRORS=$(grep -c "ERROR" "$LATEST_LOG" || echo "0")
    if [ "$LOG_ERRORS" -le 5 ]; then
        check_pass "Log de importación disponible con $LOG_ERRORS errores"
    else
        check_warn "Log tiene $LOG_ERRORS errores (revisar manualmente)"
    fi
else
    check_warn "No se encontraron logs de importación"
fi
echo ""

echo "======================================================================"
echo "  RESUMEN DE VERIFICACIÓN"
echo "======================================================================"
echo "Total de verificaciones: $TOTAL_CHECKS"
echo -e "${GREEN}Exitosas: $PASSED_CHECKS${NC}"
echo -e "${RED}Fallidas: $FAILED_CHECKS${NC}"
echo ""

if [ "$FAILED_CHECKS" -eq 0 ]; then
    echo -e "${GREEN}✅ SISTEMA LISTO PARA PRODUCCIÓN${NC}"
    echo ""
    echo "Pasos siguientes:"
    echo "1. Notifica al equipo sobre el despliegue"
    echo "2. Ejecuta en horario de bajo tráfico"
    echo "3. Monitorea la aplicación después del despliegue"
    echo ""
    exit 0
else
    echo -e "${RED}❌ SISTEMA NO ESTÁ LISTO PARA PRODUCCIÓN${NC}"
    echo ""
    echo "Por favor corrige los errores antes de desplegar."
    echo ""
    exit 1
fi
