# Migraciones de Base de Datos

## Información General

Este proyecto utiliza **TypeORM** con `synchronize: true` en desarrollo, lo que significa que las tablas se crean automáticamente basándose en las entidades.

En producción, `synchronize` está configurado como `false` por seguridad, por lo que las migraciones pueden ser necesarias.

## Migraciones Disponibles

### 001-create-client-balance-tables.sql

**Fecha:** 2025-10-27
**Descripción:** Sistema de saldo a favor de clientes (manejo de sobrepagos)

**Tablas creadas:**
- `client_balances`: Saldo actual de cada cliente
- `client_balance_transactions`: Historial de transacciones de saldo

**Funcionalidad:**
- Permite manejar sobrepagos de créditos
- Cuando un cliente paga más de lo que debe, el exceso se guarda como "saldo a favor"
- El saldo puede usarse para futuros pagos de créditos o pedidos
- Sistema completo de auditoría con transacciones

## Ejecución en Desarrollo

En desarrollo local, **NO necesitas ejecutar las migraciones manualmente**. TypeORM creará las tablas automáticamente cuando inicies el servidor.

```bash
npm run start:dev
```

Las entidades están en:
- `src/modules/credits/entities/client-balance.entity.ts`
- `src/modules/credits/entities/client-balance-transaction.entity.ts`

## Ejecución en Producción

Si necesitas ejecutar las migraciones manualmente en producción (ej. Render):

### Opción 1: Dejar que TypeORM sincronice automáticamente
Si estás seguro y quieres que TypeORM cree las tablas automáticamente una vez:

1. Cambia temporalmente `synchronize: false` a `synchronize: true` en `src/config/database.config.ts` (línea 73)
2. Despliega a producción
3. Verifica que las tablas se crearon correctamente
4. Regresa `synchronize: false` (IMPORTANTE por seguridad)

### Opción 2: Ejecutar SQL manualmente

1. Conéctate a la base de datos de producción:
```bash
# Si usas Render/Supabase
psql $DATABASE_URL
```

2. Ejecuta el archivo de migración:
```bash
psql $DATABASE_URL < src/migrations/001-create-client-balance-tables.sql
```

### Opción 3: Usar herramienta de gestión de base de datos

Puedes copiar el contenido de `001-create-client-balance-tables.sql` y ejecutarlo en:
- pgAdmin
- DBeaver
- TablePlus
- Consola de Supabase/Render

## Verificación

Para verificar que las tablas se crearon correctamente:

```sql
-- Listar tablas de saldo de clientes
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name LIKE 'client_balance%';

-- Debería retornar:
-- client_balances
-- client_balance_transactions

-- Ver estructura de client_balances
\d client_balances

-- Ver estructura de client_balance_transactions
\d client_balance_transactions
```

## Rollback (Deshacer)

Si necesitas eliminar las tablas:

```sql
DROP TABLE IF EXISTS client_balance_transactions CASCADE;
DROP TABLE IF EXISTS client_balances CASCADE;
```

⚠️ **ADVERTENCIA:** Esto eliminará todos los datos de saldo de clientes permanentemente.

## Consideraciones de Seguridad

1. **NUNCA** dejar `synchronize: true` en producción por tiempo prolongado
2. Las migraciones deberían ejecutarse con acceso controlado
3. Siempre hacer backup de la base de datos antes de ejecutar migraciones
4. Probar las migraciones en entorno de staging primero

## Soporte

Si tienes problemas con las migraciones:
1. Revisa los logs del servidor para errores de TypeORM
2. Verifica que las credenciales de base de datos sean correctas
3. Asegúrate que las tablas `clients` y `credits` existan (son dependencias)
