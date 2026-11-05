import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VegetableCashSessionsService } from './vegetable-cash-sessions.service';
import { VegetableCashSessionsController } from './vegetable-cash-sessions.controller';
import { VegetableCashSession } from './entities/vegetable-cash-session.entity';
import { VegetableSale } from '../vegetables/entities/vegetable-sale.entity';
import { VegetableSalePayment } from '../vegetables/entities/vegetable-sale-payment.entity';
import { VegetablePurchase } from '../vegetables/entities/vegetable-purchase.entity';
import { VegetableExpense } from '../vegetable-expenses/entities/vegetable-expense.entity';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([VegetableCashSession, VegetableSale, VegetableSalePayment, VegetablePurchase, VegetableExpense]),
    // Para validar la contraseña de Adalberto antes de mostrar el cuadre.
    AuthModule,
  ],
  controllers: [VegetableCashSessionsController],
  providers: [VegetableCashSessionsService],
  exports: [VegetableCashSessionsService],
})
export class VegetableCashSessionsModule {}
