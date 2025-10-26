# 🛡️ Instrucciones para Ejecutar Migración Segura en Render

## ⚠️ IMPORTANTE
Esta migración es **100% segura** y NO afectará tus datos existentes.

### ¿Qué hace la migración?
- ✅ Solo cambia la restricción de la columna `barcode` para permitir valores NULL
- ✅ Crea un backup automático antes de hacer el cambio
- ✅ NO elimina, modifica ni borra ningún dato
- ✅ Incluye comandos para revertir si es necesario

---

## 📋 OPCIÓN 1: Conectarse a PostgreSQL desde Render Dashboard

### Paso 1: Ir a tu Base de Datos en Render
1. Ve a https://dashboard.render.com
2. Selecciona tu base de datos PostgreSQL
3. Ve a la pestaña **"Connect"**
4. Copia la **External Database URL** (se ve así):
   ```
   postgres://username:password@host:port/database
   ```

### Paso 2: Conectarte usando psql
Abre tu terminal y ejecuta:

```bash
# Reemplaza <DATABASE_URL> con la URL que copiaste
psql "<DATABASE_URL>"
```

### Paso 3: Ejecutar la Migración Segura
Una vez conectado a la base de datos:

```bash
# Opción A: Pegar el contenido completo del script
# Copia y pega todo el contenido de safe_migration_barcode_nullable.sql

# Opción B: Ejecutar desde archivo (si tienes el archivo localmente)
\i /ruta/al/archivo/safe_migration_barcode_nullable.sql
```

### Paso 4: Verificar Resultados
El script mostrará:
- ✅ Estructura ANTES de la migración
- ✅ Confirmación del backup creado
- ✅ Resultado de la migración
- ✅ Estructura DESPUÉS de la migración
- ✅ Verificación de que NO se perdieron datos

---

## 📋 OPCIÓN 2: Usar Render Shell (Más Fácil)

### Paso 1: Ir a tu Web Service en Render
1. Ve a https://dashboard.render.com
2. Selecciona tu **Web Service** (backend)
3. Ve a la pestaña **"Shell"**

### Paso 2: Conectarte a la Base de Datos
En el shell de Render, ejecuta:

```bash
# El DATABASE_URL ya está configurado como variable de entorno
psql $DATABASE_URL
```

### Paso 3: Ejecutar Comandos de Migración
Copia y pega estos comandos **UNO POR UNO**:

```sql
-- 1. Ver estructura actual
\d products

-- 2. Crear backup de seguridad
DROP TABLE IF EXISTS products_backup_20251026;
CREATE TABLE products_backup_20251026 AS SELECT * FROM products;

-- 3. Verificar backup
SELECT
    (SELECT COUNT(*) FROM products) as productos_originales,
    (SELECT COUNT(*) FROM products_backup_20251026) as productos_en_backup;

-- 4. Ejecutar la migración
ALTER TABLE products ALTER COLUMN barcode DROP NOT NULL;
COMMENT ON COLUMN products.barcode IS 'Product barcode - nullable to allow supervisor to add it later';

-- 5. Verificar estructura nueva
\d products

-- 6. Verificar que NO se perdieron datos
SELECT
    COUNT(*) as total_productos,
    COUNT(CASE WHEN barcode IS NOT NULL THEN 1 END) as productos_con_barcode,
    COUNT(CASE WHEN barcode IS NULL THEN 1 END) as productos_sin_barcode
FROM products;
```

---

## ✅ Verificación Final

Después de ejecutar la migración, deberías ver:

```
Table "public.products"
   Column    | Type         | Nullable
-------------+--------------+----------
 barcode     | varchar      |          ← SIN "not null" (✅ CORRECTO)
```

Y el resumen de datos:
```
 total_productos | productos_con_barcode | productos_sin_barcode
-----------------+-----------------------+----------------------
              X  |                    X  |                    0
```

---

## 🔄 Si Necesitas Revertir (Rollback)

Si por alguna razón quieres deshacer la migración:

```sql
-- Volver a hacer barcode NOT NULL
ALTER TABLE products ALTER COLUMN barcode SET NOT NULL;
```

---

## 🗑️ Limpiar Backup (Después de Confirmar que Todo Funciona)

Cuando estés 100% seguro de que la migración funcionó bien (después de 1-2 días):

```sql
DROP TABLE products_backup_20251026;
```

---

## 📞 Preguntas Frecuentes

**Q: ¿Perderé mis productos existentes?**
A: NO. La migración solo cambia cómo funciona la columna barcode, no toca tus datos.

**Q: ¿Los productos con barcode se verán afectados?**
A: NO. Todos los productos con barcode seguirán funcionando igual.

**Q: ¿Cuánto tiempo tarda?**
A: Menos de 1 segundo. Es instantáneo.

**Q: ¿Puedo ejecutarla mientras la app está funcionando?**
A: SÍ. No necesitas detener el servicio.

**Q: ¿Hay riesgo de perder datos?**
A: NO. El script crea un backup automático antes de hacer cualquier cambio.

---

## ✨ Después de la Migración

Podrás crear productos sin barcode desde el frontend, y el supervisor podrá agregarlo después.

**¿Todo listo?** Elige la opción que prefieras y sigue los pasos con calma. 🚀
