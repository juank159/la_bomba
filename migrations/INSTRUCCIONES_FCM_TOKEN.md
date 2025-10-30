# 🔔 Instrucciones para Agregar FCM Token a Usuarios

## ⚠️ IMPORTANTE
Esta migración es **100% segura** y NO afectará tus datos existentes.

### ¿Qué hace la migración?
- ✅ Agrega una nueva columna `fcm_token` a la tabla `users`
- ✅ Crea un backup automático antes de hacer el cambio
- ✅ Crea un índice para búsquedas rápidas
- ✅ NO elimina, modifica ni borra ningún usuario existente
- ✅ Incluye comandos para revertir si es necesario

---

## 📋 OPCIÓN 1: Usar Render Shell (Recomendado)

### Paso 1: Ir a tu Web Service en Render
1. Ve a https://dashboard.render.com
2. Selecciona tu **Web Service** (backend)
3. Ve a la pestaña **"Shell"**

### Paso 2: Conectarte a la Base de Datos
En el shell de Render, ejecuta:

```bash
psql $DATABASE_URL
```

### Paso 3: Ejecutar la Migración
Copia y pega todo el contenido del archivo `add_fcm_token_to_users.sql` en el shell.

O ejecuta estos comandos **UNO POR UNO**:

```sql
-- 1. Ver estructura actual de users
\d users

-- 2. Crear backup de seguridad
DROP TABLE IF EXISTS users_backup_fcm_20251029;
CREATE TABLE users_backup_fcm_20251029 AS SELECT * FROM users;

-- 3. Verificar backup
SELECT
    (SELECT COUNT(*) FROM users) as usuarios_originales,
    (SELECT COUNT(*) FROM users_backup_fcm_20251029) as usuarios_en_backup;

-- 4. Agregar columna fcm_token
ALTER TABLE users
ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(255);

-- 5. Crear índice
CREATE INDEX IF NOT EXISTS idx_users_fcm_token ON users(fcm_token) WHERE fcm_token IS NOT NULL;

-- 6. Agregar comentario
COMMENT ON COLUMN users.fcm_token IS 'Firebase Cloud Messaging token for push notifications (nullable)';

-- 7. Verificar estructura nueva
\d users

-- 8. Verificar que NO se perdieron datos
SELECT
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN fcm_token IS NOT NULL THEN 1 END) as usuarios_con_token,
    COUNT(CASE WHEN fcm_token IS NULL THEN 1 END) as usuarios_sin_token
FROM users;
```

---

## 📋 OPCIÓN 2: Conectarse desde tu Terminal Local

### Paso 1: Obtener la URL de la Base de Datos
1. Ve a https://dashboard.render.com
2. Selecciona tu base de datos PostgreSQL
3. Ve a la pestaña **"Connect"**
4. Copia la **External Database URL**

### Paso 2: Conectarte usando psql
```bash
# Reemplaza <DATABASE_URL> con la URL que copiaste
psql "<DATABASE_URL>"
```

### Paso 3: Ejecutar el archivo de migración
```bash
# Opción A: Pegar el contenido completo
# Abre add_fcm_token_to_users.sql y copia/pega todo

# Opción B: Ejecutar desde archivo local
\i /Users/mac/Documents/pedidos/backend/migrations/add_fcm_token_to_users.sql
```

---

## ✅ Verificación Final

Después de ejecutar la migración, deberías ver:

```
Table "public.users"
   Column    | Type         | Nullable
-------------+--------------+----------
 id          | uuid         | not null
 username    | varchar      | not null
 email       | varchar      | not null
 password    | varchar      | not null
 role        | enum         | not null
 isActive    | boolean      |
 createdAt   | timestamp    | not null
 updatedAt   | timestamp    | not null
 fcm_token   | varchar(255) |          ← NUEVA COLUMNA (✅ CORRECTO)
```

Y el resumen de usuarios:
```
 total_usuarios | usuarios_con_token | usuarios_sin_token
----------------+--------------------+-------------------
              X |                  0 |                 X
```

Todos los usuarios existentes tendrán `fcm_token = NULL` hasta que inicien sesión en la app móvil.

---

## 🔄 Si Necesitas Revertir (Rollback)

Si por alguna razón quieres deshacer la migración:

```sql
-- Eliminar columna
ALTER TABLE users DROP COLUMN IF EXISTS fcm_token;

-- Eliminar índice
DROP INDEX IF EXISTS idx_users_fcm_token;

-- Restaurar desde backup (si es necesario)
-- CUIDADO: Esto eliminará cualquier token FCM guardado después de la migración
-- DELETE FROM users;
-- INSERT INTO users SELECT * FROM users_backup_fcm_20251029;
```

---

## 🗑️ Limpiar Backup (Después de Confirmar que Todo Funciona)

Cuando estés 100% seguro de que la migración funcionó bien (después de 1-2 días):

```sql
DROP TABLE users_backup_fcm_20251029;
```

---

## 📞 Preguntas Frecuentes

**Q: ¿Perderé mis usuarios existentes?**
A: NO. La migración solo agrega una nueva columna, no toca tus usuarios.

**Q: ¿Los usuarios podrán iniciar sesión normalmente?**
A: SÍ. Todo seguirá funcionando igual, solo se agregó una columna extra.

**Q: ¿Cuánto tiempo tarda?**
A: Menos de 1 segundo. Es instantáneo.

**Q: ¿Puedo ejecutarla mientras la app está funcionando?**
A: SÍ. No necesitas detener el servicio.

**Q: ¿Hay riesgo de perder datos?**
A: NO. El script crea un backup automático antes de hacer cualquier cambio.

**Q: ¿Qué pasa si un usuario ya tiene fcm_token?**
A: Si re-ejecutas la migración, no hace nada gracias a `IF NOT EXISTS`. Es seguro ejecutarla múltiples veces.

---

## ✨ Después de la Migración

Una vez completada la migración, podrás:

1. ✅ Recibir y almacenar tokens FCM cuando usuarios inicien sesión
2. ✅ Enviar notificaciones push personalizadas por usuario
3. ✅ Enviar notificaciones por rol (admin, supervisor, employee)
4. ✅ Actualizar tokens cuando se refresquen

**¿Todo listo?** Sigue los pasos con calma y ejecuta la migración. 🚀
