-- 022 - Notificaciones en la app WEB: token del navegador aparte del celular.
--
-- Correr ANTES de desplegar el backend que lo usa:
--   psql "$DATABASE_URL" -f src/migrations/022-web-push-token.sql
-- Idempotente: se puede correr más de una vez.

ALTER TABLE users ADD COLUMN IF NOT EXISTS "webFcmToken" character varying(500);
