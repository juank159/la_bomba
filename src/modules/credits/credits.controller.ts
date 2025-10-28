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

  /**
   * 🔧 Aplicar saldo a favor manualmente a un crédito existente
   * Útil para corregir créditos donde el saldo no se aplicó automáticamente
   *
   * POST /credits/:id/apply-client-balance
   */
  @Post(':id/apply-client-balance')
  applyClientBalanceManually(@Param('id') id: string, @Req() req: any) {
    return this.creditsService.applyClientBalanceManually(id, req.user.username);
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

  /**
   * 🧪 ENDPOINT DE TESTING - Verificar notificaciones de créditos vencidos manualmente
   * Este endpoint permite probar el sistema de notificaciones sin esperar 30 días
   *
   * Uso:
   * GET /credits/test-overdue-notifications?days=1
   *
   * El parámetro 'days' es opcional (default: 1 día para testing)
   *
   * ⚠️ ELIMINAR O COMENTAR EN PRODUCCIÓN
   */
  // @Get('test-overdue-notifications')
  // async testOverdueNotifications(@Req() req: any) {
  //   console.log(`🧪 [Testing] Usuario ${req.user.username} ejecutó verificación manual de créditos vencidos`);
  //
  //   // Para testing, usamos 1 minuto (0.0007 días) en lugar de 30 días
  //   await this.creditsService.checkOverdueCredits(0.0007); // 1 minuto = 1/(24*60) días
  //
  //   return {
  //     message: 'Verificación de créditos vencidos ejecutada exitosamente (modo testing: 1+ minuto sin pagos)',
  //     timestamp: new Date().toISOString(),
  //     note: 'Revisa la campana de notificaciones en la app',
  //   };
  // }
}