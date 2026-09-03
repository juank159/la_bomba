import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { VegetableExpensesService } from './vegetable-expenses.service';
import { CreateVegetableExpenseDto } from './dto/create-vegetable-expense.dto';
import { UpdateVegetableExpenseDto } from './dto/update-vegetable-expense.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('vegetable-expenses')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.VERDULERO)
export class VegetableExpensesController {
  constructor(private readonly vegetableExpensesService: VegetableExpensesService) {}

  @Post()
  create(@Body() dto: CreateVegetableExpenseDto, @Request() req) {
    return this.vegetableExpensesService.create(dto, req.user.userId);
  }

  @Get()
  findAll() {
    return this.vegetableExpensesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.vegetableExpensesService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateVegetableExpenseDto) {
    return this.vegetableExpensesService.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.vegetableExpensesService.remove(id);
  }
}
