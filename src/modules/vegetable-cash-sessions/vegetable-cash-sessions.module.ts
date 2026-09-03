import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VegetableCashSessionsService } from './vegetable-cash-sessions.service';
import { VegetableCashSessionsController } from './vegetable-cash-sessions.controller';
import { VegetableCashSession } from './entities/vegetable-cash-session.entity';
import { VegetableSale } from '../vegetables/entities/vegetable-sale.entity';
import { VegetableExpense } from '../vegetable-expenses/entities/vegetable-expense.entity';

@Module({
  imports: [TypeOrmModule.forFeature([VegetableCashSession, VegetableSale, VegetableExpense])],
  controllers: [VegetableCashSessionsController],
  providers: [VegetableCashSessionsService],
  exports: [VegetableCashSessionsService],
})
export class VegetableCashSessionsModule {}
