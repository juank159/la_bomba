import { Controller, Get, Post, Body, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { CorresponsalService } from './corresponsal.service';
import { CreateCorresponsalEntryDto } from './dto/create-corresponsal-entry.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('corresponsal')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class CorresponsalController {
  constructor(private readonly corresponsalService: CorresponsalService) {}

  @Post()
  create(@Body() dto: CreateCorresponsalEntryDto, @Request() req) {
    return this.corresponsalService.create(dto, req.user.userId);
  }

  @Get()
  findAll() {
    return this.corresponsalService.findAll();
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.corresponsalService.remove(id);
  }
}
