-- =====================================================
-- Migration: Add FCM Token to Users Table
-- Purpose: Store Firebase Cloud Messaging tokens for push notifications
-- Date: 2025-10-29
-- Status: SAFE - Solo agrega columna nueva, no modifica datos existentes
-- =====================================================

-- Verificar estructura actual de la tabla users
-- \d users

-- Crear backup de seguridad (IMPORTANTE)
DROP TABLE IF EXISTS users_backup_fcm_20251029;
CREATE TABLE users_backup_fcm_20251029 AS SELECT * FROM users;

-- Verificar que el backup se creó correctamente
SELECT
    (SELECT COUNT(*) FROM users) as usuarios_originales,
    (SELECT COUNT(*) FROM users_backup_fcm_20251029) as usuarios_en_backup;

-- ✅ Agregar columna fcm_token a la tabla users
-- Esta columna almacenará el token de Firebase Cloud Messaging
-- Es nullable porque:
-- 1. Usuarios existentes no tendrán token hasta que inicien sesión
-- 2. Los nuevos usuarios obtendrán token al iniciar sesión
ALTER TABLE users
ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(255);

-- Crear índice para búsquedas rápidas por token
CREATE INDEX IF NOT EXISTS idx_users_fcm_token ON users(fcm_token) WHERE fcm_token IS NOT NULL;

-- Agregar comentario explicativo
COMMENT ON COLUMN users.fcm_token IS 'Firebase Cloud Messaging token for push notifications (nullable)';

-- ✅ Verificar que la migración se aplicó correctamente
-- Ver estructura actualizada
-- \d users

-- Verificar que NO se perdieron usuarios
SELECT
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN fcm_token IS NOT NULL THEN 1 END) as usuarios_con_token,
    COUNT(CASE WHEN fcm_token IS NULL THEN 1 END) as usuarios_sin_token
FROM users;

-- =====================================================
-- RESUMEN:
-- ✅ Columna fcm_token agregada a la tabla users
-- ✅ Índice creado para optimizar búsquedas
-- ✅ Backup de seguridad creado: users_backup_fcm_20251029
-- ✅ Todos los usuarios existentes tienen fcm_token = NULL
-- ✅ NO se eliminó ni modificó ningún dato existente
-- =====================================================

-- 🔄 ROLLBACK (Si necesitas revertir):
-- ALTER TABLE users DROP COLUMN IF EXISTS fcm_token;
-- DROP INDEX IF EXISTS idx_users_fcm_token;

-- 🗑️ LIMPIAR BACKUP (Después de confirmar que todo funciona):
-- DROP TABLE users_backup_fcm_20251029;
