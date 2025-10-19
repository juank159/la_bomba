"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.databaseConfig = exports.createDatabaseConfig = void 0;
const createDatabaseConfig = (configService) => ({
    type: 'postgres',
    host: configService.get('database.host'),
    port: configService.get('database.port'),
    username: configService.get('database.username'),
    password: configService.get('database.password'),
    database: configService.get('database.name'),
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    synchronize: configService.get('environment') !== 'production',
    logging: configService.get('environment') === 'development',
    ssl: configService.get('environment') === 'production' ? { rejectUnauthorized: false } : false,
});
exports.createDatabaseConfig = createDatabaseConfig;
exports.databaseConfig = {
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'password',
    database: process.env.DB_NAME || 'pedidos_db',
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    synchronize: process.env.NODE_ENV !== 'production',
    logging: process.env.NODE_ENV === 'development',
    ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
};
//# sourceMappingURL=database.config.js.map