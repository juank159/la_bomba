import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductsService } from './products.service';
import { ProductsController } from './products.controller';
import { ProductsSearchController } from './search.controller';
import { ProductUpdateTasksService } from './product-update-tasks.service';
import { ProductUpdateTasksController } from './product-update-tasks.controller';
import { Product } from './entities/product.entity';
import { ProductUpdateTask } from './entities/product-update-task.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Product, ProductUpdateTask])],
  controllers: [ProductsController, ProductsSearchController, ProductUpdateTasksController],
  providers: [ProductsService, ProductUpdateTasksService],
  exports: [ProductsService, ProductUpdateTasksService],
})
export class ProductsModule {}