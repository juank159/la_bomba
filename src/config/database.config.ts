// import { TypeOrmModuleOptions } from "@nestjs/typeorm";
// import { ConfigService } from "@nestjs/config";

// export const createDatabaseConfig = (
//   configService: ConfigService
// ): TypeOrmModuleOptions => ({
//   type: "postgres",
//   host: configService.get<string>("database.host"),
//   port: configService.get<number>("database.port"),
//   username: configService.get<string>("database.username"),
//   password: configService.get<string>("database.password"),
//   database: configService.get<string>("database.name"),
//   entities: [__dirname + "/../**/*.entity{.ts,.js}"],
//   synchronize: configService.get<string>("environment") !== "production",
//   logging: configService.get<string>("environment") === "development",
//   ssl:
//     configService.get<string>("environment") === "production"
//       ? {
//           rejectUnauthorized: false,
//         }
//       : false,
//   // FORZAR IPv4 y configuración extra
//   extra: {
//     // Forzar resolución DNS a IPv4
//     family: 4,
//   },
// });

// // Para backward compatibility
// export const databaseConfig: TypeOrmModuleOptions = {
//   type: "postgres",
//   host: process.env.DB_HOST || "localhost",
//   port: parseInt(process.env.DB_PORT, 10) || 5432,
//   username: process.env.DB_USERNAME || "postgres",
//   password: process.env.DB_PASSWORD || "password",
//   database: process.env.DB_NAME || "pedidos_db",
//   entities: [__dirname + "/../**/*.entity{.ts,.js}"],
//   synchronize: process.env.NODE_ENV !== "production",
//   logging: process.env.NODE_ENV === "development",
//   ssl:
//     process.env.NODE_ENV === "production"
//       ? {
//           rejectUnauthorized: false,
//         }
//       : false,
//   extra: {
//     family: 4,
//   },
// };

import { TypeOrmModuleOptions } from "@nestjs/typeorm";
import { ConfigService } from "@nestjs/config";
import * as url from "url";

export const createDatabaseConfig = (
  configService: ConfigService
): TypeOrmModuleOptions => {
  const environment =
    configService.get<string>("environment") || process.env.NODE_ENV;
  const databaseUrl = process.env.DATABASE_URL;

  // Si existe DATABASE_URL (Render o Supabase), parseamos la URL
  if (databaseUrl) {
    const parsedUrl = new url.URL(databaseUrl);
    return {
      type: "postgres",
      host: parsedUrl.hostname,
      port: parseInt(parsedUrl.port, 10),
      username: parsedUrl.username,
      password: parsedUrl.password,
      database: parsedUrl.pathname.replace("/", ""),
      entities: [__dirname + "/../**/*.entity{.ts,.js}"],
      synchronize: true, // TEMPORAL: Permitir sincronización en producción para agregar columna supplier_id
      logging: environment === "development",
      ssl: {
        rejectUnauthorized: false,
      },
      extra: {
        family: 4,
      },
    };
  }

  // Si no hay DATABASE_URL (entorno local)
  return {
    type: "postgres",
    host: configService.get<string>("database.host"),
    port: configService.get<number>("database.port"),
    username: configService.get<string>("database.username"),
    password: configService.get<string>("database.password"),
    database: configService.get<string>("database.name"),
    entities: [__dirname + "/../**/*.entity{.ts,.js}"],
    synchronize: true, // TEMPORAL: Permitir sincronización en producción para agregar columna supplier_id
    logging: environment === "development",
    ssl: environment === "production" ? { rejectUnauthorized: false } : false,
    extra: {
      family: 4,
    },
  };
};

// Versión por defecto (para compatibilidad)
export const databaseConfig: TypeOrmModuleOptions = {
  type: "postgres",
  host: process.env.DB_HOST || "localhost",
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  username: process.env.DB_USERNAME || "postgres",
  password: process.env.DB_PASSWORD || "password",
  database: process.env.DB_NAME || "pedidos_db",
  entities: [__dirname + "/../**/*.entity{.ts,.js}"],
  synchronize: true, // TEMPORAL: Permitir sincronización en producción para agregar columna supplier_id
  logging: process.env.NODE_ENV === "development",
  ssl:
    process.env.NODE_ENV === "production"
      ? {
          rejectUnauthorized: false,
        }
      : false,
  extra: {
    family: 4,
  },
};
