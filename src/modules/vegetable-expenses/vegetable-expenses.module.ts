import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VegetableExpensesService } from './vegetable-expenses.service';
import { VegetableExpensesController } from './vegetable-expenses.controller';
import { VegetableExpense } from './entities/vegetable-expense.entity';

@Module({
  imports: [TypeOrmModule.forFeature([VegetableExpense])],
  controllers: [VegetableExpensesController],
  providers: [VegetableExpensesService],
})
export class VegetableExpensesModule {}
