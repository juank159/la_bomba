import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { ProductsModule } from './modules/products/products.module';
import { OrdersModule } from './modules/orders/orders.module';
import { ExpensesModule } from './modules/expenses/expenses.module';
import { CreditsModule } from './modules/credits/credits.module';
import { TodosModule } from './modules/todos/todos.module';
import { ClientsModule } from './modules/clients/clients.module';
import { createDatabaseConfig } from './config/database.config';
import configuration, { validateConfig } from './config/configuration';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => createDatabaseConfig(configService),
      inject: [ConfigService],
    }),
    AuthModule,
    UsersModule,
    ProductsModule,
    OrdersModule,
    ExpensesModule,
    CreditsModule,
    TodosModule,
    ClientsModule,
  ],
})
export class AppModule {}