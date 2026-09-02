import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { VegetablesController } from './vegetables.controller';
import { VegetablesService } from './vegetables.service';
import { VegetableItem } from './entities/vegetable-item.entity';
import { VegetableCategory } from './entities/vegetable-category.entity';
import { VegetableSale } from './entities/vegetable-sale.entity';
import { VegetableSaleItem } from './entities/vegetable-sale-item.entity';
import { VegetableOrder } from './entities/vegetable-order.entity';
import { VegetableOrderItem } from './entities/vegetable-order-item.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      VegetableItem,
      VegetableCategory,
      VegetableSale,
      VegetableSaleItem,
      VegetableOrder,
      VegetableOrderItem,
    ]),
  ],
  controllers: [VegetablesController],
  providers: [VegetablesService],
  exports: [VegetablesService],
})
export class VegetablesModule {}
