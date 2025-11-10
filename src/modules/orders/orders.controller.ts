import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request, Query } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderDto } from './dto/update-order.dto';
import { UpdateOrderItemsDto } from './dto/update-order-items.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  create(@Body() createOrderDto: CreateOrderDto, @Request() req) {
    return this.ordersService.create(createOrderDto, req.user.userId);
  }

  @Get()
  findAll(
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.ordersService.findAll(search, status, page, limit);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateOrderDto: UpdateOrderDto, @Request() req) {
    return this.ordersService.update(id, updateOrderDto, req.user.role, req.user.userId);
  }

  @Patch('items/quantities')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  updateRequestedQuantities(@Body() updateItemsDto: UpdateOrderItemsDto[], @Request() req) {
    return this.ordersService.updateRequestedQuantities(updateItemsDto, req.user.role);
  }

  @Post(':id/items')
  addProductToOrder(
    @Param('id') orderId: string,
    @Body() addProductDto: { productId?: string; temporaryProductId?: string; existingQuantity: number; requestedQuantity?: number; measurementUnit: string; supplierId?: string },
    @Request() req
  ) {
    return this.ordersService.addProductToOrder(orderId, addProductDto, req.user.role, req.user.userId);
  }

  @Delete(':id/items/:itemId')
  removeProductFromOrder(
    @Param('id') orderId: string,
    @Param('itemId') itemId: string,
    @Request() req
  ) {
    return this.ordersService.removeProductFromOrder(orderId, itemId, req.user.role, req.user.userId);
  }

  @Patch(':id/items/:itemId')
  updateOrderItemQuantity(
    @Param('id') orderId: string,
    @Param('itemId') itemId: string,
    @Body() updateDto: { existingQuantity?: number; requestedQuantity?: number; measurementUnit?: string; supplierId?: string },
    @Request() req
  ) {
    return this.ordersService.updateOrderItemQuantity(orderId, itemId, updateDto, req.user.role, req.user.userId);
  }

  @Get(':id/by-supplier')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR)
  getOrderGroupedBySupplier(@Param('id') id: string) {
    return this.ordersService.groupItemsBySupplier(id);
  }

  @Patch(':id/items/:itemId/supplier')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  assignSupplierToItem(
    @Param('id') orderId: string,
    @Param('itemId') itemId: string,
    @Body('supplierId') supplierId: string,
    @Request() req
  ) {
    return this.ordersService.assignSupplierToItem(orderId, itemId, supplierId, req.user.role);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.ordersService.remove(id);
  }
}