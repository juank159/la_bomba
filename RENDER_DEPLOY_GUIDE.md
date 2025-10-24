# 🚀 Guía Rápida: Deploy en Render con Supabase

## ✅ Pre-requisitos

- ✅ Cuenta en Render (https://render.com)
- ✅ Base de datos en Supabase (ya la tienes)
- ✅ Repositorio en GitHub/GitLab

---

## 📝 Paso a Paso

### 1️⃣ Preparar el Código

Tu código ya está listo! Verifica que tengas estos archivos:

```
backend/
├── package.json
├── Dockerfile
├── src/
└── .env.render (referencia)
```

### 2️⃣ Crear Servicio en Render

1. Ve a https://dashboard.render.com
2. Click en **"New +"** → **"Web Service"**
3. Conecta tu repositorio de GitHub/GitLab
4. Selecciona el repositorio `pedidos/backend`

### 3️⃣ Configuración Básica

En la pantalla de configuración:

| Campo | Valor |
|-------|-------|
| **Name** | `pedidos-backend` (o el que prefieras) |
| **Region** | Oregon (US West) o la más cercana |
| **Branch** | `main` (o tu rama principal) |
| **Root Directory** | `backend` (si tu repo tiene frontend y backend) |
| **Environment** | `Node` |
| **Build Command** | `npm install && npm run build` |
| **Start Command** | `npm run start:prod` |

### 4️⃣ Variables de Entorno

Haz click en **"Advanced"** → **"Add Environment Variable"**

Agrega estas variables **UNA POR UNA**:

#### ✅ Configuración de Aplicación

```
NODE_ENV = production
```

```
PORT = 3000
```

#### ✅ Base de Datos (Supabase)

**Opción Recomendada - URL Completa:**

```
DATABASE_URL = postgresql://postgres:Bauduty0159@db.yeeziftpvdmiuljncbva.supabase.co:5432/postgres
```

#### ✅ JWT Secret

**🔴 CRÍTICO**: Genera un nuevo secret:

```bash
# Ejecuta en tu terminal local:
openssl rand -base64 64
```

Luego agrega:

```
JWT_SECRET = [PEGA_EL_SECRET_GENERADO_AQUI]
```

```
JWT_EXPIRES_IN = 7d
```

#### ✅ CORS

```
ALLOWED_ORIGINS = https://tu-frontend.onrender.com
```

**Nota**: Cambia por la URL real de tu frontend cuando la tengas.

### 5️⃣ Health Check (Opcional pero Recomendado)

En **"Advanced"** → **"Health Check Path"**:

```
/health
```

### 6️⃣ Deploy

1. Revisa que todas las variables estén correctas
2. Click en **"Create Web Service"**
3. Render comenzará a construir y deployar automáticamente

---

## 📊 Monitoreo del Deploy

### Ver Logs en Tiempo Real

En tu dashboard de Render:
- Ve a tu servicio
- Click en **"Logs"**
- Deberías ver:

```
✓ Building...
✓ Starting application...
[2025-10-24T...] [INFO] [Bootstrap] 🚀 Application is running on: http://0.0.0.0:3000
[2025-10-24T...] [INFO] [Bootstrap] 📦 Environment: production
```

### Verificar que Funciona

Una vez que el deploy termine (status "Live"):

```bash
# Reemplaza con tu URL real de Render
curl https://pedidos-backend.onrender.com/health
```

Deberías ver:

```json
{
  "status": "ok",
  "timestamp": "2025-10-24T...",
  "uptime": 123.456,
  "environment": "production"
}
```

---

## 🐛 Troubleshooting

### ❌ Error: "Application failed to start"

**Verifica los logs**:
1. Ve a tu servicio en Render
2. Click en "Logs"
3. Busca el error específico

**Causas comunes**:

#### 1. Error de Base de Datos

```
Error: connect ECONNREFUSED
```

**Solución**: Verifica que Supabase permita conexiones externas:
- Ve a Supabase Dashboard
- Settings → Database
- **Desactiva** "IP Address Restrictions" (si está activo)

#### 2. Error de Variables de Entorno

```
Error: Missing required environment variable: JWT_SECRET
```

**Solución**: Verifica que agregaste TODAS las variables en Render.

#### 3. Error de Build

```
npm ERR! missing script: start:prod
```

**Solución**: Verifica `package.json`:

```json
"scripts": {
  "start:prod": "node dist/main"
}
```

### ❌ Error: "CORS blocked"

**Síntomas**: Tu frontend no puede conectarse al backend.

**Solución**:
1. Ve a Render → Tu servicio → Environment
2. Actualiza `ALLOWED_ORIGINS` con la URL correcta de tu frontend
3. El servicio se reiniciará automáticamente

---

## 🔒 Configuración de Supabase

### Permitir Conexiones Externas

1. Ve a https://app.supabase.com
2. Selecciona tu proyecto
3. Settings → Database
4. **Connection Pooling**: Verifica que esté habilitado
5. **SSL Enforcement**: Debe estar ON (ya configurado en tu código)

### Verificar Credenciales

Tu URL de conexión:
```
postgresql://postgres:Bauduty0159@db.yeeziftpvdmiuljncbva.supabase.co:5432/postgres
```

- ✅ Host: `db.yeeziftpvdmiuljncbva.supabase.co`
- ✅ Puerto: `5432`
- ✅ Usuario: `postgres`
- ✅ Contraseña: `Bauduty0159`
- ✅ Base de datos: `postgres`

---

## 🎯 Después del Deploy

### 1. Obtén tu URL

Render te dará una URL como:
```
https://pedidos-backend.onrender.com
```

### 2. Prueba los Endpoints

```bash
# Health check
curl https://pedidos-backend.onrender.com/health

# Swagger (si está en development - no recomendado en prod)
# https://pedidos-backend.onrender.com/api/docs
```

### 3. Actualiza tu Frontend

Actualiza la URL del backend en tu aplicación Flutter:

```dart
// En tu archivo de configuración
const String apiUrl = 'https://pedidos-backend.onrender.com';
```

### 4. Configura Dominio Propio (Opcional)

En Render:
1. Settings → Custom Domain
2. Agrega tu dominio
3. Configura DNS según las instrucciones

---

## 🔄 Deployar Actualizaciones

Render hace deploy automático cuando pusheas a tu rama principal:

```bash
git add .
git commit -m "feat: nueva funcionalidad"
git push origin main
```

Render detectará el push y desplegará automáticamente.

### Manual Redeploy

En Render Dashboard:
1. Ve a tu servicio
2. Click en "Manual Deploy"
3. Selecciona "Clear build cache & deploy"

---

## 💰 Costos

### Free Tier (Gratis)

- ✅ 750 horas/mes
- ✅ Deploy automático
- ⚠️ Se duerme después de 15 min de inactividad
- ⚠️ Tarda ~30s en "despertar"

### Starter ($7/mes)

- ✅ Siempre activo (no se duerme)
- ✅ Mejor rendimiento
- ✅ Deploy más rápido

---

## 📞 URLs Útiles

- **Render Dashboard**: https://dashboard.render.com
- **Render Docs**: https://render.com/docs
- **Supabase Dashboard**: https://app.supabase.com
- **Tu API**: `https://pedidos-backend.onrender.com`
- **Health Check**: `https://pedidos-backend.onrender.com/health`

---

## ✅ Checklist Final

Antes de considerar el deploy completo:

- [ ] ✅ Servicio "Live" en Render
- [ ] ✅ Health check responde OK
- [ ] ✅ Logs muestran "Application is running"
- [ ] ✅ Base de datos conectada (log: "TypeOrmModule initialized")
- [ ] ✅ JWT_SECRET generado y configurado
- [ ] ✅ ALLOWED_ORIGINS configurado con URL del frontend
- [ ] ✅ Frontend actualizado con URL de Render
- [ ] ✅ Pruebas de endpoints exitosas

---

## 🎉 ¡Listo!

Tu backend está ahora en producción en Render con Supabase! 🚀

Si tienes problemas, revisa los logs en Render Dashboard o consulta la documentación.

---

**Fecha de creación**: 2025-10-24
**Última actualización**: 2025-10-24
**Estado**: ✅ Listo para usar
