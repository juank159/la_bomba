import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { AppModule } from "./app.module";
import { DebugInterceptor } from "./debug.interceptor";
import "reflect-metadata";
import * as dotenv from "dotenv";

// Cargar variables de entorno antes de crear la aplicación
dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  app.useGlobalInterceptors(new DebugInterceptor());

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false,
      transform: false, // ✅ DISABLE TRANSFORM to prevent unwanted field addition
      // Removed transformOptions since transform is disabled
    })
  );

  app.enableCors({
    origin: true,
    credentials: true,
  });

  const port = configService.get<number>("PORT") || 3000;
  await app.listen(port);

  console.log(`Application is running on: http://localhost:${port}`);
  console.log(`Environment: ${configService.get<string>("environment")}`);
}

bootstrap();
