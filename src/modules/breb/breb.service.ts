import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
  OnModuleInit,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectDataSource } from '@nestjs/typeorm';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import * as crypto from 'crypto';
import { DataSource, MoreThan } from 'typeorm';
import { BREB_PAYMENT_METHOD_CODE, BrebSaleInfo } from '../../common/types/breb-sale-info';
import { PaymentMethod } from '../credits/entities/payment-method.entity';
import { CreateInvoiceDto } from '../invoices/dto/create-invoice.dto';
import { Invoice } from '../invoices/entities/invoice.entity';
import { InvoicesService } from '../invoices/invoices.service';
import { FirebaseNotificationService } from '../notifications/firebase-notification.service';
import { UserRole } from '../users/entities/user.entity';
import { VegetableCashSessionsService } from '../vegetable-cash-sessions/vegetable-cash-sessions.service';
import { CreateVegetableSaleDto } from '../vegetables/dto/create-vegetable-sale.dto';
import { VegetableSale } from '../vegetables/entities/vegetable-sale.entity';
import { VegetablesService } from '../vegetables/vegetables.service';
import { BrebConfig, BrebLlaveConfig } from './entities/breb-config.entity';
import {
  BrebChargeModule,
  BrebPendingCharge,
} from './entities/breb-pending-charge.entity';
import {
  BREB_ASSIGNABLE_REASONS,
  BrebUnmatchedEmail,
} from './entities/breb-unmatched-email.entity';
import { BankParseResult, findBankAdapter } from './parsers';
import { buildDynamicQrPayload, InvalidEmvQrTemplateError } from './utils/emv-qr.util';

/** Máximo de pesos que se baja un cobro para que su monto sea único. */
export const MAX_BREB_ADJUSTMENT = 9;

const CONFIG_ID = 1;

/**
 * Elige el monto del cobro: el pedido si está libre, si no el primero
 * libre bajando de a $1 (hasta `MAX_BREB_ADJUSTMENT`). `usedCents` son los
 * montos (en centavos) de los cobros pendientes. `null` si están todos
 * ocupados.
 */
export function pickUniqueAmount(requested: number, usedCents: Set<number>): number | null {
  for (let d = 0; d <= MAX_BREB_ADJUSTMENT; d++) {
    const candidate = Math.round((requested - d) * 100) / 100;
    if (candidate <= 0) return null;
    if (!usedCents.has(Math.round(candidate * 100))) return candidate;
  }
  return null;
}

/** Quién está pidiendo — para restringir por módulo y para el push. */
export interface BrebActor {
  userId: string;
  username: string;
  role: UserRole | string;
}

/**
 * BrebService — cobros con llaves Bre-B conciliados por el correo que el
 * banco (Nequi / Bancolombia) manda al recibir la transferencia. Es el
 * mismo diseño ya probado en Food App:
 *
 *   1. createCharge()       → el cajero cobra $X; queda "pending" unos minutos
 *                             con el borrador de la venta guardado.
 *   2. getStatus()          → polling desde Flutter cada 3 s (red de seguridad
 *                             del push).
 *   3. handleInboundEmail() → llega el correo reenviado (Mailgun Inbound
 *                             Routes), se valida la firma, se lee con el
 *                             adaptador del banco y se concilia con el cobro
 *                             pendiente del mismo monto exacto → se REGISTRA
 *                             la venta/factura y se avisa por push.
 *
 * Lo que no se pudo conciliar solo nunca se pierde: queda en
 * `breb_unmatched_emails` y el cajero lo asigna a mano con un toque.
 */
@Injectable()
export class BrebService implements OnModuleInit {
  private readonly logger = new Logger(BrebService.name);

  constructor(
    @InjectDataSource()
    private readonly dataSource: DataSource,
    private readonly config: ConfigService,
    private readonly notifications: FirebaseNotificationService,
    private readonly vegetablesService: VegetablesService,
    private readonly invoicesService: InvoicesService,
    private readonly cashSessionsService: VegetableCashSessionsService,
  ) {}

  // ───────────────────────── Arranque ─────────────────────────────

  /**
   * Garantiza la fila de configuración y el método de pago "Bre-B". Nunca
   * tumba el arranque: si en producción todavía no se corrió la migración
   * 020, solo se loguea (el resto de la app sigue funcionando).
   */
  async onModuleInit(): Promise<void> {
    try {
      await this.getOrCreateConfig();
      await this.getBrebPaymentMethod();
    } catch (err) {
      this.logger.error(
        `No se pudo preparar Bre-B (¿falta la migración 020?): ${(err as Error).message}`,
      );
    }
  }

  private async getOrCreateConfig(): Promise<BrebConfig> {
    const repo = this.dataSource.getRepository(BrebConfig);
    let cfg = await repo.findOne({ where: { id: CONFIG_ID } });
    if (!cfg) {
      cfg = repo.create({
        id: CONFIG_ID,
        llaves: [],
        inboundSlug: crypto.randomBytes(6).toString('hex'),
        updatedBy: null,
      });
      await repo.save(cfg);
    }
    return cfg;
  }

  /** El método de pago "Bre-B" (código `breb`), creándolo si no existe. */
  async getBrebPaymentMethod(): Promise<PaymentMethod> {
    const repo = this.dataSource.getRepository(PaymentMethod);
    let pm = await repo.findOne({ where: { code: BREB_PAYMENT_METHOD_CODE } });
    if (!pm) {
      pm = repo.create({
        name: 'Bre-B',
        description: 'Transferencia con llave Bre-B confirmada automáticamente por el banco',
        icon: 'breb',
        isActive: true,
        isCash: false,
        code: BREB_PAYMENT_METHOD_CODE,
        createdBy: 'system',
      });
      pm = await repo.save(pm);
      this.logger.log('Método de pago "Bre-B" creado');
    }
    return pm;
  }

  // ─────────────────────── Configuración (admin) ───────────────────

  async getSettings(): Promise<{ llaves: BrebLlaveConfig[]; inboundEmail: string }> {
    const cfg = await this.getOrCreateConfig();
    return { llaves: cfg.llaves ?? [], inboundEmail: this.inboundEmailFor(cfg) };
  }

  async updateSettings(
    llaves: BrebLlaveConfig[],
    username: string,
  ): Promise<{ llaves: BrebLlaveConfig[]; inboundEmail: string }> {
    const clean: BrebLlaveConfig[] = llaves.map((l) => ({
      id: l.id.trim(),
      label: l.label.trim() || 'Llave',
      llave: l.llave.trim(),
      ...(l.qr_template?.trim() ? { qr_template: l.qr_template.trim() } : {}),
      show_in_invoices: !!l.show_in_invoices,
      show_in_vegetables: !!l.show_in_vegetables,
    }));
    // Un QR mal pegado se detecta ACÁ, no con un cliente esperando en caja.
    for (const l of clean) {
      if (!l.qr_template) continue;
      try {
        buildDynamicQrPayload(l.qr_template, 1000);
      } catch (err) {
        if (err instanceof InvalidEmvQrTemplateError) {
          throw new BadRequestException(`QR de "${l.label}": ${err.message}`);
        }
        throw err;
      }
    }
    const cfg = await this.getOrCreateConfig();
    cfg.llaves = clean;
    cfg.updatedBy = username;
    await this.dataSource.getRepository(BrebConfig).save(cfg);
    return { llaves: clean, inboundEmail: this.inboundEmailFor(cfg) };
  }

  previewQr(template: string, amount: number): string {
    return buildDynamicQrPayload(template, amount);
  }

  private inboundEmailFor(cfg: BrebConfig): string {
    const domain = this.config.get<string>('BREB_INBOUND_DOMAIN', 'notificaciones.tudominio.co');
    return `pagos-${cfg.inboundSlug}@${domain}`;
  }

  /** Últimos correos que no se conciliaron solos (diagnóstico/onboarding). */
  async getRecentUnmatchedEmails(): Promise<BrebUnmatchedEmail[]> {
    return this.dataSource.getRepository(BrebUnmatchedEmail).find({
      order: { createdAt: 'DESC' },
      take: 20,
    });
  }

  // ───────────────────────── Cobro (cajero) ─────────────────────────

  /** El verdulero solo puede cobrar/ver cobros de Verduras; Facturación es del admin. */
  assertModuleAllowed(module: BrebChargeModule, actor: BrebActor): void {
    if (actor.role === UserRole.ADMIN) return;
    if (module === 'vegetables' && actor.role === UserRole.VERDULERO) return;
    throw new ForbiddenException('No tienes permiso para cobrar con Bre-B en este módulo');
  }

  async createCharge(
    module: BrebChargeModule,
    draft: Record<string, any>,
    amount: number,
    actor: BrebActor,
  ): Promise<{
    chargeId: string;
    amount: number;
    requestedAmount: number;
    llaves: Array<{ id: string; label: string; llave: string; qrPayload: string | null }>;
    expiresAt: Date;
  }> {
    this.assertModuleAllowed(module, actor);

    const cfg = await this.getOrCreateConfig();
    const llaves = (cfg.llaves ?? []).filter((l) =>
      module === 'vegetables' ? l.show_in_vegetables : l.show_in_invoices,
    );
    if (llaves.length === 0) {
      throw new BadRequestException(
        `No hay llaves Bre-B habilitadas para ${module === 'vegetables' ? 'Verduras' : 'Facturación'}. ` +
          'El administrador las configura en Administración → Pagos Bre-B.',
      );
    }

    // El borrador se valida YA (mismo DTO que el cobro normal): si algo
    // está mal, que falle ahora y no cuando el cliente ya transfirió.
    const pm = await this.getBrebPaymentMethod();
    const cleanDraft = await this.validateDraft(module, draft, pm.id);

    // Mismas reglas que la venta real: carrito válido y total = lo cobrado.
    const computed =
      module === 'vegetables'
        ? await this.vegetablesService.previewSaleTotal(cleanDraft as CreateVegetableSaleDto)
        : await this.invoicesService.previewInvoiceTotal(cleanDraft as CreateInvoiceDto);
    if (Math.abs(computed - Number(amount)) > 0.5) {
      throw new BadRequestException(
        `El total del carrito (${Math.round(computed)}) no coincide con el valor a cobrar (${Math.round(Number(amount))}). Actualiza la pantalla e intenta de nuevo.`,
      );
    }

    if (module === 'vegetables') {
      const open = await this.cashSessionsService.getCurrentOpenSessionForToday();
      if (!open) {
        throw new BadRequestException('No hay una caja abierta hoy. Abre la caja antes de vender.');
      }
    }

    const ttlMinutes = Number(this.config.get('BREB_CHARGE_TTL_MINUTES', 10)) || 10;
    const expiresAt = new Date(Date.now() + ttlMinutes * 60_000);

    // Monto ÚNICO entre los cobros pendientes. El correo del banco solo trae
    // el monto (y a veces la llave): si Verduras y Facturación cobran
    // $5.000 a la vez, no habría forma de saber cuál pagó. Se ajusta HACIA
    // ABAJO (el cliente nunca paga de más; el negocio absorbe $1–$9 solo
    // cuando coinciden). El lock serializa la elección entre cajas.
    const requested = Math.round(Number(amount) * 100) / 100;
    const record = await this.dataSource.transaction(async (tx) => {
      await tx.query('SELECT pg_advisory_xact_lock(hashtext($1))', ['breb:labomba']);
      const taken: Array<{ amount: string }> = await tx.query(
        `SELECT amount FROM breb_pending_charges
         WHERE status IN ('pending', 'matching') AND expires_at > now()
           AND amount BETWEEN $1 AND $2`,
        [requested - MAX_BREB_ADJUSTMENT, requested],
      );
      const used = new Set(taken.map((t) => Math.round(Number(t.amount) * 100)));
      const chosen = pickUniqueAmount(requested, used);
      if (chosen === null) {
        throw new BadRequestException(
          `Hay ${MAX_BREB_ADJUSTMENT + 1} cobros Bre-B pendientes por valores casi iguales. ` +
            'Espera a que se confirme alguno o cancélalo, y vuelve a intentar.',
        );
      }
      return tx.save(
        BrebPendingCharge,
        tx.create(BrebPendingCharge, {
          module,
          draft: cleanDraft,
          initiatedByUserId: actor.userId,
          initiatedByUsername: actor.username,
          amount: chosen,
          requestedAmount: requested,
          status: 'pending',
          expiresAt,
        }),
      );
    });
    const chargeAmount = Number(record.amount);

    this.logger.log(
      `Cobro Bre-B creado: id=${record.id} módulo=${module} monto=${chargeAmount}` +
        (chargeAmount !== requested ? ` (pedido ${requested})` : '') +
        ` por ${actor.username}`,
    );

    return {
      chargeId: record.id,
      amount: chargeAmount,
      requestedAmount: requested,
      llaves: llaves.map((l) => ({
        id: l.id,
        label: l.label,
        llave: l.llave,
        // El QR lleva el monto ÚNICO: el cliente lo escanea y paga exacto.
        qrPayload: l.qr_template ? this.safeBuildQr(l.qr_template, chargeAmount) : null,
      })),
      expiresAt,
    };
  }

  private async validateDraft(
    module: BrebChargeModule,
    draft: Record<string, any>,
    brebPaymentMethodId: string,
  ): Promise<Record<string, any>> {
    const body = { ...draft, paymentMethodId: brebPaymentMethodId };
    const cls = module === 'vegetables' ? CreateVegetableSaleDto : CreateInvoiceDto;
    const instance = plainToInstance(cls as any, body) as object;
    const errors = await validate(instance, { whitelist: true, forbidNonWhitelisted: false });
    if (errors.length > 0) {
      const msg = errors
        .map((e) => Object.values(e.constraints ?? {}).join(', ') || e.property)
        .join('; ');
      throw new BadRequestException(`Venta inválida: ${msg}`);
    }
    // Se guarda el cuerpo tal cual quedó tras el whitelist (sin campos extra).
    return JSON.parse(JSON.stringify(instance));
  }

  /** Nunca lanza: una llave con QR roto sale sin QR (queda el texto). */
  private safeBuildQr(template: string, amount: number): string | null {
    try {
      return buildDynamicQrPayload(template, amount);
    } catch (err) {
      if (err instanceof InvalidEmvQrTemplateError) {
        this.logger.warn(`Plantilla de QR Bre-B inválida: ${err.message}`);
        return null;
      }
      throw err;
    }
  }

  private async findChargeFor(chargeId: string, actor: BrebActor): Promise<BrebPendingCharge> {
    const record = await this.dataSource
      .getRepository(BrebPendingCharge)
      .findOne({ where: { id: chargeId } });
    if (!record) throw new NotFoundException('Cobro Bre-B no encontrado');
    this.assertModuleAllowed(record.module, actor);
    return record;
  }

  async getStatus(
    chargeId: string,
    actor: BrebActor,
  ): Promise<{
    status: 'pending' | 'matched' | 'expired' | 'cancelled';
    payerName: string | null;
    bankLabel: string | null;
    saleId: string | null;
    saleNumber: number | null;
    module: BrebChargeModule;
    expiresAt: Date;
  }> {
    const repo = this.dataSource.getRepository(BrebPendingCharge);
    const record = await this.findChargeFor(chargeId, actor);
    if (record.status === 'pending' && record.expiresAt < new Date()) {
      record.status = 'expired';
      await repo.save(record);
    }
    return {
      // `matching` es interno (registrando la venta): para la app sigue
      // "esperando" un instante más.
      status: record.status === 'matching' ? 'pending' : record.status,
      payerName: record.payerName,
      bankLabel: record.bankLabel,
      saleId: record.saleId,
      saleNumber: record.saleNumber,
      module: record.module,
      expiresAt: record.expiresAt,
    };
  }

  async cancel(chargeId: string, actor: BrebActor): Promise<{ success: boolean }> {
    const record = await this.findChargeFor(chargeId, actor);
    // Atómico: si justo llegó el correo y lo está registrando, no se cancela.
    await this.dataSource
      .createQueryBuilder()
      .update(BrebPendingCharge)
      .set({ status: 'cancelled' })
      .where("id = :id AND status IN ('pending', 'expired')", { id: record.id })
      .execute();
    return { success: true };
  }

  // ─────────────── Asignación manual (cajero, un toque) ───────────────

  /** Pagos que SÍ llegaron pero no se asignaron solos (últimas 24 h). */
  async listAssignable(): Promise<
    Array<{
      id: string;
      amount: number;
      payerName: string | null;
      bankLabel: string | null;
      reference: string | null;
      receivedAt: Date;
    }>
  > {
    const rows = await this.dataSource
      .getRepository(BrebUnmatchedEmail)
      .createQueryBuilder('e')
      .select(['e.id', 'e.rawAmount', 'e.rawPayerName', 'e.bankLabel', 'e.rawReference', 'e.createdAt'])
      .where('e.reason IN (:...reasons)', { reasons: BREB_ASSIGNABLE_REASONS })
      .andWhere('e.resolvedChargeId IS NULL')
      .andWhere('e.rawAmount IS NOT NULL')
      .andWhere("e.createdAt > now() - interval '24 hours'")
      .orderBy('e.createdAt', 'DESC')
      .take(30)
      .getMany();
    return rows.map((e) => ({
      id: e.id,
      amount: Number(e.rawAmount),
      payerName: e.rawPayerName ?? null,
      bankLabel: e.bankLabel ?? null,
      reference: e.rawReference ?? null,
      receivedAt: e.createdAt,
    }));
  }

  /**
   * Asigna un pago recibido a un cobro. Todo bajo bloqueo de fila: el mismo
   * pago NUNCA se asigna dos veces aunque dos cajeros toquen a la vez.
   *
   * A diferencia de Food App, La Bomba no maneja abonos parciales en una
   * venta: el pago debe cubrir el cobro (se tolera hasta $9 menos, igual
   * que el ajuste por monto único). Si llegó de más, se registra la venta
   * por su total.
   */
  async assignManually(
    chargeId: string,
    emailId: string,
    actor: BrebActor,
  ): Promise<{ success: boolean; saleId: string | null; saleNumber: number | null }> {
    await this.findChargeFor(chargeId, actor); // permisos + 404

    const charge = await this.dataSource.transaction(async (tx) => {
      const email = await tx
        .getRepository(BrebUnmatchedEmail)
        .createQueryBuilder('e')
        .setLock('pessimistic_write')
        .where('e.id = :id', { id: emailId })
        .getOne();
      if (!email) throw new NotFoundException('Pago recibido no encontrado');
      if (!BREB_ASSIGNABLE_REASONS.includes(email.reason) || email.rawAmount == null) {
        throw new BadRequestException('Ese correo no es un pago asignable');
      }
      if (email.resolvedChargeId) {
        throw new BadRequestException('Ese pago ya se asignó a otro cobro');
      }
      const c = await tx
        .getRepository(BrebPendingCharge)
        .createQueryBuilder('c')
        .setLock('pessimistic_write')
        .where('c.id = :id', { id: chargeId })
        .getOne();
      if (!c) throw new NotFoundException('Cobro Bre-B no encontrado');
      if (c.status !== 'pending' && c.status !== 'expired') {
        throw new BadRequestException(
          c.status === 'matched' ? 'Ese cobro ya está pagado' : 'Ese cobro ya no está activo',
        );
      }
      const received = Number(email.rawAmount);
      const requested = Number(c.requestedAmount);
      if (requested - received > MAX_BREB_ADJUSTMENT + 0.009) {
        throw new BadRequestException(
          `Ese pago ($${received}) es menor que el cobro ($${requested}). ` +
            'Cobra la diferencia aparte o asigna el pago correcto.',
        );
      }
      c.status = 'matching';
      c.payerName = email.rawPayerName?.slice(0, 255) ?? null;
      c.matchedReference = (email.rawReference ?? `manual:${email.id}`).slice(0, 255);
      c.bankLabel = email.bankLabel ?? null;
      c.matchedLlave = email.llave ?? null;
      c.receivedAmount = Math.min(received, requested);
      c.confirmedVia = 'manual';
      await tx.save(BrebPendingCharge, c);
      email.resolvedChargeId = c.id;
      email.resolvedAt = new Date();
      await tx.save(BrebUnmatchedEmail, email);
      return c;
    });

    try {
      await this.registerSale(charge);
    } catch (err) {
      // Se deshace la asignación: el correo vuelve a estar disponible.
      await this.dataSource.transaction(async (tx) => {
        await tx.update(BrebUnmatchedEmail, { id: emailId }, { resolvedChargeId: null, resolvedAt: null });
        await tx.update(
          BrebPendingCharge,
          { id: chargeId },
          {
            status: charge.expiresAt < new Date() ? 'expired' : 'pending',
            matchedReference: null,
            lastError: (err as Error).message.slice(0, 1000),
          },
        );
      });
      throw new BadRequestException(`No se pudo registrar la venta: ${(err as Error).message}`);
    }
    await this.markMatched(charge);
    this.notifyConfirmed(charge);
    this.logger.log(`Pago Bre-B asignado a mano: email=${emailId} → cobro=${chargeId}`);
    return { success: true, saleId: charge.saleId, saleNumber: charge.saleNumber };
  }

  // ─────────────────────── Historial (admin) ─────────────────────────

  async listCharges(filters: {
    from?: Date;
    to?: Date;
    module?: BrebChargeModule;
  }): Promise<BrebPendingCharge[]> {
    const qb = this.dataSource
      .getRepository(BrebPendingCharge)
      .createQueryBuilder('c')
      .select([
        'c.id', 'c.module', 'c.amount', 'c.requestedAmount', 'c.status', 'c.payerName',
        'c.bankLabel', 'c.matchedLlave', 'c.matchedReference', 'c.receivedAmount', 'c.saleId',
        'c.saleNumber', 'c.confirmedAt', 'c.confirmedVia', 'c.initiatedByUsername', 'c.lastError',
        'c.expiresAt', 'c.createdAt',
      ])
      .orderBy('c.createdAt', 'DESC')
      .take(500);
    if (filters.from) qb.andWhere('c.createdAt >= :from', { from: filters.from });
    if (filters.to) qb.andWhere('c.createdAt <= :to', { to: filters.to });
    if (filters.module) qb.andWhere('c.module = :module', { module: filters.module });
    return qb.getMany();
  }

  // ────────────────────────── Webhook de correo ─────────────────────────

  /**
   * Recibe el payload de Mailgun Inbound Routes. Nunca lanza (salvo firma
   * inválida → 401) para que Mailgun no reintente en bucle; todo lo que no
   * se pueda conciliar queda en `breb_unmatched_emails`.
   */
  async handleInboundEmail(fields: {
    timestamp?: string;
    token?: string;
    signature?: string;
    recipient?: string;
    from?: string;
    sender?: string;
    bodyPlain?: string;
    messageHeaders?: string;
  }): Promise<{ success: boolean; message: string }> {
    try {
      return await this.handleInboundEmailCore(fields);
    } catch (err) {
      if (err instanceof UnauthorizedException) throw err;
      this.logger.error(
        `Error inesperado procesando correo Bre-B: ${(err as Error).message}`,
        (err as Error).stack,
      );
      return { success: true, message: 'Error interno, correo descartado de forma segura' };
    }
  }

  private async handleInboundEmailCore(fields: {
    timestamp?: string;
    token?: string;
    signature?: string;
    recipient?: string;
    from?: string;
    sender?: string;
    bodyPlain?: string;
    messageHeaders?: string;
  }): Promise<{ success: boolean; message: string }> {
    this.validateMailgunSignature(fields.timestamp, fields.token, fields.signature);

    const cfg = await this.getOrCreateConfig();
    const slug = this.extractSlug(fields.recipient);
    if (!slug || slug !== cfg.inboundSlug.toLowerCase()) {
      await this.logUnmatched(undefined, 'unknown_slug', fields.bodyPlain);
      return { success: false, message: 'Dirección desconocida' };
    }

    // `from`/`sender` no siempre alcanzan (Bancolombia reenviado por Gmail
    // llega sin el dominio del banco): se completa con los dominios
    // verificados por DKIM/DMARC de los headers crudos.
    const fromHeader = [fields.from, fields.sender, this.extractVerifiedSenderDomains(fields.messageHeaders)]
      .filter(Boolean)
      .join(' ')
      .toLowerCase();
    const bank = findBankAdapter(fromHeader);
    if (!bank) {
      await this.logUnmatched(undefined, 'not_approved', fields.bodyPlain);
      return { success: false, message: 'Remitente no reconocido' };
    }

    const bodyText = fields.bodyPlain ?? '';
    if (!bank.matchesTemplate(bodyText)) {
      await this.logUnmatched(undefined, 'not_a_sale', bodyText);
      return { success: true, message: 'No es una notificación de venta' };
    }

    const parsed = bank.parse(bodyText);
    if (!parsed.amount) {
      await this.logUnmatched(parsed, 'parse_error', bodyText);
      return { success: false, message: 'No se pudo interpretar el correo' };
    }
    if (!parsed.approved) {
      await this.logUnmatched(parsed, 'status_rejected', bodyText);
      return { success: true, message: 'Estado no aprobado, ignorado' };
    }

    // Referencia sintética (Bancolombia no da comprobante): dos pagos REALES
    // iguales en el mismo minuto darían la misma — se le suma el Message-Id.
    if (parsed.reference && parsed.syntheticReference) {
      const messageId = this.extractMessageId(fields.messageHeaders);
      if (messageId) parsed.reference = `${parsed.reference}:${messageId}`;
    }
    const reference = parsed.reference?.slice(0, 255);

    const chargesRepo = this.dataSource.getRepository(BrebPendingCharge);
    if (reference) {
      // Idempotencia: Mailgun reintenta — nunca registrar dos veces.
      if (await chargesRepo.findOne({ where: { matchedReference: reference } })) {
        return { success: true, message: 'Ya procesado' };
      }
      const alreadyLogged = await this.dataSource
        .getRepository(BrebUnmatchedEmail)
        .findOne({ where: { rawReference: reference } });
      if (alreadyLogged) return { success: true, message: 'Ya procesado' };
    }

    const candidates = await chargesRepo.find({
      where: { status: 'pending', amount: parsed.amount, expiresAt: MoreThan(new Date()) },
      order: { createdAt: 'ASC' },
    });
    if (candidates.length === 0) {
      await this.logUnmatched(parsed, 'no_pending_match', bodyText, bank.bankLabel);
      return { success: true, message: 'Sin cobro pendiente para conciliar' };
    }
    if (candidates.length > 1) {
      await this.logUnmatched(parsed, 'multiple_matches', bodyText, bank.bankLabel);
      return { success: true, message: 'Match ambiguo, requiere revisión manual' };
    }

    // Reclamo ATÓMICO (`pending → matching`).
    const charge = candidates[0];
    if (!(await this.claim(charge.id))) {
      await this.logUnmatched(parsed, 'already_claimed', bodyText, bank.bankLabel);
      return { success: true, message: 'El cobro ya lo estaba confirmando otro correo' };
    }

    charge.status = 'matching';
    charge.payerName = parsed.payerName?.slice(0, 255) ?? null;
    charge.matchedReference = reference ?? null;
    charge.bankLabel = bank.bankLabel;
    charge.matchedLlave = parsed.llave?.slice(0, 255) ?? null;
    charge.receivedAmount = Number(parsed.amount);
    charge.confirmedVia = 'email';
    await chargesRepo.save(charge);

    try {
      await this.registerSale(charge);
    } catch (err) {
      // La plata SÍ llegó pero la venta no se pudo registrar (ej. se cerró
      // la caja): se libera el cobro y el correo queda para asignarlo a mano.
      await chargesRepo.update(
        { id: charge.id },
        {
          status: 'pending',
          matchedReference: null,
          lastError: (err as Error).message.slice(0, 1000),
        },
      );
      this.logger.error(`Error registrando venta Bre-B (cobro=${charge.id}): ${(err as Error).message}`);
      await this.logUnmatched(
        parsed,
        'registration_failed',
        `${bodyText}\n\n[ERROR AL REGISTRAR] cobro=${charge.id}: ${(err as Error).message}`,
        bank.bankLabel,
      );
      return { success: true, message: 'Pago recibido pero no se pudo registrar automáticamente' };
    }

    await this.markMatched(charge);
    this.notifyConfirmed(charge);
    this.logger.log(`Pago Bre-B conciliado: cobro=${charge.id} venta=${charge.saleNumber} (${charge.module})`);
    return { success: true, message: 'Pago conciliado' };
  }

  /** `pending → matching` atómico. `false` si otro ya lo reclamó. */
  private async claim(chargeId: string): Promise<boolean> {
    const result = await this.dataSource
      .createQueryBuilder()
      .update(BrebPendingCharge)
      .set({ status: 'matching' })
      .where('id = :id AND status = :status', { id: chargeId, status: 'pending' })
      .execute();
    return (result.affected ?? 0) === 1;
  }

  /**
   * Registra la venta/factura del cobro con los datos del pago. Idempotente:
   * si una venta con este cobro ya existe (el servidor se cayó a mitad de
   * camino la vez anterior), la reutiliza en vez de duplicarla.
   */
  private async registerSale(charge: BrebPendingCharge): Promise<void> {
    const existing = await this.findSaleForCharge(charge);
    if (existing) {
      charge.saleId = existing.id;
      charge.saleNumber = existing.number;
      return;
    }

    const info: BrebSaleInfo = {
      chargeId: charge.id,
      payerName: charge.payerName,
      bankLabel: charge.bankLabel,
      llave: charge.matchedLlave,
      reference: charge.matchedReference,
      amountReceived: Number(charge.receivedAmount ?? charge.amount),
      expectedTotal: Number(charge.requestedAmount),
    };
    const pm = await this.getBrebPaymentMethod();
    const draft = { ...charge.draft, paymentMethodId: pm.id };

    if (charge.module === 'vegetables') {
      const sale = await this.vegetablesService.createSale(
        draft as CreateVegetableSaleDto,
        charge.initiatedByUsername,
        info,
      );
      charge.saleId = sale.id;
      charge.saleNumber = sale.number;
    } else {
      const invoice = await this.invoicesService.create(
        draft as CreateInvoiceDto,
        charge.initiatedByUsername,
        info,
      );
      charge.saleId = invoice.id;
      charge.saleNumber = invoice.number;
    }
  }

  private async findSaleForCharge(
    charge: Pick<BrebPendingCharge, 'id' | 'module'>,
  ): Promise<{ id: string; number: number } | null> {
    const entity = charge.module === 'vegetables' ? VegetableSale : Invoice;
    const found = await this.dataSource
      .getRepository(entity as any)
      .findOne({ where: { brebChargeId: charge.id } as any, select: ['id', 'number'] as any });
    return (found as { id: string; number: number } | null) ?? null;
  }

  private async markMatched(charge: BrebPendingCharge): Promise<void> {
    charge.status = 'matched';
    charge.confirmedAt = new Date();
    charge.lastError = null;
    await this.dataSource.getRepository(BrebPendingCharge).save(charge);
  }

  private notifyConfirmed(charge: BrebPendingCharge): void {
    this.notifications
      .sendBrebPaymentConfirmed(
        charge.initiatedByUserId,
        charge.id,
        Number(charge.receivedAmount ?? charge.amount),
        charge.payerName ?? '',
        charge.bankLabel ?? '',
      )
      .catch((err) => this.logger.error(`Error enviando push Bre-B: ${(err as Error).message}`));
  }

  /**
   * Cobros que quedaron en `matching` (el servidor se reinició entre crear
   * la venta y marcar el cobro): si la venta existe → `matched`; si no →
   * vuelve a `pending` (o `expired`) para que el correo o la asignación
   * manual lo puedan tomar. Corre cada minuto.
   */
  @Cron(CronExpression.EVERY_MINUTE)
  async recoverStuckCharges(): Promise<number> {
    let fixed = 0;
    try {
      const repo = this.dataSource.getRepository(BrebPendingCharge);
      const stuck = await repo
        .createQueryBuilder('c')
        .where("c.status = 'matching'")
        .andWhere("c.updatedAt < now() - interval '5 minutes'")
        .take(100)
        .getMany();
      for (const c of stuck) {
        const sale = await this.findSaleForCharge(c);
        const next = sale ? 'matched' : c.expiresAt < new Date() ? 'expired' : 'pending';
        const res = await this.dataSource
          .createQueryBuilder()
          .update(BrebPendingCharge)
          .set({
            status: next,
            ...(sale
              ? { saleId: sale.id, saleNumber: sale.number, confirmedAt: new Date() }
              : { matchedReference: null }),
          })
          .where("id = :id AND status = 'matching'", { id: c.id })
          .execute();
        if (res.affected) {
          fixed++;
          this.logger.warn(`Cobro Bre-B ${c.id} estaba trabado en "matching" → ${next}`);
        }
      }
    } catch (err) {
      this.logger.error(`recoverStuckCharges falló: ${(err as Error).message}`);
    }
    return fixed;
  }

  // ────────────────────────── Helpers privados ──────────────────────────

  private extractSlug(recipient?: string): string | null {
    if (!recipient) return null;
    const match = recipient.match(/pagos-([a-f0-9]+)@/i);
    return match ? match[1].toLowerCase() : null;
  }

  private extractMessageId(messageHeaders?: string): string | null {
    if (!messageHeaders) return null;
    try {
      const pairs = JSON.parse(messageHeaders) as Array<[string, string]>;
      const found = pairs.find(
        (p) => Array.isArray(p) && typeof p[0] === 'string' && p[0].toLowerCase() === 'message-id',
      );
      return found ? String(found[1]).trim().slice(0, 150) : null;
    } catch {
      return null;
    }
  }

  /** Dominios verificados (DKIM `d=` y `header.from=` de DMARC). Nunca lanza. */
  private extractVerifiedSenderDomains(messageHeaders?: string): string {
    if (!messageHeaders) return '';
    let headers: unknown;
    try {
      headers = JSON.parse(messageHeaders);
    } catch {
      return '';
    }
    if (!Array.isArray(headers)) return '';
    const domains = new Set<string>();
    for (const entry of headers) {
      if (!Array.isArray(entry) || entry.length < 2) continue;
      const [name, value] = entry as [unknown, unknown];
      if (typeof name !== 'string' || typeof value !== 'string') continue;
      const lower = name.toLowerCase();
      if (lower === 'dkim-signature') {
        const m = value.match(/[; ]d=([a-z0-9.-]+)/i);
        if (m) domains.add(m[1].toLowerCase());
      }
      if (lower === 'authentication-results') {
        for (const m of value.matchAll(/header\.from=([a-z0-9.-]+)/gi)) domains.add(m[1].toLowerCase());
      }
    }
    return [...domains].join(' ');
  }

  private async logUnmatched(
    parsed: BankParseResult | undefined,
    reason: BrebUnmatchedEmail['reason'],
    rawBody?: string,
    bankLabel?: string,
  ): Promise<void> {
    const repo = this.dataSource.getRepository(BrebUnmatchedEmail);
    // Truncado defensivo: un regex que "se coma" de más nunca debe tumbar
    // el guardado (bug real de producción en Food App).
    await repo.save(
      repo.create({
        bankLabel: bankLabel?.slice(0, 50) ?? null,
        llave: parsed?.llave?.slice(0, 255) ?? null,
        rawAmount: parsed?.amount ?? null,
        rawReference: parsed?.reference?.slice(0, 255) ?? null,
        rawPayerName: parsed?.payerName?.slice(0, 255) ?? null,
        rawBody: rawBody?.slice(0, 5000) ?? null,
        reason,
      }),
    );
    this.logger.warn(`Correo Bre-B sin conciliar (${reason})`);
  }

  /** Firma de Mailgun: HMAC-SHA256(signing_key, timestamp + token). */
  private validateMailgunSignature(timestamp?: string, token?: string, signature?: string): void {
    const signingKey = this.config.get<string>('MAILGUN_SIGNING_KEY', '');
    if (!signingKey) {
      if (this.config.get<string>('NODE_ENV') === 'production') {
        // En producción NUNCA se acepta un correo sin firma: cualquiera
        // podría "confirmar" un pago que no llegó.
        throw new UnauthorizedException('Webhook Bre-B sin MAILGUN_SIGNING_KEY configurado');
      }
      this.logger.warn('MAILGUN_SIGNING_KEY no configurado — omitiendo validación de firma (solo desarrollo).');
      return;
    }
    if (!timestamp || !token || !signature) {
      throw new UnauthorizedException('Firma de webhook Bre-B ausente');
    }
    const expected = crypto.createHmac('sha256', signingKey).update(timestamp + token).digest('hex');
    const sigBuf = Buffer.from(signature);
    const expBuf = Buffer.from(expected);
    if (sigBuf.length !== expBuf.length || !crypto.timingSafeEqual(sigBuf, expBuf)) {
      throw new UnauthorizedException('Firma de webhook Bre-B inválida');
    }
  }
}
