import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreditsService } from './credits.service';
import { CreditsController } from './credits.controller';
import { ClientBalanceService } from './client-balance.service';
import { ClientBalanceController } from './client-balance.controller';
import { PaymentMethodService } from './payment-method.service';
import { PaymentMethodController } from './payment-method.controller';
import { Credit } from './entities/credit.entity';
import { Payment } from './entities/payment.entity';
import { CreditTransaction } from './entities/transaction.entity';
import { ClientBalance } from './entities/client-balance.entity';
import { ClientBalanceTransaction } from './entities/client-balance-transaction.entity';
import { PaymentMethod } from './entities/payment-method.entity';
import { Client } from '../clients/entities/client.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Credit,
      Payment,
      CreditTransaction,
      ClientBalance,
      ClientBalanceTransaction,
      PaymentMethod,
      Client,
    ]),
  ],
  controllers: [CreditsController, ClientBalanceController, PaymentMethodController],
  providers: [CreditsService, ClientBalanceService, PaymentMethodService],
  exports: [CreditsService, ClientBalanceService, PaymentMethodService],
})
export class CreditsModule {}