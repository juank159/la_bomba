import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InvoicesController } from './invoices.controller';
import { InvoicesService } from './invoices.service';
import { Invoice } from './entities/invoice.entity';
import { InvoiceItem } from './entities/invoice-item.entity';
import { InvoicePayment } from './entities/invoice-payment.entity';
import { Product } from '../products/entities/product.entity';
import { PaymentMethod } from '../credits/entities/payment-method.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Invoice, InvoiceItem, InvoicePayment, Product, PaymentMethod]),
  ],
  controllers: [InvoicesController],
  providers: [InvoicesService],
  exports: [InvoicesService],
})
export class InvoicesModule {}
