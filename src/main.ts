import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { LoggerService } from './common/logger/logger.service';
import helmet from 'helmet';
import * as compression from 'compression';
import 'reflect-metadata';

async function bootstrap() {
  // Create logger
  const logger = new LoggerService('Bootstrap');

  const app = await NestFactory.create(AppModule, {
    logger: new LoggerService('NestApplication'),
  });

  const configService = app.get(ConfigService);
  // Render usa PORT=10000, pero también soporta process.env.PORT
  const port = parseInt(process.env.PORT, 10) || configService.get<number>('PORT') || 3000;
  const nodeEnv = configService.get<string>('environment') || 'development';
  const isDevelopment = nodeEnv === 'development';

  // Security: Helmet middleware
  app.use(helmet({
    contentSecurityPolicy: isDevelopment ? false : undefined,
    crossOriginEmbedderPolicy: isDevelopment ? false : undefined,
  }));

  // Compression middleware
  app.use(compression());

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: false,
      transformOptions: {
        enableImplicitConversion: false,
      },
    })
  );

  // CORS configuration
  const allowedOrigins = configService.get<string>('ALLOWED_ORIGINS');
  app.enableCors({
    origin: allowedOrigins ? allowedOrigins.split(',') : ['http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  });

  // Swagger documentation (only in development)
  if (isDevelopment) {
    const config = new DocumentBuilder()
      .setTitle('Pedidos API')
      .setDescription('API documentation for Pedidos application')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('Auth', 'Authentication endpoints')
      .addTag('Products', 'Product management')
      .addTag('Orders', 'Order management')
      .addTag('Clients', 'Client management')
      .addTag('Health', 'Health check endpoints')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);

    logger.log(`📚 Swagger documentation available at http://localhost:${port}/api/docs`);
  }

  // Render requiere escuchar en 0.0.0.0, no solo localhost
  await app.listen(port, '0.0.0.0');

  logger.log(`🚀 Application is running on: http://0.0.0.0:${port}`);
  logger.log(`📦 Environment: ${nodeEnv}`);
  logger.log(`🔒 CORS enabled for: ${allowedOrigins || 'http://localhost:3000'}`);
}

bootstrap().catch((error) => {
  const logger = new LoggerService('Bootstrap');
  logger.error('❌ Application failed to start', error.stack);
  process.exit(1);
});
