import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { VegetablesService } from './vegetables.service';
import { CreateVegetableItemDto } from './dto/create-vegetable-item.dto';
import { UpdateVegetableItemDto } from './dto/update-vegetable-item.dto';
import { CreateVegetableCategoryDto } from './dto/create-vegetable-category.dto';
import { UpdateVegetableCategoryDto } from './dto/update-vegetable-category.dto';
import { CreateVegetableSaleDto } from './dto/create-vegetable-sale.dto';
import { CreateVegetableOrderDto } from './dto/create-vegetable-order.dto';
import { CreateStockMovementDto } from './dto/create-stock-movement.dto';
import { CreateVegetablePurchaseDto } from './dto/create-vegetable-purchase.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('vegetables')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.VERDULERO)
export class VegetablesController {
  constructor(private readonly vegetablesService: VegetablesService) {}

  // ---- Categorías ----

  @Post('categories')
  createCategory(@Body() dto: CreateVegetableCategoryDto) {
    return this.vegetablesService.createCategory(dto);
  }

  @Get('categories')
  findAllCategories(@Query('includeInactive') includeInactive?: string) {
    return this.vegetablesService.findAllCategories(includeInactive === 'true');
  }

  @Get('categories/:id')
  findOneCategory(@Param('id') id: string) {
    return this.vegetablesService.findOneCategory(id);
  }

  @Patch('categories/:id')
  updateCategory(@Param('id') id: string, @Body() dto: UpdateVegetableCategoryDto) {
    return this.vegetablesService.updateCategory(id, dto);
  }

  @Delete('categories/:id')
  removeCategory(@Param('id') id: string) {
    return this.vegetablesService.removeCategory(id);
  }

  // ---- Catálogo ----

  @Post('items')
  createItem(@Body() dto: CreateVegetableItemDto) {
    return this.vegetablesService.createItem(dto);
  }

  @Get('items')
  findAllItems(@Query('includeInactive') includeInactive?: string) {
    return this.vegetablesService.findAllItems(includeInactive === 'true');
  }

  @Get('items/:id')
  findOneItem(@Param('id') id: string) {
    return this.vegetablesService.findOneItem(id);
  }

  @Patch('items/:id')
  updateItem(@Param('id') id: string, @Body() dto: UpdateVegetableItemDto) {
    return this.vegetablesService.updateItem(id, dto);
  }

  @Delete('items/:id')
  removeItem(@Param('id') id: string) {
    return this.vegetablesService.removeItem(id);
  }

  // ---- Ventas ----

  @Post('sales')
  createSale(@Body() dto: CreateVegetableSaleDto, @Request() req) {
    return this.vegetablesService.createSale(dto, req.user.username);
  }

  @Get('sales')
  findAllSales() {
    return this.vegetablesService.findAllSales();
  }

  @Get('sales/:id')
  findOneSale(@Param('id') id: string) {
    return this.vegetablesService.findOneSale(id);
  }

  // ---- Pedidos ----

  @Post('orders')
  createOrder(@Body() dto: CreateVegetableOrderDto, @Request() req) {
    return this.vegetablesService.createOrder(dto, req.user.username);
  }

  @Get('orders')
  findAllOrders() {
    return this.vegetablesService.findAllOrders();
  }

  @Get('orders/:id')
  findOneOrder(@Param('id') id: string) {
    return this.vegetablesService.findOneOrder(id);
  }

  // ---- Inventario / Merma ----

  @Post('items/:id/stock-movements')
  registerStockMovement(
    @Param('id') id: string,
    @Body() dto: CreateStockMovementDto,
    @Request() req,
  ) {
    return this.vegetablesService.registerStockMovement(id, dto, req.user.username);
  }

  @Get('items/:id/stock-movements')
  findStockMovements(@Param('id') id: string) {
    return this.vegetablesService.findStockMovements(id);
  }

  // ---- Compras ----

  @Post('purchases')
  createPurchase(@Body() dto: CreateVegetablePurchaseDto, @Request() req) {
    return this.vegetablesService.createPurchase(dto, req.user.username);
  }

  @Get('purchases')
  findAllPurchases() {
    return this.vegetablesService.findAllPurchases();
  }

  @Get('purchases/:id')
  findOnePurchase(@Param('id') id: string) {
    return this.vegetablesService.findOnePurchase(id);
  }
}
