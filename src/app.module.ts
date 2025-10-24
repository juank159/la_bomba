import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ProductsModule } from './modules/products/products.module';
import { OrdersModule } from './modules/orders/orders.module';
import { ExpensesModule } from './modules/expenses/expenses.module';
import { CreditsModule } from './modules/credits/credits.module';
import { TodosModule } from './modules/todos/todos.module';
import { ClientsModule } from './modules/clients/clients.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { HealthModule } from './health/health.module';
import { createDatabaseConfig } from './config/database.config';
import configuration, { validateConfig } from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      validate: validateConfig,
    }),
    ThrottlerModule.forRoot([{
      ttl: 60000, // 60 seconds
      limit: 100, // 100 requests per ttl
    }]),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => createDatabaseConfig(configService),
      inject: [ConfigService],
    }),
    HealthModule,
    AuthModule,
    UsersModule,
    ProductsModule,
    OrdersModule,
    ExpensesModule,
    CreditsModule,
    TodosModule,
    ClientsModule,
    NotificationsModule,
  ],
})
export class AppModule {}