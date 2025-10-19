import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CreditsService } from './credits.service';
import { CreditsController } from './credits.controller';
import { Credit } from './entities/credit.entity';
import { Payment } from './entities/payment.entity';
import { CreditTransaction } from './entities/transaction.entity';
import { Client } from '../clients/entities/client.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Credit, Payment, CreditTransaction, Client])],
  controllers: [CreditsController],
  providers: [CreditsService],
})
export class CreditsModule {}