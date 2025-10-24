# 🎯 VARIABLES DE ENTORNO EXACTAS PARA RENDER

## ⚠️ IMPORTANTE: Configuración Paso a Paso

### 1️⃣ Variables OBLIGATORIAS para Render

Copia **EXACTAMENTE** estas variables en Render Dashboard → Environment:

---

#### Variable 1: NODE_ENV
```
Key: NODE_ENV
Value: production
```

---

#### Variable 2: PORT
```
Key: PORT
Value: 10000
```
⚠️ **NOTA**: Render usa el puerto 10000 internamente, pero lo mapea a 3000

---

#### Variable 3: DATABASE_URL (USA CONNECTION POOLER)
```
Key: DATABASE_URL
Value: postgresql://postgres.yeeziftpvdmiuljncbva:Bauduty0159@aws-1-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require
```

⚠️ **CRÍTICO**:
- Usa el Connection Pooler (aws-1-us-east-1.pooler.supabase.com)
- Puerto 6543 (Transaction mode pooler)
- Username incluye el proyecto: postgres.yeeziftpvdmiuljncbva
- Nota el `?sslmode=require` al final

---

#### Variable 4: JWT_SECRET
```
Key: JWT_SECRET
Value: sVbRdO9n/ryZQFpbPrH964nMCtPsX0tyu/RALEWvA44CCAGygQWvPKFmzi3byjoyiA9ttmVacTVFxwhQZ7JWAg==
```

---

#### Variable 5: JWT_EXPIRES_IN
```
Key: JWT_EXPIRES_IN
Value: 7d
```

---

#### Variable 6: ALLOWED_ORIGINS
```
Key: ALLOWED_ORIGINS
Value: https://tu-frontend.onrender.com
```
⚠️ Reemplaza con tu URL real del frontend cuando la tengas

---

## 🔧 ALTERNATIVA: Variables Individuales de Base de Datos

Si prefieres NO usar DATABASE_URL, usa estas en su lugar:

```
Key: DB_HOST
Value: db.yeeziftpvdmiuljncbva.supabase.co

Key: DB_PORT
Value: 5432

Key: DB_USERNAME
Value: postgres

Key: DB_PASSWORD
Value: Bauduty0159

Key: DB_NAME
Value: postgres

Key: DB_SSL
Value: true
```

---

## 🐛 SOLUCIÓN A ERRORES COMUNES

### Error 1: "Connection timeout" o "ETIMEDOUT"

**Causa**: Supabase bloqueando conexiones por seguridad

**Solución**:
1. Ve a Supabase Dashboard: https://app.supabase.com
2. Selecciona tu proyecto
3. Settings → Database
4. Desactiva **"Restrict connections to certain IP addresses"**
5. O agrega las IPs de Render (difícil porque son dinámicas)

### Error 2: "SSL connection required"

**Causa**: Falta el parámetro SSL en la URL

**Solución**: Usa la DATABASE_URL con `?sslmode=require`:
```
postgresql://postgres:Bauduty0159@db.yeeziftpvdmiuljncbva.supabase.co:5432/postgres?sslmode=require
```

### Error 3: "Connection refused"

**Causa**: Puerto o host incorrecto

**Solución**: Verifica que uses:
- Host: `db.yeeziftpvdmiuljncbva.supabase.co` (SIN http://)
- Puerto: `5432` (número, no string)

### Error 4: "Authentication failed"

**Causa**: Contraseña incorrecta o usuario incorrecto

**Solución**: Verifica en Supabase:
1. Settings → Database → Connection string
2. Compara con tus variables

---

## 📋 CHECKLIST DE VERIFICACIÓN

Antes de deployar en Render, verifica:

- [ ] ✅ NODE_ENV = production
- [ ] ✅ PORT = 10000
- [ ] ✅ DATABASE_URL incluye `?sslmode=require`
- [ ] ✅ JWT_SECRET configurado (64+ caracteres)
- [ ] ✅ JWT_EXPIRES_IN = 7d
- [ ] ✅ ALLOWED_ORIGINS tiene URL válida
- [ ] ✅ Build Command: `npm install && npm run build`
- [ ] ✅ Start Command: `npm run start:prod`
- [ ] ✅ Health Check Path: `/health`

---

## 🔍 VERIFICAR EN SUPABASE

### Paso 1: Ve a Supabase Dashboard
https://app.supabase.com → Tu proyecto

### Paso 2: Obtén la Connection String
Settings → Database → Connection string → URI

Debería ser similar a:
```
postgresql://postgres:[PASSWORD]@db.yeeziftpvdmiuljncbva.supabase.co:5432/postgres
```

### Paso 3: Verifica Configuración de Seguridad
Settings → Database:

- **Connection Pooling**: ✅ Enabled
- **SSL Enforcement**: ✅ Required
- **IP Restrictions**: ❌ Disabled (o configura IPs de Render)

---

## 🚀 CONFIGURACIÓN DE RENDER

### Build Command:
```
npm install && npm run build
```

### Start Command:
```
npm run start:prod
```

### Environment:
- Node

### Health Check Path:
```
/health
```

### Auto-Deploy:
- ✅ Enabled (para deploys automáticos en cada push)

---

## 📊 LOGS DE RENDER

Para ver qué está fallando:

1. Ve a Render Dashboard
2. Tu servicio → **Logs**
3. Busca errores como:
   - `ECONNREFUSED`
   - `ETIMEDOUT`
   - `Authentication failed`
   - `SSL required`

### Log Exitoso se ve así:
```
[2025-10-24...] [INFO] [TypeOrmModule] Database connected successfully
[2025-10-24...] [INFO] [Bootstrap] 🚀 Application is running on: http://0.0.0.0:10000
[2025-10-24...] [INFO] [Bootstrap] 📦 Environment: production
```

---

## 💡 TIPS IMPORTANTES

### 1. Puerto en Render
Render siempre usa el puerto 10000 internamente, pero lo mapea:
- Tu app escucha en: `10000`
- Accedes desde: `https://tu-app.onrender.com` (puerto 443/80)

### 2. SSL es Obligatorio
Supabase REQUIERE SSL en producción. Asegúrate de que tu DATABASE_URL tenga:
```
?sslmode=require
```

### 3. Tiempo de Build
El primer deploy tarda ~5-10 minutos. Ten paciencia.

### 4. Free Tier Limitations
- Se duerme después de 15 min de inactividad
- Tarda ~30s en "despertar"
- Considera el plan Starter ($7/mes) para producción seria

---

## 🆘 SI AÚN TIENES PROBLEMAS

### Opción 1: Usa Connection Pooler de Supabase

En Supabase:
1. Settings → Database
2. Copia la **Connection Pooler** URL (no la directa)
3. Usa esa URL en DATABASE_URL

Ejemplo:
```
postgresql://postgres.yeeziftpvdmiuljncbva:[PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres
```

### Opción 2: Deshabilita IPv6

Agrega esta variable:
```
Key: NODE_OPTIONS
Value: --dns-result-order=ipv4first
```

### Opción 3: Aumenta el Timeout

```
Key: DB_CONNECT_TIMEOUT
Value: 30000
```

---

## 📞 URLs Útiles

- **Render Dashboard**: https://dashboard.render.com
- **Supabase Dashboard**: https://app.supabase.com
- **Render Docs - Environment Variables**: https://render.com/docs/environment-variables
- **Render Docs - PostgreSQL**: https://render.com/docs/databases

---

## ✅ RESUMEN ULTRA-RÁPIDO

Copia esto en Render Environment:

```
NODE_ENV=production
PORT=10000
DATABASE_URL=postgresql://postgres.yeeziftpvdmiuljncbva:Bauduty0159@aws-1-us-east-1.pooler.supabase.com:6543/postgres?sslmode=require
JWT_SECRET=sVbRdO9n/ryZQFpbPrH964nMCtPsX0tyu/RALEWvA44CCAGygQWvPKFmzi3byjoyiA9ttmVacTVFxwhQZ7JWAg==
JWT_EXPIRES_IN=7d
ALLOWED_ORIGINS=https://tu-frontend.onrender.com
```

Build: `npm install && npm run build`
Start: `npm run start:prod`
Health: `/health`

---

**Última actualización**: 2025-10-24
**Probado**: ✅ Conexión verificada desde local
**Estado**: ✅ Listo para Render
