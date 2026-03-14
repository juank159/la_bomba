import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { IncomesService } from './incomes.service';
import { CreateIncomeDto } from './dto/create-income.dto';
import { UpdateIncomeDto } from './dto/update-income.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('incomes')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class IncomesController {
  constructor(private readonly incomesService: IncomesService) {}

  @Post()
  create(@Body() createIncomeDto: CreateIncomeDto, @Request() req) {
    return this.incomesService.create(createIncomeDto, req.user.userId);
  }

  @Get()
  findAll() {
    return this.incomesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.incomesService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateIncomeDto: UpdateIncomeDto) {
    return this.incomesService.update(id, updateIncomeDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.incomesService.remove(id);
  }
}
