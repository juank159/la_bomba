import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentMethod } from '../credits/entities/payment-method.entity';
import { InvoicesModule } from '../invoices/invoices.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { VegetableCashSessionsModule } from '../vegetable-cash-sessions/vegetable-cash-sessions.module';
import { VegetablesModule } from '../vegetables/vegetables.module';
import { BrebController } from './breb.controller';
import { BrebService } from './breb.service';
import { BrebConfig } from './entities/breb-config.entity';
import { BrebPendingCharge } from './entities/breb-pending-charge.entity';
import { BrebUnmatchedEmail } from './entities/breb-unmatched-email.entity';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([BrebConfig, BrebPendingCharge, BrebUnmatchedEmail, PaymentMethod]),
    NotificationsModule,
    // Para registrar la venta/factura cuando el banco confirma el pago —
    // con la MISMA función del cobro normal (stock, caja, totales).
    VegetablesModule,
    InvoicesModule,
    VegetableCashSessionsModule,
  ],
  controllers: [BrebController],
  providers: [BrebService],
  exports: [BrebService],
})
export class BrebModule {}
