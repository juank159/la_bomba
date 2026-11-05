import {
  BadRequestException,
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Put,
  Query,
  Request,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import { SkipThrottle } from '@nestjs/throttler';
import { Roles } from '../../common/decorators/roles.decorator';
import { RolesGuard } from '../../common/guards/roles.guard';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UserRole } from '../users/entities/user.entity';
import { BrebActor, BrebService } from './breb.service';
import {
  AssignBrebPaymentDto,
  CreateBrebChargeDto,
  PreviewBrebQrDto,
  UpdateBrebSettingsDto,
} from './dto/breb.dto';
import { InvalidEmvQrTemplateError } from './utils/emv-qr.util';

const actorOf = (req: any): BrebActor => ({
  userId: req.user.userId,
  username: req.user.username,
  role: req.user.role,
});

@Controller('breb')
export class BrebController {
  constructor(private readonly brebService: BrebService) {}

  // ───────────── Cobro (cajero: admin o verdulero) ─────────────
  // El verdulero solo puede tocar cobros de Verduras: lo valida el servicio
  // (assertModuleAllowed), además del rol de cada endpoint.

  @Post('charge')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.VERDULERO)
  @HttpCode(HttpStatus.OK)
  createCharge(@Body() dto: CreateBrebChargeDto, @Request() req) {
    return this.brebService.createCharge(dto.module, dto.draft, dto.amount, actorOf(req), dto.restPaymentMethodId);
  }

  @Get('status/:chargeId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.VERDULERO)
  @SkipThrottle() // polling cada 3 s
  getStatus(@Param('chargeId', ParseUUIDPipe) chargeId: string, @Request() req) {
    return this.brebService.getStatus(chargeId, actorOf(req));
  }

  @Post('cancel/:chargeId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.VERDULERO)
  @HttpCode(HttpStatus.OK)
  cancel(@Param('chargeId', ParseUUIDPipe) chargeId: string, @Request() req) {
    return this.brebService.cancel(chargeId, actorOf(req));
  }

  @Get('unassigned')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.VERDULERO)
  listAssignable() {
    return this.brebService.listAssignable();
  }

  @Post('assign')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.VERDULERO)
  @HttpCode(HttpStatus.OK)
  assign(@Body() dto: AssignBrebPaymentDto, @Request() req) {
    return this.brebService.assignManually(dto.chargeId, dto.emailId, actorOf(req), dto.restPaymentMethodId);
  }

  // ───────────── Configuración e historial (solo admin) ─────────────

  @Get('settings')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  getSettings() {
    return this.brebService.getSettings();
  }

  @Put('settings')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  updateSettings(@Body() dto: UpdateBrebSettingsDto, @Request() req) {
    return this.brebService.updateSettings(dto.llaves, req.user.username);
  }

  @Post('qr-preview')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.OK)
  previewQr(@Body() dto: PreviewBrebQrDto) {
    try {
      return { payload: this.brebService.previewQr(dto.template, dto.amount) };
    } catch (err) {
      if (err instanceof InvalidEmvQrTemplateError) throw new BadRequestException(err.message);
      throw err;
    }
  }

  @Get('recent-emails')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  getRecentEmails() {
    return this.brebService.getRecentUnmatchedEmails();
  }

  @Get('charges')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  listCharges(
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('module') module?: 'vegetables' | 'invoices',
  ) {
    const parse = (v?: string) => {
      if (!v) return undefined;
      const d = new Date(v);
      if (isNaN(d.getTime())) throw new BadRequestException(`Fecha inválida: ${v}`);
      return d;
    };
    if (module && module !== 'vegetables' && module !== 'invoices') {
      throw new BadRequestException('module debe ser vegetables o invoices');
    }
    return this.brebService.listCharges({ from: parse(from), to: parse(to), module });
  }

  /**
   * Webhook de correo entrante (Mailgun Inbound Routes). Sin JWT: Mailgun no
   * lo manda. La autenticidad se verifica con la firma HMAC del body
   * (`timestamp`, `token`, `signature`) usando MAILGUN_SIGNING_KEY.
   * Mailgun postea multipart/form-data (puede traer adjuntos).
   */
  @Post('inbound-email')
  @UseInterceptors(AnyFilesInterceptor())
  @SkipThrottle()
  @HttpCode(HttpStatus.OK)
  inboundEmail(@Body() rawBody: Record<string, string> | undefined) {
    // Petición sin cuerpo (no es de Mailgun): se rechaza por firma ausente
    // (401) en vez de romper con un 500.
    const body = rawBody ?? {};
    return this.brebService.handleInboundEmail({
      timestamp: body.timestamp,
      token: body.token,
      signature: body.signature,
      recipient: body.recipient,
      from: body.From ?? body.from,
      sender: body.sender,
      bodyPlain: body['body-plain'] ?? body.bodyPlain,
      messageHeaders: body['message-headers'],
    });
  }
}
