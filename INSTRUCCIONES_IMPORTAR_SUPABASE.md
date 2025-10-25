# 🚀 INSTRUCCIONES: IMPORTAR PRODUCTOS A SUPABASE

## 📋 PASO 1: Instalar dependencias

Antes de ejecutar el script, necesitas instalar `psycopg2` (driver de PostgreSQL para Python):

```bash
cd /Users/mac/Documents/pedidos/backend

# Opción 1: psycopg2-binary (más fácil, recomendado)
pip3 install psycopg2-binary

# O si tienes problemas:
pip install psycopg2-binary
```

## 📁 PASO 2: Preparar tu archivo CSV

1. Coloca tu archivo CSV de productos en `/Users/mac/Documents/pedidos/backend/`

2. El CSV debe tener este formato (separado por `;`):

```
nombre;referencias;precioa;preciob;precioc;costo;iva
Coca Cola 350ml;7702004004729;2500;2300;2100;1800;19% IVA Incluido
```

**Columnas requeridas:**
- `nombre`: Descripción del producto
- `referencias`: Código de barras (barcode)
- `precioa`: Precio principal (OBLIGATORIO)
- `preciob`: Precio secundario (opcional)
- `precioc`: Precio terciario (opcional)
- `costo`: Costo del producto (opcional)
- `iva`: Porcentaje de IVA (ej: "19% IVA Incluido", "0% Excluido")

## ⚙️ PASO 3: Ejecutar el script

```bash
cd /Users/mac/Documents/pedidos/backend

# Hacer el script ejecutable
chmod +x importar_productos_supabase.py

# Ejecutar
python3 importar_productos_supabase.py
```

## 📖 PASO 4: Seguir el menú interactivo

El script te mostrará un menú con 3 opciones:

### 1️⃣ Modo Prueba (Dry-Run) - **RECOMENDADO PRIMERO**

```
✅ Qué hace:
   - Lee el CSV
   - Valida los productos
   - Genera el archivo SQL (upsert_products.sql)
   - NO modifica la base de datos

👉 Úsalo primero para verificar que todo esté bien
```

### 2️⃣ Importación Real (Con Backup) - **RECOMENDADO**

```
✅ Qué hace:
   - Crea un backup automático de los productos actuales
   - Ejecuta la importación
   - Verifica que todo se importó correctamente

📁 El backup se guarda como: backup_products_YYYYMMDD_HHMMSS.sql
```

### 3️⃣ Importación Rápida (Sin Backup) - **NO RECOMENDADO**

```
⚠️ Qué hace:
   - Importa directamente sin crear backup
   - Más rápido pero menos seguro
```

## ✨ CARACTERÍSTICAS DEL IMPORTADOR

- ✅ **UPSERT automático**: Si el producto ya existe (mismo barcode), lo actualiza. Si no existe, lo crea.
- ✅ **Preserva IDs**: No duplica productos, mantiene los IDs existentes
- ✅ **Validaciones robustas**: Detecta errores en el CSV antes de importar
- ✅ **Backup automático**: Guarda una copia de seguridad antes de modificar
- ✅ **Logs detallados**: Genera archivo de log con toda la info
- ✅ **Manejo de errores**: Si un producto tiene error, lo omite y continúa

## 📊 EJEMPLO DE USO

```bash
$ python3 importar_productos_supabase.py

══════════════════════════════════════════════════════════════
  🚀 IMPORTADOR DE PRODUCTOS PARA SUPABASE
══════════════════════════════════════════════════════════════

ℹ️ Verificando conexión a Supabase...
✅ Conexión a Supabase exitosa!

══════════════════════════════════════════════════════════════
  📁 SELECTOR DE ARCHIVO CSV
══════════════════════════════════════════════════════════════

Archivos CSV disponibles:

1. productos_2025.csv
   📊 Tamaño: 1.25 MB
   📅 Modificado: 2025-10-25 14:30:00

Selecciona el número del archivo CSV (1-1) o 'q' para salir: 1
✅ Archivo seleccionado: productos_2025.csv

══════════════════════════════════════════════════════════════
  ⚙️ OPCIONES DE IMPORTACIÓN
══════════════════════════════════════════════════════════════

¿Qué deseas hacer?

1. Modo Prueba (Dry-Run)
   Solo genera el SQL sin modificar la base de datos
   ✅ Recomendado para la primera vez

2. Importación Real (Con Backup)
   Crea backup y ejecuta la importación
   ✅ Modo seguro recomendado

3. Importación Rápida (Sin Backup)
   Ejecuta sin crear backup
   ⚠️ No recomendado

q. Salir

Selecciona una opción (1-3) o 'q': 2

... (el script ejecuta la importación)

══════════════════════════════════════════════════════════════
  🎉 IMPORTACIÓN COMPLETADA
══════════════════════════════════════════════════════════════

✅ Total productos procesados: 1,234
ℹ️ Log guardado en: import_log_20251025_143500.txt
ℹ️ Backup guardado en: backup_products_20251025_143500.sql

✅ TODO SALIÓ BIEN!
```

## 🔧 CONFIGURACIÓN DE SUPABASE

El script está preconfigurado con las credenciales de Supabase:

```python
SUPABASE_CONFIG = {
    'host': 'aws-1-us-east-1.pooler.supabase.com',
    'port': 6543,
    'database': 'postgres',
    'user': 'postgres.yeeziftpvdmiuljncbva',
    'password': 'Bauduty0159',
}
```

**No necesitas cambiar nada**, el script se conecta automáticamente.

## ⚠️ SOLUCIÓN DE PROBLEMAS

### Error: `ModuleNotFoundError: No module named 'psycopg2'`

```bash
pip3 install psycopg2-binary
```

### Error: `could not connect to server`

- Verifica que tengas internet
- Verifica que las credenciales de Supabase sean correctas
- Asegúrate de que el firewall no bloquee el puerto 6543

### Error: `No se encontraron archivos CSV`

- Verifica que tu archivo .csv esté en el directorio `backend/`
- El script busca archivos con extensión `.csv`

### Productos duplicados

El script usa **UPSERT** basado en el `barcode`:
- Si el barcode ya existe → Actualiza el producto
- Si el barcode no existe → Crea producto nuevo
- **NO duplica productos**

## 📝 ARCHIVOS GENERADOS

Después de ejecutar, encontrarás:

```
backend/
├── upsert_products.sql          # SQL generado
├── import_log_YYYYMMDD_HHMMSS.txt  # Log de la operación
└── backup_products_YYYYMMDD_HHMMSS.sql  # Backup (si usaste opción 2)
```

## 🔄 RESTAURAR DESDE BACKUP

Si algo sale mal y necesitas restaurar:

```bash
# Conectar a Supabase y ejecutar el backup
psql -h aws-1-us-east-1.pooler.supabase.com \
     -p 6543 \
     -U postgres.yeeziftpvdmiuljncbva \
     -d postgres \
     -f backup_products_YYYYMMDD_HHMMSS.sql
```

## 💡 TIPS

1. **Siempre usa Dry-Run primero** para verificar
2. **Revisa el archivo SQL generado** antes de ejecutar en modo real
3. **Guarda los backups** en un lugar seguro
4. **Revisa los logs** si algo falla
5. **El script es seguro**: usa transacciones, si algo falla hace rollback

## ✅ LISTO!

Ya puedes importar tus productos a Supabase de forma segura 🚀
