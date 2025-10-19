import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('products')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  create(@Body() createProductDto: CreateProductDto) {
    return this.productsService.create(createProductDto);
  }

  @Get()
  // Los empleados, supervisores y administradores pueden ver productos
  findAll(
    @Query('search') search?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    try {
      console.log('FindAll called with:', { search, page, limit });
      return this.productsService.findAll(search, page, limit);
    } catch (error) {
      console.error('Error in findAll controller:', error);
      throw error;
    }
  }

  @Get('by-id/:id')
  // Los empleados, supervisores y administradores pueden ver detalles de productos
  findOne(@Param('id') id: string, @Request() req: any) {
    console.log('🔍 GET /products/by-id/' + id + ' called by:', req.user?.role);
    // Los administradores y supervisores pueden ver todos los productos (incluso inactivos)
    if (req.user?.role === UserRole.ADMIN || req.user?.role === UserRole.SUPERVISOR) {
      console.log('👑 Admin/Supervisor access - using findOneForAdmin');
      return this.productsService.findOneForAdmin(id);
    }
    // Los empleados solo ven productos activos
    console.log('👤 Employee access - using findOne (active only)');
    return this.productsService.findOne(id);
  }

  @Patch('by-id/:id')
  @Roles(UserRole.ADMIN)
  update(@Param('id') id: string, @Body() updateProductDto: UpdateProductDto, @Request() req: any) {
    console.log('🔄 PATCH /products/by-id/' + id + ' called');
    console.log('👤 Full req.user object:', JSON.stringify(req.user, null, 2));
    console.log('🆔 req.user.userId:', req.user?.userId);
    console.log('🆔 req.user.id:', req.user?.id);
    console.log('📊 Update data:', updateProductDto);
    return this.productsService.update(id, updateProductDto, req.user?.userId);
  }

  @Delete('by-id/:id')
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.productsService.remove(id);
  }
}