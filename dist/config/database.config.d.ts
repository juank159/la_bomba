import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
export declare const createDatabaseConfig: (configService: ConfigService) => TypeOrmModuleOptions;
export declare const databaseConfig: TypeOrmModuleOptions;
