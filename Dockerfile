# Imagen base de Node.js
FROM node:20-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache bash curl

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./

# Instalar TODAS las dependencias (necesarias para el build)
RUN npm ci && npm cache clean --force

# Copiar archivos de código fuente (sin .env gracias al .dockerignore)
COPY tsconfig*.json ./
COPY src ./src

# Compilar la aplicación TypeScript
RUN npm run build

# Remover dependencias de desarrollo
RUN npm prune --production

# Crear un usuario no-root para mayor seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nestjs -u 1001 && \
    chown -R nestjs:nodejs /app

# Cambiar al usuario no-root
USER nestjs

# Exponer el puerto
EXPOSE 3000

# Comando para ejecutar la aplicación
CMD ["npm", "run", "start:prod"]