import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req } from '@nestjs/common';
import { CreditsService } from './credits.service';
import { CreateCreditDto } from './dto/create-credit.dto';
import { UpdateCreditDto } from './dto/update-credit.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { AddAmountToCreditDto } from './dto/add-amount-to-credit.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('credits')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class CreditsController {
  constructor(private readonly creditsService: CreditsService) {}

  @Post()
  create(@Body() createCreditDto: CreateCreditDto, @Req() req: any) {
    return this.creditsService.create(createCreditDto, req.user.username);
  }

  @Get()
  findAll() {
    return this.creditsService.findAll();
  }

  @Get('client/:clientId/pending')
  findPendingCreditByClient(@Param('clientId') clientId: string) {
    return this.creditsService.findPendingCreditByClient(clientId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.creditsService.findOne(id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updateCreditDto: UpdateCreditDto, @Req() req: any) {
    return this.creditsService.update(id, updateCreditDto, req.user.username);
  }

  @Post(':id/add-amount')
  addAmountToCredit(@Param('id') id: string, @Body() addAmountDto: AddAmountToCreditDto, @Req() req: any) {
    return this.creditsService.addAmountToCredit(id, addAmountDto.amount, addAmountDto.description, req.user.username);
  }

  @Post(':id/payments')
  addPayment(@Param('id') id: string, @Body() createPaymentDto: CreatePaymentDto, @Req() req: any) {
    return this.creditsService.addPayment(id, createPaymentDto, req.user.username);
  }

  // TODO: Endpoint de eliminar pago comentado temporalmente
  // hasta definir el comportamiento correcto para manejo de dinero
  // @Delete(':id/payments/:paymentId')
  // removePayment(@Param('id') id: string, @Param('paymentId') paymentId: string, @Req() req: any) {
  //   return this.creditsService.removePayment(id, paymentId, req.user.username);
  // }

  // TODO: Endpoint de eliminar crédito comentado temporalmente
  // hasta definir el comportamiento correcto para manejo de dinero
  // @Delete(':id')
  // remove(@Param('id') id: string, @Req() req: any) {
  //   return this.creditsService.remove(id, req.user.username);
  // }
}