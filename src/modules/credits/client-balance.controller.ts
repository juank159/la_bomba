import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { ClientBalanceService } from './client-balance.service';
import { UseBalanceDto } from './dto/use-balance.dto';
import { RefundBalanceDto } from './dto/refund-balance.dto';
import { AdjustBalanceDto } from './dto/adjust-balance.dto';
import { ClientBalanceResponseDto } from './dto/client-balance-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('client-balance')
@Controller('client-balance')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
export class ClientBalanceController {
  constructor(private readonly clientBalanceService: ClientBalanceService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener todos los saldos de clientes (con saldo > 0)' })
  @ApiResponse({ status: 200, description: 'Lista de saldos de clientes', type: [ClientBalanceResponseDto] })
  async getAllClientBalances() {
    const balances = await this.clientBalanceService.getAllClientBalances();
    return balances.map((balance) => this.clientBalanceService.toResponseDto(balance));
  }

  @Get('client/:clientId')
  @ApiOperation({ summary: 'Obtener saldo de un cliente específico' })
  @ApiResponse({ status: 200, description: 'Saldo del cliente', type: ClientBalanceResponseDto })
  @ApiResponse({ status: 404, description: 'Cliente no encontrado' })
  async getClientBalance(@Param('clientId') clientId: string) {
    const balance = await this.clientBalanceService.getClientBalance(clientId);

    if (!balance) {
      // Si no existe, crear uno con saldo 0
      return {
        clientId,
        balance: 0,
        transactions: [],
      };
    }

    return this.clientBalanceService.toResponseDto(balance);
  }

  @Get('client/:clientId/transactions')
  @ApiOperation({ summary: 'Obtener historial de transacciones de un cliente' })
  @ApiResponse({ status: 200, description: 'Historial de transacciones' })
  async getClientTransactions(@Param('clientId') clientId: string) {
    const transactions = await this.clientBalanceService.getClientTransactions(clientId);
    return transactions.map((t) => ({
      id: t.id,
      type: t.type,
      amount: Number(t.amount),
      description: t.description,
      balanceAfter: Number(t.balanceAfter),
      relatedCreditId: t.relatedCreditId,
      relatedOrderId: t.relatedOrderId,
      createdBy: t.createdBy,
      createdAt: t.createdAt,
    }));
  }

  @Post('use')
  @ApiOperation({ summary: 'Usar saldo del cliente para pagar crédito u orden' })
  @ApiResponse({ status: 200, description: 'Saldo actualizado', type: ClientBalanceResponseDto })
  @ApiResponse({ status: 400, description: 'Saldo insuficiente o validación fallida' })
  @ApiResponse({ status: 404, description: 'Cliente no encontrado' })
  async useBalance(@Body() useBalanceDto: UseBalanceDto, @Req() req: any) {
    const balance = await this.clientBalanceService.useBalance(useBalanceDto, req.user.username);
    return this.clientBalanceService.toResponseDto(balance);
  }

  @Post('refund')
  @ApiOperation({ summary: 'Devolver saldo al cliente (reembolso)' })
  @ApiResponse({ status: 200, description: 'Saldo actualizado', type: ClientBalanceResponseDto })
  @ApiResponse({ status: 400, description: 'Monto excede saldo disponible o validación fallida' })
  @ApiResponse({ status: 404, description: 'Cliente no encontrado' })
  async refundBalance(@Body() refundBalanceDto: RefundBalanceDto, @Req() req: any) {
    const balance = await this.clientBalanceService.refundBalance(refundBalanceDto, req.user.username);
    return this.clientBalanceService.toResponseDto(balance);
  }

  @Post('adjust')
  @ApiOperation({ summary: 'Ajustar saldo manualmente (corrección)' })
  @ApiResponse({ status: 200, description: 'Saldo actualizado', type: ClientBalanceResponseDto })
  @ApiResponse({ status: 400, description: 'Validación fallida' })
  async adjustBalance(@Body() adjustBalanceDto: AdjustBalanceDto, @Req() req: any) {
    const balance = await this.clientBalanceService.adjustBalance(adjustBalanceDto, req.user.username);
    return this.clientBalanceService.toResponseDto(balance);
  }
}
