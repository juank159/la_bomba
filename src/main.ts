import { NestFactory } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { AppModule } from "./app.module";
import "reflect-metadata";
import * as dotenv from "dotenv";

// Cargar variables de entorno antes de crear la aplicación
dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: false, // Changed to false to allow extra properties to pass through
      transform: true,
      transformOptions: {
        enableImplicitConversion: false, // Disable implicit conversion to prevent default values
      },
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
