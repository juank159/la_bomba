# Backend API - Sistema de Pedidos

API REST desarrollada con NestJS, TypeORM y PostgreSQL para la gestión de pedidos con roles de usuario (admin/employee).

## Características

- 🔐 Autenticación JWT
- 👥 Roles de usuario (Admin/Employee)
- 📦 Gestión de productos con códigos de barras
- 📋 Sistema de pedidos con items
- 💰 Módulo de gastos (solo admin)
- 💳 Sistema de créditos con pagos parciales
- ✅ TODOs con tareas opcionales

## Tecnologías

- **Framework**: NestJS
- **Base de datos**: PostgreSQL
- **ORM**: TypeORM
- **Autenticación**: JWT
- **Validación**: class-validator

## Instalación

### Opción 1: Con Docker (Recomendado)

1. **Clonar y configurar**:
```bash
# Copiar variables de entorno
cp .env.example .env
# Editar .env con tus valores si es necesario
```

2. **Ejecutar con Docker**:

**Para desarrollo (con hot-reload):**
```bash
docker-compose -f docker-compose.dev.yml up --build
```

**Para producción:**
```bash
docker-compose up --build
```

3. **Acceder a los servicios**:
- API: http://localhost:3000
- PgAdmin: http://localhost:5050 (admin@pedidos.com / admin123)

### Opción 2: Instalación Local

1. **Instalar dependencias**:
```bash
npm install
```

2. **Configurar variables de entorno**:
```bash
cp .env.example .env
# Editar .env con la configuración de tu base de datos local
```

3. **Crear la base de datos PostgreSQL local**

4. **Ejecutar la aplicación**:
```bash
npm run start:dev
```

## Docker

### Comandos útiles:

```bash
# Desarrollo con hot-reload
docker-compose -f docker-compose.dev.yml up

# Producción
docker-compose up --build

# Detener servicios
docker-compose down

# Ver logs
docker-compose logs -f app

# Acceder al contenedor de la app
docker exec -it pedidos_app_dev sh
```

## Endpoints Principales

### Autenticación
- `POST /auth/register` - Registrar usuario
- `POST /auth/login` - Iniciar sesión

### Usuarios (Solo Admin)
- `GET /users` - Listar usuarios
- `GET /users/:id` - Obtener usuario

### Productos
- `GET /products` - Listar productos
- `POST /products` - Crear producto
- `PATCH /products/:id` - Actualizar producto
- `DELETE /products/:id` - Eliminar producto

### Pedidos
- `GET /orders` - Listar pedidos
- `POST /orders` - Crear pedido
- `PATCH /orders/:id` - Actualizar pedido
- `PATCH /orders/items/quantities` - Actualizar cantidades (Solo Admin)
- `DELETE /orders/:id` - Eliminar pedido

### Gastos (Solo Admin)
- `GET /expenses` - Listar gastos
- `POST /expenses` - Crear gasto
- `PATCH /expenses/:id` - Actualizar gasto
- `DELETE /expenses/:id` - Eliminar gasto

### Créditos (Solo Admin)
- `GET /credits` - Listar créditos
- `POST /credits` - Crear crédito
- `POST /credits/:id/payments` - Agregar pago
- `DELETE /credits/:id/payments/:paymentId` - Eliminar pago
- `DELETE /credits/:id` - Eliminar crédito

### TODOs
- `GET /todos` - Listar TODOs
- `POST /todos` - Crear TODO
- `PATCH /todos/:id` - Actualizar TODO
- `PATCH /todos/:todoId/tasks/:taskId` - Actualizar tarea
- `DELETE /todos/:id` - Eliminar TODO

## Estructura de la Base de Datos

### Entidades Principales:

1. **Users**: Usuarios con roles (admin/employee)
2. **Products**: Productos con descripción y código de barras
3. **Orders**: Pedidos con estado (pending/completed)
4. **OrderItems**: Items de pedido con cantidades existentes y solicitadas
5. **Expenses**: Gastos (solo admin)
6. **Credits**: Créditos con pagos parciales
7. **Payments**: Pagos de créditos
8. **Todos**: TODOs con tareas opcionales
9. **Tasks**: Tareas de los TODOs

## Roles y Permisos

### Employee:
- Ver y crear pedidos
- Ver productos
- Ver y gestionar sus propios TODOs

### Admin:
- Todo lo que puede hacer Employee
- Gestionar usuarios
- Actualizar cantidades solicitadas en pedidos
- Cambiar estado de pedidos
- Gestionar gastos
- Gestionar créditos y pagos
- Crear TODOs para otros usuarios

## Autenticación

Usar Bearer Token en el header Authorization:
```
Authorization: Bearer <token>
```

## Estados de Pedidos

- `pending`: Pendiente
- `completed`: Finalizado

## Estados de Créditos

- `pending`: Pendiente de pago
- `paid`: Pagado completamente

## Variables de Entorno

El proyecto utiliza un sistema robusto de configuración basado en variables de entorno. Todas las configuraciones críticas están centralizadas y validadas.

### Variables Requeridas:
- `JWT_SECRET`: Clave secreta para JWT (requerido)

### Variables de Base de Datos:
- `DB_HOST`: Host de la base de datos (por defecto: localhost)
- `DB_PORT`: Puerto de la base de datos (por defecto: 5432)
- `DB_USERNAME`: Usuario de la base de datos (por defecto: postgres)
- `DB_PASSWORD`: Contraseña de la base de datos (por defecto: password)
- `DB_NAME`: Nombre de la base de datos (por defecto: pedidos_db)

### Variables de Aplicación:
- `PORT`: Puerto de la aplicación (por defecto: 3000)
- `NODE_ENV`: Entorno de ejecución (por defecto: development)
- `JWT_EXPIRES_IN`: Tiempo de expiración del JWT (por defecto: 7d)

La aplicación validará que `JWT_SECRET` esté configurado al iniciar, de lo contrario arrojará un error.# la_bomba
