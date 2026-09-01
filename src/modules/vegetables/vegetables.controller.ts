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
import { CreateVegetableSaleDto } from './dto/create-vegetable-sale.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('vegetables')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.VERDULERO)
export class VegetablesController {
  constructor(private readonly vegetablesService: VegetablesService) {}

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
}
