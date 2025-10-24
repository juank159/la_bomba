import { validate } from './env.validation';

export default () => ({
  port: parseInt(process.env.PORT, 10) || 3000,
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    name: process.env.DB_NAME || 'pedidos_db',
  },
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  environment: process.env.NODE_ENV || 'development',
  allowedOrigins: process.env.ALLOWED_ORIGINS || 'http://localhost:3000',
});

export const validateConfig = (config: Record<string, unknown>) => {
  return validate(config);
};