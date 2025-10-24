# 🚀 Variables de Entorno para Render

## Variables Requeridas

Copia estas variables en la sección "Environment" de tu servicio en Render:

### 1. Application Configuration

```env
NODE_ENV=production
PORT=3000
```

### 2. Database Configuration (Supabase)

**⚠️ IMPORTANTE**: Usa estos valores exactos extraídos de tu URL de Supabase

```env
DB_HOST=db.yeeziftpvdmiuljncbva.supabase.co
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=Bauduty0159
DB_NAME=postgres
```

**Alternativamente**, puedes usar la URL completa (Render la parsea automáticamente):

```env
DATABASE_URL=postgresql://postgres:Bauduty0159@db.yeeziftpvdmiuljncbva.supabase.co:5432/postgres
```

### 3. JWT Configuration

**⚠️ CRÍTICO**: Genera un secret NUEVO y ÚNICO para producción

```bash
# Genera uno nuevo con este comando:
openssl rand -base64 64
```

```env
JWT_SECRET=TU_SECRET_SUPER_SEGURO_GENERADO_AQUI
JWT_EXPIRES_IN=7d
```

### 4. CORS Configuration

```env
ALLOWED_ORIGINS=https://tu-frontend.onrender.com,https://tu-dominio.com
```

**Nota**: Cambia las URLs por las de tu aplicación frontend real.

---

## 📝 Pasos para Deployar en Render

### 1. Crear Web Service en Render

1. Ve a https://dashboard.render.com
2. Click en "New +" → "Web Service"
3. Conecta tu repositorio de GitHub/GitLab

### 2. Configuración del Servicio

**Build Command:**
```bash
npm install && npm run build
```

**Start Command:**
```bash
npm run start:prod
```

**Environment:**
- Node

**Region:**
- Oregon (US West) o la más cercana a ti

**Instance Type:**
- Free o Starter (según necesites)

### 3. Agregar Variables de Entorno

En la sección "Environment", agrega TODAS estas variables:

```
NODE_ENV=production
PORT=3000

DB_HOST=db.yeeziftpvdmiuljncbva.supabase.co
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=Bauduty0159
DB_NAME=postgres

JWT_SECRET=<GENERA_UNO_NUEVO>
JWT_EXPIRES_IN=7d

ALLOWED_ORIGINS=https://tu-frontend.onrender.com
```

### 4. Health Check

Render automáticamente detectará `/health`, pero puedes configurarlo manualmente:

- **Health Check Path**: `/health`
- **Health Check Status**: `200`

---

## 🔒 Seguridad en Supabase

### Configurar IP Whitelisting (Opcional)

Si Supabase tiene IP whitelisting, necesitas agregar las IPs de Render:

1. Ve a Supabase Dashboard
2. Settings → Database → Connection Pooling
3. Agrega las IPs de Render (o deshabilita IP restrictions)

**Render usa IPs dinámicas**, así que es mejor:
- Deshabilitar IP restrictions en Supabase, O
- Usar Connection Pooler de Supabase con SSL

### Usar SSL (Recomendado)

Modifica la configuración de la base de datos para usar SSL:

```env
DB_SSL=true
```

---

## 🐛 Troubleshooting

### Error: "Connection refused"

**Solución**: Verifica que Supabase permita conexiones externas:
- Ve a Supabase → Settings → Database
- Desactiva "Restrict connections to certain IP addresses" si está activo

### Error: "Authentication failed"

**Solución**: Verifica las credenciales:
- Usuario: `postgres`
- Contraseña: `Bauduty0159`

### Error: "CORS blocked"

**Solución**: Agrega la URL de tu frontend a `ALLOWED_ORIGINS`:
```env
ALLOWED_ORIGINS=https://tu-app-frontend.onrender.com,https://otro-dominio.com
```

---

## 📊 Monitoreo

Después del deploy, verifica:

1. **Health Check**:
   ```bash
   curl https://tu-api.onrender.com/health
   ```

2. **Logs en Render**:
   - Dashboard → Tu servicio → Logs
   - Busca: `🚀 Application is running`

3. **Base de Datos**:
   - Verifica conexión en logs: `TypeOrmModule dependencies initialized`

---

## 🎯 Checklist Pre-Deploy

- [ ] Variables de entorno configuradas en Render
- [ ] JWT_SECRET generado y guardado de forma segura
- [ ] ALLOWED_ORIGINS configurado con URL de frontend
- [ ] Supabase permite conexiones externas
- [ ] SSL habilitado en conexión a BD (recomendado)
- [ ] Health check path configurado: `/health`
- [ ] Build command: `npm install && npm run build`
- [ ] Start command: `npm run start:prod`

---

## 🔗 URLs Útiles

- **Render Dashboard**: https://dashboard.render.com
- **Supabase Dashboard**: https://app.supabase.com
- **Health Check**: `https://tu-api.onrender.com/health`
- **Swagger** (solo si NODE_ENV=development): `https://tu-api.onrender.com/api/docs`

---

## ⚡ Deploy Automático

Render hace deploy automático cuando pusheas a la rama principal:

```bash
git add .
git commit -m "Deploy to Render"
git push origin main
```

Render detectará el push y desplegará automáticamente.

---

## 💡 Tips

1. **Free Tier de Render**: El servicio se duerme después de 15 min de inactividad
2. **Logs**: Revisa siempre los logs después del deploy
3. **Environment Secrets**: Usa la opción "Secret" en Render para variables sensibles
4. **Backups**: Supabase hace backups automáticos (verifica tu plan)

---

**¿Listo para deployar?** 🚀

Sigue los pasos y tu backend estará en producción en minutos!
