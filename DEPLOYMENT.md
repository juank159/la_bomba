# 🚀 Deployment Guide - Pedidos Backend

## 📋 Pre-requisitos

- Docker & Docker Compose instalados
- Node.js 20+ (para desarrollo local)
- PostgreSQL 15+ (si no usas Docker)

## 🔐 Configuración de Variables de Entorno

### 1. Crear archivo .env

Copia el archivo `.env.example` y renómbralo a `.env`:

```bash
cp .env.example .env
```

### 2. Configurar variables CRÍTICAS para producción

**⚠️ IMPORTANTE:** Cambia estos valores antes de deployar:

```env
NODE_ENV=production
PORT=3000

# Database - USA CONTRASEÑAS FUERTES
DB_HOST=db
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=TU_CONTRASEÑA_SUPER_SEGURA_AQUI
DB_NAME=pedidos_db

# JWT - GENERA UN SECRET ÚNICO
JWT_SECRET=GENERA_UN_SECRET_ALEATORIO_MUY_LARGO_Y_SEGURO
JWT_EXPIRES_IN=7d

# CORS - Dominios permitidos (separados por comas)
ALLOWED_ORIGINS=https://tu-dominio.com,https://www.tu-dominio.com

# Docker Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=TU_CONTRASEÑA_SUPER_SEGURA_AQUI
POSTGRES_DB=pedidos_db
```

### 3. Generar JWT Secret seguro

```bash
# Opción 1: OpenSSL
openssl rand -base64 64

# Opción 2: Node.js
node -e "console.log(require('crypto').randomBytes(64).toString('base64'))"
```

## 🏗️ Deployment

### Opción 1: Docker Compose (Recomendado)

#### Desarrollo:
```bash
docker-compose up -d
```

#### Producción:
```bash
# Build y start
docker-compose -f docker-compose.prod.yml up -d --build

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f app

# Detener
docker-compose -f docker-compose.prod.yml down
```

### Opción 2: Deployment Manual

```bash
# 1. Instalar dependencias
npm ci

# 2. Build
npm run build

# 3. Iniciar aplicación
npm run start:prod
```

## 🔍 Health Checks

La aplicación expone varios endpoints de health check:

```bash
# Health general
curl http://localhost:3000/health

# Ready check
curl http://localhost:3000/health/ready

# Live check
curl http://localhost:3000/health/live
```

## 📚 Documentación API (Solo Desarrollo)

En modo desarrollo, Swagger está disponible en:

```
http://localhost:3000/api/docs
```

## 🔒 Seguridad Implementada

✅ **Helmet** - Protección de headers HTTP
✅ **Rate Limiting** - 100 requests por minuto
✅ **CORS** - Configurado por dominio
✅ **Validation Pipes** - Validación automática de DTOs
✅ **JWT Authentication** - Tokens seguros
✅ **Password Hashing** - bcrypt para contraseñas
✅ **Environment Validation** - Validación de variables requeridas
✅ **Compression** - Compresión de respuestas
✅ **Docker User** - Usuario no-root en contenedor

## 🐳 Docker Commands Útiles

```bash
# Ver logs en tiempo real
docker logs -f pedidos_app_prod

# Entrar al contenedor
docker exec -it pedidos_app_prod sh

# Reiniciar aplicación
docker restart pedidos_app_prod

# Ver estado de contenedores
docker ps

# Limpiar volúmenes (⚠️ CUIDADO: Borra la BD)
docker-compose down -v
```

## 📊 Monitoreo

### Logs

Los logs están estructurados en formato:
```
[timestamp] [LEVEL] [Context] message
```

### Métricas

- **Health**: `/health` - Estado general
- **Ready**: `/health/ready` - Aplicación lista
- **Live**: `/health/live` - Aplicación viva

## 🔄 Actualizaciones

```bash
# 1. Pull cambios
git pull origin main

# 2. Rebuild imagen
docker-compose -f docker-compose.prod.yml build --no-cache

# 3. Restart contenedores
docker-compose -f docker-compose.prod.yml up -d
```

## 🐛 Troubleshooting

### Error: "Missing required environment variable"
- Verifica que todas las variables en `.env` estén configuradas

### Error: "Connection refused" a la BD
- Verifica que el contenedor de PostgreSQL esté corriendo: `docker ps`
- Revisa los logs de la BD: `docker logs pedidos_db_prod`

### Error: "CORS blocked"
- Agrega tu dominio a `ALLOWED_ORIGINS` en `.env`
- Formato: `https://dominio1.com,https://dominio2.com`

## 📞 Soporte

Para problemas o preguntas, contacta al equipo de desarrollo.

---

**⚠️ RECORDATORIO DE SEGURIDAD:**
- Nunca commitees el archivo `.env` al repositorio
- Cambia TODOS los secrets antes de production
- Usa HTTPS en producción
- Actualiza dependencias regularmente: `npm audit`
