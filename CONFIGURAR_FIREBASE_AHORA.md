# 🔥 Configurar Firebase - Guía Rápida

## ⚠️ Problema Actual
Estás viendo este warning en los logs:
```
⚠️ FIREBASE_SERVICE_ACCOUNT not configured. Push notifications will not work.
```

**Esto es NORMAL** - solo significa que falta agregar las credenciales de Firebase.

---

## 🚀 Solución en 3 Pasos (10 minutos)

### **Paso 1: Descargar Service Account de Firebase** (3 min)

1. Ve a: https://console.firebase.google.com
2. **Selecciona tu proyecto** (o crea uno nuevo si no tienes)
3. Click en el **ícono ⚙️** (arriba izquierda) → **"Project Settings"**
4. Ve a la pestaña **"Service Accounts"**
5. Click en **"Generate new private key"**
6. Confirma y descarga el archivo JSON

**Resultado**: Tendrás un archivo tipo `my-project-firebase-adminsdk-xxxxx.json`

---

### **Paso 2: Minificar el JSON** (2 min)

**Opción A - Usando el script (Recomendado):**

```bash
cd /Users/mac/Documents/pedidos/backend
./setup-firebase-env.sh ~/Downloads/tu-archivo-firebase.json
```

El script te mostrará el JSON minificado listo para copiar.

**Opción B - Manual (si el script no funciona):**

1. Ve a: https://www.text-utils.com/json-minifier/
2. Abre tu archivo JSON descargado
3. Copia TODO el contenido
4. Pégalo en el sitio web
5. Click en "Minify"
6. Copia el resultado (será una sola línea)

**Importante**: El JSON debe quedar en **UNA SOLA LÍNEA**, algo así:
```json
{"type":"service_account","project_id":"tu-proyecto",...}
```

---

### **Paso 3: Agregar en Render** (5 min)

1. Ve a: https://dashboard.render.com
2. Selecciona tu **Web Service** (backend)
3. Click en la pestaña **"Environment"**
4. Click en **"Add Environment Variable"**
5. Configura:
   - **Key**: `FIREBASE_SERVICE_ACCOUNT`
   - **Value**: (pega el JSON minificado aquí)
6. Click en **"Save Changes"**

**Render reiniciará automáticamente** el servicio (toma ~2 minutos).

---

## ✅ Verificar que Funcionó

Una vez que Render termine de reiniciar:

1. Ve a la pestaña **"Logs"** en Render
2. Busca esta línea:
   ```
   ✅ Firebase Admin initialized successfully
   ```

Si ves ese mensaje: **¡LISTO! 🎉** Firebase está configurado.

Si ves un error:
```
❌ Error initializing Firebase Admin: ...
```

**Posibles causas:**
- El JSON no está bien formado → Valídalo en https://jsonlint.com
- El JSON tiene saltos de línea → Debe ser UNA sola línea
- Hay comillas extras → Copia solo desde `{` hasta `}`

---

## 🧪 Probar que Funciona

Una vez configurado, puedes probar enviando una notificación de prueba.

**Opción 1 - Desde el código:**

Agrega esto temporalmente en cualquier endpoint del backend:

```typescript
// En algún controller
@Get('test-notification/:userId')
async testNotification(@Param('userId') userId: string) {
  const result = await this.firebaseNotificationService.sendToUser(
    userId,
    'Prueba',
    'Esta es una notificación de prueba',
    { type: NotificationTypeEnum.ADMIN_TASK }
  );

  return { success: result };
}
```

**Opción 2 - Esperar un evento real:**

Las notificaciones se enviarán automáticamente cuando:
- Se cree una tarea de supervisor
- Se apruebe un producto
- Se actualice un pedido
- etc.

---

## 📞 ¿Necesitas Ayuda?

**Problema común 1**: "El JSON es muy largo"
- ✅ Es normal, puede tener 2000+ caracteres
- ✅ Render acepta variables largas sin problema

**Problema común 2**: "Dice 'Unexpected token' o 'Invalid JSON'"
- ❌ El JSON tiene saltos de línea
- ✅ Usa el script o el minifier para dejarlo en una línea

**Problema común 3**: "Sigue sin funcionar después de guardar"
- ⏱️ Espera a que Render termine de reiniciar (1-2 min)
- 🔄 Refresca la página de logs

---

## 📚 Documentación Completa

Para más detalles, consulta: `FIREBASE_PUSH_NOTIFICATIONS.md`

---

¡Listo! Sigue estos 3 pasos y tendrás Firebase funcionando en 10 minutos. 🚀
