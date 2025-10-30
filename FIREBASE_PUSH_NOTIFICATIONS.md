# 🔔 Sistema de Notificaciones Push con Firebase

## 📋 Índice
1. [Configuración Inicial](#configuración-inicial)
2. [Ejecutar Migración en Supabase](#ejecutar-migración-en-supabase)
3. [Configurar Firebase en Render](#configurar-firebase-en-render)
4. [Uso del Servicio de Notificaciones](#uso-del-servicio-de-notificaciones)
5. [Ejemplos de Uso](#ejemplos-de-uso)
6. [Testing](#testing)

---

## 1. Configuración Inicial

### ✅ Archivos Instalados

- ✅ `firebase-admin` instalado en package.json
- ✅ `src/modules/notifications/firebase-notification.service.ts` creado
- ✅ `src/modules/users/entities/user.entity.ts` actualizado con campo `fcmToken`
- ✅ `src/modules/users/users.service.ts` con métodos para manejar tokens FCM
- ✅ `src/modules/users/users.controller.ts` con endpoints PUT /users/fcm-token
- ✅ `migrations/add_fcm_token_to_users.sql` migración creada

---

## 2. Ejecutar Migración en Supabase

### Paso 1: Conectarse a Supabase desde Render Shell

1. Ve a https://dashboard.render.com
2. Selecciona tu **Web Service** (backend)
3. Ve a la pestaña **"Shell"**
4. Ejecuta:

```bash
psql $DATABASE_URL
```

### Paso 2: Ejecutar la Migración

Copia y pega estos comandos **UNO POR UNO**:

```sql
-- 1. Ver estructura actual
\d users

-- 2. Crear backup
DROP TABLE IF EXISTS users_backup_fcm_20251029;
CREATE TABLE users_backup_fcm_20251029 AS SELECT * FROM users;

-- 3. Verificar backup
SELECT
    (SELECT COUNT(*) FROM users) as usuarios_originales,
    (SELECT COUNT(*) FROM users_backup_fcm_20251029) as usuarios_en_backup;

-- 4. Agregar columna fcm_token
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token VARCHAR(255);

-- 5. Crear índice
CREATE INDEX IF NOT EXISTS idx_users_fcm_token ON users(fcm_token) WHERE fcm_token IS NOT NULL;

-- 6. Agregar comentario
COMMENT ON COLUMN users.fcm_token IS 'Firebase Cloud Messaging token for push notifications (nullable)';

-- 7. Verificar
\d users

-- 8. Confirmar datos
SELECT
    COUNT(*) as total_usuarios,
    COUNT(CASE WHEN fcm_token IS NOT NULL THEN 1 END) as usuarios_con_token,
    COUNT(CASE WHEN fcm_token IS NULL THEN 1 END) as usuarios_sin_token
FROM users;
```

**✅ Resultado Esperado:**
```
 total_usuarios | usuarios_con_token | usuarios_sin_token
----------------+--------------------+-------------------
              X |                  0 |                 X
```

Más detalles en: `migrations/INSTRUCCIONES_FCM_TOKEN.md`

---

## 3. Configurar Firebase en Render

### Paso 1: Obtener Service Account de Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Project Settings** (⚙️) → **Service Accounts**
4. Click en **"Generate New Private Key"**
5. Se descargará un archivo JSON (ej: `my-project-firebase-adminsdk-xxxxx.json`)

### Paso 2: Preparar el JSON para Variable de Entorno

El archivo JSON se ve así:
```json
{
  "type": "service_account",
  "project_id": "tu-proyecto-id",
  "private_key_id": "xxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIE...",
  "client_email": "firebase-adminsdk-xxxxx@tu-proyecto.iam.gserviceaccount.com",
  "client_id": "xxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40tu-proyecto.iam.gserviceaccount.com"
}
```

### Paso 3: Minificar el JSON (Una Línea)

**IMPORTANTE**: Debes convertir el JSON a una sola línea sin saltos de línea.

Opción A - **Manual** (recomendado):
1. Abre el archivo JSON
2. Copia todo el contenido
3. Ve a https://www.text-utils.com/json-minifier/
4. Pega el JSON
5. Click en "Minify"
6. Copia el resultado (todo en una línea)

Opción B - **Command Line**:
```bash
# macOS/Linux
cat tu-archivo-firebase.json | jq -c
```

El resultado debe ser algo como:
```json
{"type":"service_account","project_id":"tu-proyecto","private_key_id":"xxx","private_key":"-----BEGIN PRIVATE KEY-----\nMIIE...","client_email":"firebase-adminsdk-xxx@tu-proyecto.iam.gserviceaccount.com",...}
```

### Paso 4: Agregar Variable de Entorno en Render

1. Ve a https://dashboard.render.com
2. Selecciona tu **Web Service** (backend)
3. Ve a la pestaña **"Environment"**
4. Click en **"Add Environment Variable"**
5. Agrega:

| Key | Value |
|-----|-------|
| `FIREBASE_SERVICE_ACCOUNT` | (pega el JSON minificado aquí) |

**⚠️ IMPORTANTE:**
- Debe ser TODO en una línea (sin saltos de línea)
- Incluye las llaves `{` y `}` al inicio y al final
- No agregues comillas adicionales

6. Click en **"Save Changes"**
7. Render reiniciará automáticamente tu servicio

### Paso 5: Verificar Configuración

Una vez que el servicio se haya reiniciado, revisa los logs:

```bash
# En la pestaña "Logs" de Render deberías ver:
✅ Firebase Admin initialized successfully
```

Si ves este mensaje, ¡Firebase está configurado correctamente! 🎉

Si ves un error:
```bash
❌ Error initializing Firebase Admin: ...
⚠️ Push notifications will not work without Firebase configuration
```

Verifica que:
- El JSON esté bien formado (usa un validador JSON)
- El JSON esté en una sola línea
- No haya comillas extras alrededor del JSON

---

## 4. Uso del Servicio de Notificaciones

### Importar el Servicio

En cualquier módulo que necesite enviar notificaciones:

```typescript
import { FirebaseNotificationService, NotificationTypeEnum } from '../notifications/firebase-notification.service';

@Injectable()
export class MiServicio {
  constructor(
    private firebaseNotificationService: FirebaseNotificationService,
  ) {}

  // ... tus métodos
}
```

### Métodos Disponibles

#### 1. Enviar a un usuario específico

```typescript
await this.firebaseNotificationService.sendToUser(
  userId,
  'Título de la notificación',
  'Cuerpo del mensaje',
  {
    type: NotificationTypeEnum.SUPERVISOR_TASK,
    taskId: '123',
  }
);
```

#### 2. Enviar a múltiples usuarios

```typescript
const result = await this.firebaseNotificationService.sendToMultipleUsers(
  ['user-id-1', 'user-id-2', 'user-id-3'],
  'Nuevo anuncio',
  'Hay actualizaciones disponibles',
  {
    type: NotificationTypeEnum.ORDER_UPDATE,
  }
);

console.log(`Enviadas: ${result.success}, Fallidas: ${result.failed}`);
```

#### 3. Enviar a todos los usuarios de un rol

```typescript
// Enviar a todos los admins
await this.firebaseNotificationService.sendToAllAdmins(
  'Revisión pendiente',
  'Hay productos esperando aprobación',
  {
    type: NotificationTypeEnum.ADMIN_TASK,
  }
);

// Enviar a todos los supervisores
await this.firebaseNotificationService.sendToAllSupervisors(
  'Nueva tarea',
  'Se ha asignado una nueva tarea',
  {
    type: NotificationTypeEnum.SUPERVISOR_TASK,
    taskId: '456',
  }
);
```

---

## 5. Ejemplos de Uso

### Ejemplo 1: Notificar cuando se crea una tarea para supervisor

```typescript
// En tu service de tareas
async createTask(supervisorId: string, taskData: any) {
  // 1. Crear la tarea en la BD
  const task = await this.tasksRepository.save(taskData);

  // 2. Enviar notificación push
  await this.firebaseNotificationService.sendSupervisorTaskNotification(
    supervisorId,
    task.id,
    task.description
  );

  return task;
}
```

### Ejemplo 2: Notificar cuando se aprueba un producto

```typescript
// En tu service de productos
async approveProduct(productId: string, adminId: string) {
  const product = await this.productsRepository.findOne({ where: { id: productId } });

  // Actualizar estado
  product.isApproved = true;
  await this.productsRepository.save(product);

  // Notificar a quien creó el producto
  if (product.createdBy) {
    await this.firebaseNotificationService.sendProductApprovedNotification(
      product.createdBy,
      product.id,
      product.name
    );
  }

  return product;
}
```

### Ejemplo 3: Recordatorio de crédito

```typescript
// En tu service de créditos
async sendCreditReminder(creditId: string) {
  const credit = await this.creditsRepository.findOne({
    where: { id: creditId },
    relations: ['client'],
  });

  if (credit && credit.client) {
    await this.firebaseNotificationService.sendCreditReminderNotification(
      credit.client.userId,  // Asumiendo que el cliente está vinculado a un usuario
      credit.id,
      credit.amount
    );
  }
}
```

### Ejemplo 4: Notificar a todos los admins sobre un evento

```typescript
// Cuando un producto necesita revisión
async requestProductReview(productId: string) {
  const product = await this.productsRepository.findOne({ where: { id: productId } });

  // Notificar a TODOS los admins
  await this.firebaseNotificationService.sendToAllAdmins(
    'Producto pendiente de revisión',
    `El producto "${product.name}" necesita ser revisado`,
    {
      type: NotificationTypeEnum.ADMIN_TASK,
      productId: product.id,
    }
  );
}
```

---

## 6. Testing

### Test Manual desde Render Shell

Puedes probar el servicio de notificaciones ejecutando:

```bash
# En Render Shell
node dist/test-notifications.js
```

O crear un endpoint temporal para testing:

```typescript
// En notifications.controller.ts
@Get('test/:userId')
@Roles(UserRole.ADMIN)
async testNotification(@Param('userId') userId: string) {
  const result = await this.firebaseNotificationService.sendToUser(
    userId,
    'Notificación de prueba',
    'Esta es una notificación de prueba desde el backend',
    {
      type: NotificationTypeEnum.ADMIN_TASK,
    }
  );

  return {
    success: result,
    message: result ? 'Notificación enviada' : 'Error al enviar notificación'
  };
}
```

Luego prueba con:
```bash
curl -X GET https://tu-backend.onrender.com/notifications/test/USER_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## 📊 Tipos de Notificaciones Soportadas

| Tipo | Descripción | Navega a |
|------|-------------|----------|
| `SUPERVISOR_TASK` | Tarea asignada a supervisor | `/supervisor` |
| `ADMIN_TASK` | Tarea pendiente para admin | `/admin-tasks` |
| `PRODUCT_APPROVED` | Producto aprobado | `/products` |
| `CREDIT_REMINDER` | Recordatorio de crédito | `/credits` |
| `ORDER_UPDATE` | Actualización de pedido | `/orders` |

---

## 🔍 Troubleshooting

### Problema: "Firebase not initialized"

**Causa**: Variable de entorno `FIREBASE_SERVICE_ACCOUNT` no configurada o mal formateada.

**Solución**:
1. Verifica que la variable exista en Render
2. Verifica que el JSON esté en una sola línea
3. Verifica que el JSON sea válido (usa https://jsonlint.com)

### Problema: "User does not have FCM token"

**Causa**: El usuario no ha iniciado sesión en la app móvil después de la actualización.

**Solución**: El usuario debe:
1. Cerrar sesión en la app móvil
2. Iniciar sesión nuevamente
3. El token FCM se guardará automáticamente

### Problema: "Invalid registration token"

**Causa**: El token FCM del usuario ha expirado o es inválido.

**Solución**: El servicio automáticamente limpia tokens inválidos. El usuario debe volver a iniciar sesión en la app.

---

## ✨ Próximos Pasos

1. ✅ Ejecuta la migración SQL en Supabase
2. ✅ Configura la variable de entorno `FIREBASE_SERVICE_ACCOUNT` en Render
3. ✅ Verifica los logs que Firebase se inicializó correctamente
4. ✅ Prueba enviando una notificación de prueba
5. ✅ Integra las notificaciones en tus flujos de negocio

¡Todo listo para enviar notificaciones push! 🚀
