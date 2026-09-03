import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { VegetableCashSessionsService } from './vegetable-cash-sessions.service';
import { OpenCashSessionDto } from './dto/open-cash-session.dto';
import { CloseCashSessionDto } from './dto/close-cash-session.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('vegetable-cash-sessions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.VERDULERO)
export class VegetableCashSessionsController {
  constructor(private readonly cashSessionsService: VegetableCashSessionsService) {}

  @Post('open')
  open(@Body() dto: OpenCashSessionDto, @Request() req) {
    return this.cashSessionsService.open(dto, req.user.username);
  }

  @Post('close')
  close(@Body() dto: CloseCashSessionDto, @Request() req) {
    return this.cashSessionsService.close(dto, req.user.username);
  }

  @Get('current')
  getCurrent() {
    return this.cashSessionsService.getCurrent();
  }

  @Get()
  findAll() {
    return this.cashSessionsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.cashSessionsService.findOne(id);
  }
}
