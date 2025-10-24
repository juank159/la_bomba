# Guía de Importación Segura de Productos

## ¿Qué hace este script?

El script `import_csv_safe.py` importa productos desde un archivo CSV usando **UPSERT**, lo que significa:

✅ **Si el producto YA existe** (mismo barcode) → Lo ACTUALIZA manteniendo el mismo ID
✅ **Si el producto NO existe** → Lo INSERTA como nuevo
✅ **NO rompe relaciones** con órdenes existentes
✅ **Crea backup automático** antes de modificar
✅ **Modo de prueba** para revisar antes de aplicar cambios

## 🚨 IMPORTANTE: ANTES DE EJECUTAR

### 1. Primera vez: Probar en modo DRY-RUN

```bash
cd /Users/mac/Documents/pedidos/backend
python3 import_csv_safe.py --dry-run
```

Esto va a:
- ✅ Leer y validar el CSV
- ✅ Generar el archivo SQL
- ✅ Mostrar errores y advertencias
- ❌ **NO modificará la base de datos**

### 2. Revisar el archivo SQL generado

```bash
# Ver las primeras líneas del SQL generado
head -n 50 upsert_products.sql

# O abrirlo en un editor
code upsert_products.sql
```

Verifica que:
- Los barcodes se ven correctos
- Los precios tienen sentido
- Las descripciones están bien

### 3. Si todo se ve bien, ejecutar REAL

```bash
python3 import_csv_safe.py
```

Esto va a:
1. ✅ Validar el CSV
2. ✅ Generar SQL con UPSERT
3. ✅ **Crear backup automático** de la tabla products
4. ✅ Ejecutar la importación
5. ✅ Verificar que todo se importó correctamente

## 📋 Opciones del Script

### Modo DRY-RUN (Prueba sin modificar)
```bash
python3 import_csv_safe.py --dry-run
```
**Usa esto SIEMPRE la primera vez**

### Importación normal (con backup)
```bash
python3 import_csv_safe.py
```
**Este es el modo recomendado**

### Sin backup (NO RECOMENDADO)
```bash
python3 import_csv_safe.py --no-backup
```
**Solo usa esto si sabes lo que haces**

## 📊 Qué archivos genera

Después de ejecutar, verás estos archivos:

| Archivo | Descripción |
|---------|-------------|
| `upsert_products.sql` | SQL con los comandos UPSERT |
| `backup_products_YYYYMMDD_HHMMSS.sql` | Backup de la tabla products |
| `import_log_YYYYMMDD_HHMMSS.txt` | Log detallado de la ejecución |

## 🔍 Cómo leer el LOG

El archivo de log te muestra:

```
[2025-10-23 10:30:15] [INFO] Leyendo archivo CSV: articulos_la bomba.csv
[2025-10-23 10:30:15] [WARNING] Fila 42: PrecioA vacío, usando 1000.0 por defecto
[2025-10-23 10:30:15] [ERROR] Fila 55: Barcode vacío
[2025-10-23 10:30:16] [SUCCESS] CSV validado correctamente: 1234 productos
```

### Niveles de log:
- **INFO**: Información general
- **WARNING**: Advertencia (no crítico, pero deberías revisar)
- **ERROR**: Error crítico (producto no se importará)
- **SUCCESS**: Operación exitosa

## 🛡️ Seguridad

### El script tiene estas protecciones:

1. **Validaciones estrictas**
   - Barcodes duplicados en el CSV
   - Productos sin precio
   - Datos malformados
   - Formato científico en números

2. **Backup automático**
   - Se crea antes de cualquier cambio
   - Puedes restaurarlo si algo sale mal

3. **Transacciones**
   - Todo se ejecuta en una transacción
   - Si algo falla, se hace ROLLBACK automático
   - Todo o nada

4. **Modo dry-run**
   - Prueba sin riesgo
   - Revisa el SQL antes de ejecutar

## 🚑 Si algo sale mal

### Restaurar desde el backup

Si necesitas restaurar la tabla:

```bash
# Encontrar el backup más reciente
ls -lt backup_products_*.sql | head -1

# Restaurar (CUIDADO: esto reemplaza la tabla actual)
docker cp backup_products_20251023_103015.sql pedidos_db:/tmp/
docker exec pedidos_db psql -U postgres -d pedidos_db -c "TRUNCATE products CASCADE;"
docker exec pedidos_db psql -U postgres -d pedidos_db -f /tmp/backup_products_20251023_103015.sql
```

### Ver errores en el log

```bash
# Ver solo errores
grep ERROR import_log_*.txt

# Ver últimas líneas del log
tail -n 50 import_log_20251023_103015.txt
```

## 📝 Ejemplo de uso completo

```bash
# Paso 1: Ir al directorio del backend
cd /Users/mac/Documents/pedidos/backend

# Paso 2: Asegurarte de que el CSV esté actualizado
ls -lh "articulos_la bomba.csv"

# Paso 3: Probar en modo dry-run
python3 import_csv_safe.py --dry-run

# Paso 4: Revisar el log
cat import_log_*.txt | tail -20

# Paso 5: Si todo se ve bien, ejecutar de verdad
python3 import_csv_safe.py

# Paso 6: Verificar en la base de datos
docker exec pedidos_db psql -U postgres -d pedidos_db -c "SELECT COUNT(*) FROM products WHERE \"isActive\" = true;"
```

## ❓ Preguntas Frecuentes

### ¿Qué pasa con los productos que ya existen?
Se actualizan sus datos (precio, descripción, etc.) pero **mantienen el mismo ID**, por lo que las relaciones con órdenes NO se rompen.

### ¿Qué pasa con los productos que ya no están en el CSV?
NO se eliminan automáticamente. Se quedan en la BD con sus datos antiguos. Si quieres desactivarlos, contacta al desarrollador.

### ¿Puedo ejecutar el script múltiples veces?
Sí, es 100% seguro. Puedes ejecutarlo todas las veces que quieras. Siempre hace UPSERT.

### ¿Qué pasa si hay un error a mitad de la importación?
Todo se ejecuta en una transacción. Si hay un error, se hace ROLLBACK automático y la BD queda como estaba antes.

### ¿Cuánto tarda?
Depende del tamaño del CSV. Aproximadamente:
- 100 productos: ~2 segundos
- 1,000 productos: ~10 segundos
- 10,000 productos: ~1 minuto

## 🎯 Checklist antes de ejecutar en producción

- [ ] Ejecuté dry-run y revisé el log
- [ ] Revisé el archivo SQL generado
- [ ] Verifiqué que el contenedor de Docker está corriendo
- [ ] Tengo espacio en disco para el backup
- [ ] Notifiqué al equipo que voy a actualizar productos
- [ ] Estoy listo para revisar el log después de la ejecución

## 📞 Soporte

Si tienes problemas:
1. Revisa el archivo de log
2. Busca errores con `grep ERROR import_log_*.txt`
3. Si es crítico, restaura desde el backup
4. Contacta al desarrollador con el log completo
