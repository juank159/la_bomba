# 🚀 Guía de Importación de Productos

## Archivo Principal

**`importar_productos.py`** - Script interactivo para importar productos

## ¿Cómo usar el script?

### Opción 1: Ejecutar directamente
```bash
python3 importar_productos.py
```

### Opción 2: Ejecutar como script
```bash
./importar_productos.py
```

## 📋 Pasos del Script Interactivo

### 1️⃣ Selector de Archivo CSV

El script buscará automáticamente todos los archivos `.csv` en el directorio y te mostrará una lista:

```
📁 SELECTOR DE ARCHIVO CSV
==================================================

Archivos CSV disponibles:

1. articulos_la bomba.csv
   📊 Tamaño: 0.52 MB
   📅 Modificado: 2025-10-23 15:30:45

2. productos_nuevos.csv
   📊 Tamaño: 0.35 MB
   📅 Modificado: 2025-10-22 10:15:30

Selecciona el número del archivo CSV (1-2) o 'q' para salir:
```

**Simplemente escribe el número del archivo que quieres importar.**

### 2️⃣ Selección de Modo

El script te preguntará qué modo quieres usar:

```
⚙️  OPCIONES DE IMPORTACIÓN
==================================================

¿Qué deseas hacer?

1. Modo Prueba (Dry-Run)
   Solo genera el SQL sin modificar la base de datos
   ✅ Recomendado para la primera vez

2. Importación Real (Con Backup)
   Crea backup y ejecuta la importación
   ✅ Modo seguro recomendado

3. Importación Rápida (Sin Backup)
   Ejecuta sin crear backup
   ⚠️  No recomendado

q. Salir

Selecciona una opción (1-3) o 'q':
```

**Recomendaciones:**
- **Primera vez:** Usa opción `1` (Dry-Run) para probar
- **Normal:** Usa opción `2` (Con Backup) - **LA MÁS SEGURA**
- **Urgente:** Usa opción `3` (Sin Backup) - solo si estás seguro

### 3️⃣ El Script Hace el Resto

El script automáticamente:
- ✅ Lee y valida el CSV
- ✅ Genera el SQL con UPSERT
- ✅ Crea backup (si elegiste la opción 2)
- ✅ Ejecuta la importación
- ✅ Verifica que todo salió bien
- ✅ Te muestra un resumen al final

## 📊 Ejemplo Completo de Uso

```bash
$ python3 importar_productos.py

🚀 IMPORTADOR INTERACTIVO DE PRODUCTOS
==================================================
Sistema de importación segura con UPSERT

📁 SELECTOR DE ARCHIVO CSV
==================================================
Archivos CSV disponibles:

1. articulos_la bomba.csv
   📊 Tamaño: 0.52 MB
   📅 Modificado: 2025-10-23 15:30:45

Selecciona el número del archivo CSV (1-1) o 'q' para salir: 1
✅ Archivo seleccionado: articulos_la bomba.csv

⚙️  OPCIONES DE IMPORTACIÓN
==================================================

¿Qué deseas hacer?

1. Modo Prueba (Dry-Run)
2. Importación Real (Con Backup)
3. Importación Rápida (Sin Backup)

Selecciona una opción (1-3) o 'q': 2

📖 LEYENDO ARCHIVO: articulos_la bomba.csv
==================================================
✅ Productos válidos leídos: 5888

📝 GENERANDO SQL CON UPSERT
==================================================
✅ Archivo SQL generado: upsert_products.sql

💾 CREANDO BACKUP DE SEGURIDAD
==================================================
✅ Backup creado: backup_products_20251023_180532.sql

⚙️  EJECUTANDO SQL EN LA BASE DE DATOS
==================================================
ℹ️  Copiando archivo SQL al contenedor...
ℹ️  Ejecutando SQL...
✅ SQL ejecutado exitosamente!

🔍 VERIFICANDO IMPORTACIÓN
==================================================
ℹ️  Productos activos en BD: 6433
ℹ️  Productos procesados del CSV: 5888
✅ Verificación exitosa!

🎉 IMPORTACIÓN COMPLETADA
==================================================
✅ Total productos procesados: 5888
ℹ️  Log guardado en: import_log_20251023_180532.txt
ℹ️  Backup guardado en: backup_products_20251023_180532.sql

✅ TODO SALIÓ BIEN!
```

## 🎯 Características del Script

### ✅ Visual e Interactivo
- Selector de archivos CSV automático
- Menú de opciones claro
- Mensajes con colores y emojis
- Confirmaciones antes de acciones críticas

### ✅ Seguro
- Backup automático antes de modificar
- Validaciones exhaustivas
- UPSERT (mantiene IDs existentes)
- Transacciones (rollback si falla)
- Modo dry-run para probar

### ✅ Informativo
- Muestra progreso en tiempo real
- Genera logs detallados
- Reporte final con estadísticas
- Indica claramente qué archivos generó

## 📁 Archivos que Genera el Script

Después de ejecutar, encontrarás:

| Archivo | Descripción | ¿Para qué sirve? |
|---------|-------------|------------------|
| `upsert_products.sql` | SQL con UPSERT | Ver los comandos ejecutados |
| `backup_products_YYYYMMDD_HHMMSS.sql` | Backup de products | Restaurar si algo falla |
| `import_log_YYYYMMDD_HHMMSS.txt` | Log detallado | Revisar qué pasó |

## 🔧 Scripts Auxiliares

### `detectar_duplicados.py`
Genera un reporte CSV con todos los barcodes duplicados:
```bash
python3 detectar_duplicados.py
# Genera: reporte_duplicados.csv
```

### `verificar_produccion.sh`
Verifica que todo esté listo para producción:
```bash
./verificar_produccion.sh
```

## ❓ Preguntas Frecuentes

### ¿Puedo ejecutar el script múltiples veces?
**Sí.** El script usa UPSERT, así que es 100% seguro ejecutarlo cuantas veces quieras.

### ¿Qué pasa si hay un error a mitad de la importación?
El script usa transacciones. Si algo falla, hace **ROLLBACK automático** y la BD queda como estaba antes.

### ¿Cómo restauro desde el backup?
```bash
# Encontrar el backup
ls -lt backup_products_*.sql | head -1

# Restaurar
docker cp backup_products_20251023_180532.sql pedidos_db:/tmp/
docker exec pedidos_db psql -U postgres -d pedidos_db -c "TRUNCATE products CASCADE;"
docker exec pedidos_db psql -U postgres -d pedidos_db -f /tmp/backup_products_20251023_180532.sql
```

### ¿Qué hago si el script no encuentra mi CSV?
El script busca archivos `.csv` en el directorio actual. Asegúrate de:
1. Estar en el directorio correcto: `cd /Users/mac/Documents/pedidos/backend`
2. Que tu archivo tenga extensión `.csv`
3. Ejecutar el script desde ese directorio

### ¿Puedo cancelar el script?
**Sí.** En cualquier momento presiona `Ctrl+C` o escribe `q` cuando te lo pregunte.

## 🚨 Resolución de Problemas

### Error: "No se encontraron archivos CSV"
```bash
# Verifica que estás en el directorio correcto
pwd
# Debería mostrar: /Users/mac/Documents/pedidos/backend

# Lista los archivos CSV
ls *.csv
```

### Error: "Contenedor pedidos_db no está corriendo"
```bash
# Verifica que Docker esté corriendo
docker ps

# Si no está, inicia el contenedor
docker-compose up -d
```

### Error: "No se puede conectar a la base de datos"
```bash
# Verifica la conexión
docker exec pedidos_db psql -U postgres -d pedidos_db -c "SELECT 1;"
```

## 📞 Necesitas Ayuda?

1. **Revisa el log:** `cat import_log_*.txt | tail -50`
2. **Busca errores:** `grep ERROR import_log_*.txt`
3. **Ejecuta verificación:** `./verificar_produccion.sh`

## 🎯 Resumen Rápido

```bash
# 1. Ir al directorio
cd /Users/mac/Documents/pedidos/backend

# 2. Ejecutar el script
python3 importar_productos.py

# 3. Seguir las instrucciones en pantalla
#    - Selecciona tu archivo CSV
#    - Selecciona el modo (recomendado: opción 2)
#    - ¡Listo!

# 4. Verificar que todo salió bien
./verificar_produccion.sh
```

**¡Es así de fácil!** 🎉
