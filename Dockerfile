# Imagen base de Node.js
FROM node:20-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache bash curl

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production && npm cache clean --force

# Copiar el código fuente
COPY . .

# Compilar la aplicación TypeScript
RUN npm run build

# Crear un usuario no-root para mayor seguridad
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

# Cambiar la propiedad de los archivos al usuario nodejs
RUN chown -R nestjs:nodejs /app
USER nestjs

# Exponer el puerto
EXPOSE 3000

# Comando para ejecutar la aplicación
CMD ["npm", "run", "start:prod"]