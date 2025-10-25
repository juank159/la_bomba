# 📧 CONFIGURAR EMAIL EN RENDER

## ⚠️ ERROR ACTUAL

```
[WARN] [EmailService] ⚠️ Email credentials not configured.
Password recovery emails will be logged to console.
```

Esto significa que el sistema funciona, pero **NO envía emails reales**. Los códigos se muestran en los logs de Render.

---

## 🎯 SOLUCIÓN: CONFIGURAR GMAIL

### OPCIÓN A: Usar Gmail (Recomendado)

#### Paso 1: Obtener App Password de Gmail

1. **Ve a tu cuenta de Google**: https://myaccount.google.com

2. **Habilita la verificación en 2 pasos**:
   - Click en **Seguridad** (menú izquierdo)
   - Busca **Verificación en dos pasos**
   - Si no está activa, actívala ahora

3. **Genera un App Password**:
   - En **Seguridad**, busca **Contraseñas de aplicaciones**
   - Click en **Contraseñas de aplicaciones**
   - Selecciona **Correo** y **Otro (nombre personalizado)**
   - Escribe: **La Bomba - Render**
   - Click en **Generar**
   - **Guarda la contraseña** de 16 caracteres (ej: `abcd efgh ijkl mnop`)

#### Paso 2: Agregar Variables en Render

1. **Ve a Render Dashboard**: https://dashboard.render.com

2. **Selecciona tu servicio**: `pedidos-backend` o como se llame

3. **Ve a** → **Environment**

4. **Agrega estas 2 variables**:

```
Key: EMAIL_USER
Value: tu_email@gmail.com
```

```
Key: EMAIL_PASSWORD
Value: abcd efgh ijkl mnop
```

⚠️ **IMPORTANTE**:
- Usa el email completo en `EMAIL_USER` (ej: `juanperez@gmail.com`)
- Usa el App Password de 16 caracteres en `EMAIL_PASSWORD` (sin espacios: `abcdefghijklmnop`)
- **NO uses** tu contraseña regular de Gmail

5. **Click en "Save Changes"**

6. **Render hará auto-deploy** automáticamente

---

## ✅ VERIFICAR QUE FUNCIONA

### 1. Espera el deploy (3-5 minutos)

### 2. Revisa los logs:

Ve a **Render Dashboard → Tu servicio → Logs**

Busca esta línea:
```
[INFO] [EmailService] 📧 Email service initialized with tu_email@gmail.com
```

Si ves eso, ¡está configurado correctamente! ✅

### 3. Prueba enviar un código:

```bash
curl -X POST https://la-bomba.onrender.com/auth/password/request-reset \
  -H "Content-Type: application/json" \
  -d '{"email":"TU_EMAIL_DE_PRUEBA@gmail.com"}'
```

Reemplaza `TU_EMAIL_DE_PRUEBA@gmail.com` con un email real que tengas acceso.

### 4. Revisa tu bandeja de entrada:

Deberías recibir un email con:
- ✅ Asunto: **"Recuperación de Contraseña - La Bomba"**
- ✅ Un código de 6 dígitos en grande
- ✅ Diseño profesional en HTML

---

## 🔄 OPCIÓN B: Usar Otro Proveedor de Email

Si no quieres usar Gmail, puedes usar otro servicio (Outlook, SendGrid, etc.)

### Paso 1: Modificar el código del backend

Edita: `src/common/email/email.service.ts`

Busca esta sección (línea ~42):

```typescript
this.transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: emailUser,
    pass: emailPass,
  },
});
```

**Para Outlook/Hotmail:**
```typescript
this.transporter = nodemailer.createTransport({
  host: 'smtp-mail.outlook.com',
  port: 587,
  secure: false,
  auth: {
    user: emailUser,
    pass: emailPass,
  },
});
```

**Para SendGrid:**
```typescript
this.transporter = nodemailer.createTransport({
  host: 'smtp.sendgrid.net',
  port: 587,
  secure: false,
  auth: {
    user: 'apikey',
    pass: emailPass, // Tu API key de SendGrid
  },
});
```

**Para otro SMTP genérico:**
```typescript
this.transporter = nodemailer.createTransport({
  host: 'smtp.tuproveedor.com',
  port: 587,
  secure: false, // true si usa SSL en puerto 465
  auth: {
    user: emailUser,
    pass: emailPass,
  },
});
```

### Paso 2: Hacer commit y push

```bash
git add src/common/email/email.service.ts
git commit -m "Configure email provider"
git push origin main
```

### Paso 3: Agregar variables en Render

```
EMAIL_USER=tu_email@proveedor.com
EMAIL_PASSWORD=tu_password_o_api_key
```

---

## 🧪 MODO DESARROLLO (Sin Email)

Si **NO quieres configurar email ahora**, el sistema sigue funcionando:

✅ Los códigos se muestran en los logs de Render
✅ Puedes copiar el código de los logs
✅ El flujo completo funciona

**Para ver el código en los logs:**

1. Ve a **Render Dashboard → Logs**
2. Solicita un código desde la app
3. Busca en los logs:
   ```
   [WARN] [EmailService] 🔑 Recovery code for usuario@email.com: 123456
   ```
4. Copia el código `123456`
5. Úsalo en la app

---

## 📧 PLANTILLA DEL EMAIL

Así se ve el email que recibirá el usuario:

```
╔═══════════════════════════════════════╗
║  🔒 Recuperación de Contraseña        ║
╠═══════════════════════════════════════╣
║                                       ║
║  Hola {username},                     ║
║                                       ║
║  Tu código de verificación es:        ║
║                                       ║
║     ┌─────────────┐                   ║
║     │   123456    │                   ║
║     └─────────────┘                   ║
║                                       ║
║  Este código expira en 15 minutos     ║
║                                       ║
║  ⚠️ Importante:                       ║
║  • Si no solicitaste este cambio,    ║
║    ignora este correo                ║
║  • Nunca compartas este código       ║
║                                       ║
╚═══════════════════════════════════════╝
```

---

## 🐛 TROUBLESHOOTING

### Error: "Failed to send email"

**Causa**: Credenciales incorrectas o servicio bloqueado

**Soluciones**:
1. Verifica que `EMAIL_USER` sea el email completo
2. Verifica que `EMAIL_PASSWORD` sea el App Password (no tu contraseña regular)
3. Verifica que la verificación en 2 pasos esté activa en Gmail
4. Revisa los logs de Render para ver el error específico

### Error: "Invalid login"

**Causa**: Gmail bloqueando el acceso

**Soluciones**:
1. Asegúrate de usar App Password, no tu contraseña regular
2. Ve a https://myaccount.google.com/lesssecureapps y verifica configuración
3. Revisa si Gmail te envió un email de alerta de seguridad

### No recibo el email

**Causa**: Email en spam o delay

**Soluciones**:
1. Revisa la carpeta de **Spam**
2. Revisa los logs de Render para confirmar que se envió
3. Espera 1-2 minutos (a veces hay delay)
4. Agrega `noreply@anthropic.com` a tus contactos

---

## 🔐 SEGURIDAD

### ✅ Buenas prácticas:

- ✅ Usa App Passwords, no contraseñas regulares
- ✅ No compartas tu EMAIL_PASSWORD
- ✅ Usa verificación en 2 pasos en Gmail
- ✅ Revisa logs de acceso periódicamente
- ✅ Rota el App Password cada 3-6 meses

### ❌ NO hagas esto:

- ❌ NO uses tu contraseña regular de Gmail
- ❌ NO desactives la verificación en 2 pasos
- ❌ NO compartas las credenciales en el código
- ❌ NO uses "less secure apps" de Gmail

---

## 📊 RESUMEN RÁPIDO

### SIN Email (Modo Desarrollo):
```
✅ Funciona el sistema
✅ Códigos en logs
❌ No envía emails reales
```

### CON Email (Modo Producción):
```
✅ Funciona el sistema
✅ Envía emails reales
✅ Plantilla HTML profesional
✅ Usuarios reciben códigos automáticamente
```

---

## ✅ CHECKLIST

Para configurar email correctamente:

- [ ] Verificación en 2 pasos activa en Gmail
- [ ] App Password generado (16 caracteres)
- [ ] EMAIL_USER agregado en Render
- [ ] EMAIL_PASSWORD agregado en Render
- [ ] Deploy completado en Render
- [ ] Logs muestran: "Email service initialized"
- [ ] Probado envío de código
- [ ] Email recibido correctamente

---

## 🎯 SIGUIENTE PASO

1. **Genera tu App Password** en Gmail
2. **Agrega las variables** en Render
3. **Espera el deploy** (3-5 minutos)
4. **Prueba** solicitando un código

¡En 10 minutos tendrás emails funcionando! 📧✨

