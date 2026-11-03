import {
  Controller, Get, Post, Body, Param, UseGuards, Request, HttpCode, HttpStatus,
  ForbiddenException, UnauthorizedException,
} from '@nestjs/common';
import { VegetableCashSessionsService } from './vegetable-cash-sessions.service';
import { OpenCashSessionDto } from './dto/open-cash-session.dto';
import { CloseCashSessionDto } from './dto/close-cash-session.dto';
import { SessionReportDto } from './dto/session-report.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { AuthService } from '../auth/auth.service';

/**
 * Caja de verduras. Para el rol verdulero el cierre es A CIEGAS: el backend
 * nunca le devuelve lo esperado, la diferencia ni los totales del turno. El
 * cuadre completo (POST :id/report) exige la contraseña de Adalberto, que
 * se valida acá en el servidor contra la base de datos.
 */
@Controller('vegetable-cash-sessions')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.VERDULERO)
export class VegetableCashSessionsController {
  constructor(
    private readonly cashSessionsService: VegetableCashSessionsService,
    private readonly authService: AuthService,
  ) {}

  private isBlind(req): boolean {
    return req.user?.role !== UserRole.ADMIN;
  }

  @Post('open')
  open(@Body() dto: OpenCashSessionDto, @Request() req) {
    return this.cashSessionsService.open(dto, req.user.username);
  }

  @Post('close')
  async close(@Body() dto: CloseCashSessionDto, @Request() req) {
    const session = await this.cashSessionsService.close(dto, req.user.username);
    return this.isBlind(req) ? VegetableCashSessionsService.redact(session) : session;
  }

  @Get('current')
  async getCurrent(@Request() req) {
    const current = await this.cashSessionsService.getCurrent();
    if (!this.isBlind(req)) return current;
    return {
      session: current.session ? VegetableCashSessionsService.redact(current.session) : null,
      isStale: current.isStale,
      blind: true,
      cashSales: null,
      cashExpenses: null,
      cashPurchases: null,
      expectedAmount: null,
      paymentBreakdown: [],
    };
  }

  @Get()
  async findAll(@Request() req) {
    const sessions = await this.cashSessionsService.findAll();
    return this.isBlind(req) ? sessions.map((s) => VegetableCashSessionsService.redact(s)) : sessions;
  }

  /// Cuadre completo del turno. Pide la contraseña de Adalberto a todos
  /// (también al admin): es la única forma de ver cuánto debía haber.
  @Post(':id/report')
  @HttpCode(HttpStatus.OK)
  async getReport(@Param('id') id: string, @Body() dto: SessionReportDto) {
    try {
      await this.authService.verifyPassword(dto.password);
    } catch (err) {
      // 403 y no 401: un 401 haría que la app intente renovar el token y
      // podría cerrarle la sesión al cajero por equivocarse de clave.
      if (err instanceof UnauthorizedException) {
        throw new ForbiddenException('Contraseña incorrecta');
      }
      throw err;
    }
    return this.cashSessionsService.getReport(id);
  }

  @Get(':id')
  async findOne(@Param('id') id: string, @Request() req) {
    const session = await this.cashSessionsService.findOneWithTotals(id);
    if (!this.isBlind(req)) return session;
    return { ...VegetableCashSessionsService.redact(session), cashSales: null, cashExpenses: null, cashPurchases: null };
  }

  @Get(':id/payment-breakdown')
  @Roles(UserRole.ADMIN)
  getBreakdown(@Param('id') id: string) {
    return this.cashSessionsService.getBreakdown(id);
  }

  @Get(':id/sales')
  @Roles(UserRole.ADMIN)
  getSales(@Param('id') id: string) {
    return this.cashSessionsService.getSales(id);
  }
}
