import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VegetableExpensesService } from './vegetable-expenses.service';
import { VegetableExpensesController } from './vegetable-expenses.controller';
import { VegetableExpense } from './entities/vegetable-expense.entity';
import { VegetableCashSessionsModule } from '../vegetable-cash-sessions/vegetable-cash-sessions.module';

@Module({
  imports: [TypeOrmModule.forFeature([VegetableExpense]), VegetableCashSessionsModule],
  controllers: [VegetableExpensesController],
  providers: [VegetableExpensesService],
})
export class VegetableExpensesModule {}
