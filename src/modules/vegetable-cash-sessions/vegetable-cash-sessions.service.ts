import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, Repository } from 'typeorm';
import { InjectDataSource } from '@nestjs/typeorm';
import { BrebConfig } from '../breb/entities/breb-config.entity';
import { VegetableCashSession, CashSessionStatus } from './entities/vegetable-cash-session.entity';
import { VegetableSale } from '../vegetables/entities/vegetable-sale.entity';
import { VegetableSalePayment } from '../vegetables/entities/vegetable-sale-payment.entity';
import { VegetablePurchase, PurchaseFundingSource } from '../vegetables/entities/vegetable-purchase.entity';
import { VegetableExpense, ExpenseFundingSource } from '../vegetable-expenses/entities/vegetable-expense.entity';
import { OpenCashSessionDto } from './dto/open-cash-session.dto';
import { CloseCashSessionDto } from './dto/close-cash-session.dto';

interface SessionTotals {
  cashSales: number;
  cashExpenses: number;
  cashPurchases: number;
}

export interface PaymentBreakdownRow {
  paymentMethodId: string;
  paymentMethodName: string;
  isCash: boolean;
  total: number;
  count: number;
}

@Injectable()
export class VegetableCashSessionsService {
  constructor(
    @InjectRepository(VegetableCashSession)
    private sessionsRepository: Repository<VegetableCashSession>,
    @InjectRepository(VegetableSale)
    private salesRepository: Repository<VegetableSale>,
    @InjectRepository(VegetableSalePayment)
    private salePaymentsRepository: Repository<VegetableSalePayment>,
    @InjectRepository(VegetablePurchase)
    private purchasesRepository: Repository<VegetablePurchase>,
    @InjectRepository(VegetableExpense)
    private expensesRepository: Repository<VegetableExpense>,
    @InjectDataSource()
    private dataSource: DataSource,
  ) {}

  async open(dto: OpenCashSessionDto, username: string): Promise<VegetableCashSession> {
    const existing = await this.getCurrentOpenSession();
    if (existing) {
      throw new ConflictException(
        `Ya hay una caja abierta desde ${existing.openedAt.toISOString()} (por ${existing.openedBy})`,
      );
    }

    const session = this.sessionsRepository.create({
      status: CashSessionStatus.OPEN,
      openedBy: username,
      openingAmount: dto.openingAmount,
      notes: dto.notes,
    });
    return this.sessionsRepository.save(session);
  }

  async close(dto: CloseCashSessionDto, username: string): Promise<VegetableCashSession> {
    const session = await this.getCurrentOpenSession();
    if (!session) {
      throw new BadRequestException('No hay una caja abierta para cerrar');
    }

    // El "esperado" en caja SOLO cuenta efectivo real - las ventas por
    // transferencia (Nequi, Bancolombia, etc.) nunca estuvieron en la
    // caja física, así que no deben sumar acá aunque sí formen parte del
    // desglose por método de pago (ver getBreakdown). Los gastos Y las
    // compras pagados de esta caja se restan por igual - ambos sacan
    // plata física de la caja.
    const { cashSales, cashExpenses, cashPurchases } = await this.computeSessionTotals(session.id);
    const expectedAmount = Number(session.openingAmount) + cashSales - cashExpenses - cashPurchases;
    const difference = dto.closingAmount - expectedAmount;

    session.status = CashSessionStatus.CLOSED;
    session.closedBy = username;
    session.closedAt = new Date();
    session.closingAmount = dto.closingAmount;
    session.expectedAmount = expectedAmount;
    session.difference = difference;
    if (dto.notes) {
      session.notes = session.notes ? `${session.notes}\n${dto.notes}` : dto.notes;
    }

    return this.sessionsRepository.save(session);
  }

  /// Recalcula expectedAmount/difference de un turno YA CERRADO - se usa
  /// cuando se edita o elimina una compra/gasto que pertenecía a ese turno
  /// (ver VegetablesService.updatePurchase/deletePurchase), para que el
  /// cuadre guardado no quede desactualizado respecto al valor corregido.
  /// No hace nada si el turno sigue abierto (ahí expectedAmount se calcula
  /// al vuelo cada vez, nunca queda "guardado" hasta que se cierra).
  async recomputeClosedSessionTotals(sessionId: string): Promise<void> {
    const session = await this.sessionsRepository.findOne({ where: { id: sessionId } });
    if (!session || session.status !== CashSessionStatus.CLOSED) return;

    const { cashSales, cashExpenses, cashPurchases } = await this.computeSessionTotals(sessionId);
    const expectedAmount = Number(session.openingAmount) + cashSales - cashExpenses - cashPurchases;

    session.expectedAmount = expectedAmount;
    session.difference = Number(session.closingAmount) - expectedAmount;
    await this.sessionsRepository.save(session);
  }

  /// Sesión abierta ahora mismo (o null si la caja está cerrada), con los
  /// totales en vivo (solo efectivo) y el desglose por método de pago
  /// para mostrar antes de cerrar. `isStale` indica que la caja quedó
  /// abierta desde un día anterior sin cerrar - no habilita vender.
  async getCurrent(): Promise<{
    session: VegetableCashSession | null;
    isStale: boolean;
    cashSales: number;
    cashExpenses: number;
    cashPurchases: number;
    expectedAmount: number;
    paymentBreakdown: PaymentBreakdownRow[];
  }> {
    const session = await this.getCurrentOpenSession();
    if (!session) {
      return {
        session: null,
        isStale: false,
        cashSales: 0,
        cashExpenses: 0,
        cashPurchases: 0,
        expectedAmount: 0,
        paymentBreakdown: [],
      };
    }

    const isStale = !this.isSameCalendarDay(session.openedAt, new Date());
    const { cashSales, cashExpenses, cashPurchases } = await this.computeSessionTotals(session.id);
    const expectedAmount = Number(session.openingAmount) + cashSales - cashExpenses - cashPurchases;
    const paymentBreakdown = await this.computePaymentBreakdown(session.id);
    return { session, isStale, cashSales, cashExpenses, cashPurchases, expectedAmount, paymentBreakdown };
  }

  async getCurrentOpenSession(): Promise<VegetableCashSession | null> {
    return this.sessionsRepository.findOne({ where: { status: CashSessionStatus.OPEN } });
  }

  /// La caja que realmente habilita vender: tiene que estar abierta Y
  /// haber sido abierta hoy. Si quedó una caja abierta de un día anterior
  /// sin cerrar, esto devuelve null (hay que cerrarla y abrir una nueva).
  async getCurrentOpenSessionForToday(): Promise<VegetableCashSession | null> {
    const session = await this.getCurrentOpenSession();
    if (!session || !this.isSameCalendarDay(session.openedAt, new Date())) {
      return null;
    }
    return session;
  }

  // El negocio opera en Colombia (America/Bogota, UTC-5), pero el servidor
  // puede estar corriendo en cualquier zona horaria (típicamente UTC en el
  // hosting). Comparar "getFullYear/getMonth/getDate" directamente usaba
  // la hora LOCAL DEL SERVIDOR, no la de Colombia: cualquier caja abierta
  // después de las 7pm hora Colombia ya caía en el día siguiente en UTC,
  // así que el sistema la marcaba como "de un día anterior" sin serlo
  // todavía en Colombia. Por eso acá se convierte cada fecha al día
  // calendario de Bogotá (vía Intl, sin depender de la zona del proceso)
  // antes de comparar.
  private toBogotaDateKey(date: Date): string {
    return new Intl.DateTimeFormat('en-CA', {
      timeZone: 'America/Bogota',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(date);
  }

  private isSameCalendarDay(a: Date, b: Date): boolean {
    return this.toBogotaDateKey(a) === this.toBogotaDateKey(b);
  }

  async findAll(): Promise<VegetableCashSession[]> {
    return this.sessionsRepository.find({ order: { openedAt: 'DESC' } });
  }

  async findOne(id: string): Promise<VegetableCashSession> {
    const session = await this.sessionsRepository.findOne({ where: { id } });
    if (!session) {
      throw new NotFoundException(`Turno de caja con ID ${id} no encontrado`);
    }
    return session;
  }

  /// Trazabilidad: cuánto entró por cada método de pago (efectivo, Nequi,
  /// Bancolombia, etc.) en un turno de caja específico, abierto o
  /// cerrado. Es lo que muestra "cuánta plata está en efectivo y cuánta
  /// está en cuentas bancarias" para ese turno.
  async getBreakdown(sessionId: string): Promise<PaymentBreakdownRow[]> {
    await this.findOne(sessionId); // 404 si no existe
    return this.computePaymentBreakdown(sessionId);
  }

  /// Igual que findOne, pero con los mismos totales (ventas en efectivo,
  /// gastos y compras de caja) que ya se muestran para el turno abierto -
  /// computeSessionTotals no depende de que la caja esté abierta, así que
  /// sirve igual para el historial de turnos ya cerrados.
  async findOneWithTotals(
    id: string,
  ): Promise<VegetableCashSession & { cashSales: number; cashExpenses: number; cashPurchases: number }> {
    const session = await this.findOne(id);
    const totals = await this.computeSessionTotals(id);
    return { ...session, ...totals };
  }

  /// Ventas del turno, una por una, para poder mostrar "1 de $X, 1 de $Y..."
  /// en vez de solo el total agrupado por método de pago (ver
  /// computePaymentBreakdown) - el frontend filtra por paymentMethodId al
  /// tocar una fila del desglose.
  async getSales(sessionId: string): Promise<VegetableSale[]> {
    await this.findOne(sessionId); // 404 si no existe
    return this.salesRepository.find({
      where: { cashSessionId: sessionId, isActive: true },
      relations: ['paymentMethod', 'payments', 'payments.paymentMethod'],
      order: { createdAt: 'ASC' },
    });
  }

  private async computeSessionTotals(sessionId: string): Promise<SessionTotals> {
    // Se suman las PARTES en efectivo de cada venta: una venta de $50.000
    // pagada Bre-B $20.000 + Efectivo $30.000 aporta $30.000 a la caja.
    const salesResult = await this.salePaymentsRepository
      .createQueryBuilder('payment')
      .innerJoin('payment.sale', 'sale')
      .innerJoin('payment.paymentMethod', 'pm')
      .select('COALESCE(SUM(payment.amount), 0)', 'sum')
      .where('sale.cashSessionId = :sessionId', { sessionId })
      .andWhere('pm.isCash = true')
      .andWhere('sale.isActive = true')
      .getRawOne<{ sum: string }>();

    const expensesResult = await this.expensesRepository
      .createQueryBuilder('expense')
      .select('COALESCE(SUM(expense.amount), 0)', 'sum')
      .where('expense.cashSessionId = :sessionId', { sessionId })
      .andWhere('expense.fundingSource = :source', { source: ExpenseFundingSource.CAJA })
      .getRawOne<{ sum: string }>();

    const purchasesResult = await this.purchasesRepository
      .createQueryBuilder('purchase')
      .select('COALESCE(SUM(purchase.total), 0)', 'sum')
      .where('purchase.cashSessionId = :sessionId', { sessionId })
      .andWhere('purchase.fundingSource = :source', { source: PurchaseFundingSource.CAJA })
      .andWhere('purchase.isActive = true')
      .getRawOne<{ sum: string }>();

    return {
      cashSales: Number(salesResult?.sum ?? 0),
      cashExpenses: Number(expensesResult?.sum ?? 0),
      cashPurchases: Number(purchasesResult?.sum ?? 0),
    };
  }

  private async computePaymentBreakdown(sessionId: string): Promise<PaymentBreakdownRow[]> {
    // Por partes de pago: una venta mixta suma a cada método lo suyo.
    const rows = await this.salePaymentsRepository
      .createQueryBuilder('payment')
      .innerJoin('payment.sale', 'sale')
      .innerJoin('payment.paymentMethod', 'pm')
      .select('pm.id', 'paymentMethodId')
      .addSelect('pm.name', 'paymentMethodName')
      .addSelect('pm.isCash', 'isCash')
      .addSelect('COALESCE(SUM(payment.amount), 0)', 'total')
      .addSelect('COUNT(DISTINCT sale.id)', 'count')
      .where('sale.cashSessionId = :sessionId', { sessionId })
      .andWhere('sale.isActive = true')
      .groupBy('pm.id')
      .addGroupBy('pm.name')
      .addGroupBy('pm.isCash')
      .orderBy('pm.name', 'ASC')
      .getRawMany<{ paymentMethodId: string; paymentMethodName: string; isCash: boolean; total: string; count: string }>();

    return rows.map((row) => ({
      paymentMethodId: row.paymentMethodId,
      paymentMethodName: row.paymentMethodName,
      isCash: row.isCash,
      total: Number(row.total),
      count: Number(row.count),
    }));
  }

  // ==========================================================================
  // Cierre a ciegas + reporte completo (estilo Food App)
  // ==========================================================================

  /**
   * Versión "a ciegas" de un turno para el verdulero: sin lo esperado ni la
   * diferencia. El cajero solo cuenta y escribe lo que hay; el cuadre lo ve
   * quien tenga la contraseña de Adalberto (ver getReport). Así no pierde
   * tiempo contando la plata a cada rato, y el cuadre no se "acomoda".
   */
  static redact<T extends Partial<VegetableCashSession>>(session: T): T {
    if (!session) return session;
    return { ...session, expectedAmount: null, difference: null, blind: true } as T;
  }

  /**
   * Reporte completo de un turno (X de caja si sigue abierto, Z si cerró):
   * efectivo esperado, cierre, desglose por método, Bre-B por llave con cada
   * transacción (hora, cliente que pagó, banco, referencia) y el detalle de
   * gastos y compras pagados desde la caja.
   */
  async getReport(sessionId: string) {
    const session = await this.findOne(sessionId);
    const totals = await this.computeSessionTotals(sessionId);
    const expectedLive = Number(session.openingAmount) + totals.cashSales - totals.cashExpenses - totals.cashPurchases;
    const isClosed = session.status === CashSessionStatus.CLOSED;

    const sales = await this.salesRepository.find({
      where: { cashSessionId: sessionId, isActive: true },
      relations: ['paymentMethod', 'payments', 'payments.paymentMethod'],
      order: { createdAt: 'ASC' },
    });

    // Nombres amigables de las llaves ("Nequi negocio") configuradas por el
    // admin, para no mostrar el handle crudo cuando se puede.
    let llaveLabels: Array<{ llave: string; label: string }> = [];
    try {
      const cfg = await this.dataSource.getRepository(BrebConfig).findOne({ where: { id: 1 } });
      llaveLabels = (cfg?.llaves ?? []).map((l) => ({ llave: l.llave, label: l.label }));
    } catch {
      llaveLabels = [];
    }
    const normalize = (v: string) => v.trim().toLowerCase().replace(/^@/, '');
    const labelForLlave = (llave: string) =>
      llaveLabels.find((l) => normalize(l.llave) === normalize(llave))?.label;

    const byMethod = new Map<string, { paymentMethodId: string; name: string; isCash: boolean; code: string | null; count: number; total: number }>();
    const brebByLlave = new Map<string, { key: string; label: string; count: number; total: number; received: number }>();

    const round2 = (v: number) => Math.round(v * 100) / 100;

    const salesList = sales.map((sale) => {
      const pm = sale.paymentMethod;
      const total = Number(sale.total);

      // Partes del pago (una venta mixta tiene varias). Ventas viejas sin
      // partes registradas cuentan como una sola parte por el total.
      const parts = (sale.payments?.length ? sale.payments : [{ paymentMethod: pm, amount: total } as VegetableSalePayment])
        .filter((p) => p.paymentMethod)
        .map((p) => ({
          paymentMethodId: p.paymentMethod.id,
          paymentMethodName: p.paymentMethod.name,
          isCash: p.paymentMethod.isCash,
          isBreb: p.paymentMethod.code === 'breb',
          amount: Number(p.amount),
        }));
      for (const part of parts) {
        const m = byMethod.get(part.paymentMethodId) ?? {
          paymentMethodId: part.paymentMethodId,
          name: part.paymentMethodName,
          isCash: part.isCash,
          code: part.isBreb ? 'breb' : null,
          count: 0,
          total: 0,
        };
        m.count += 1;
        m.total = round2(m.total + part.amount);
        byMethod.set(part.paymentMethodId, m);
      }
      const brebPart = parts.filter((p) => p.isBreb).reduce((acc, p) => acc + p.amount, 0);

      let brebGroupKey: string | null = null;
      if (pm.code === 'breb' && brebPart > 0) {
        // Por llave si el banco la reportó (Bancolombia), si no por banco
        // (Nequi nunca la manda) — nunca mezclar bancos distintos.
        const llave = sale.brebLlave?.trim() || null;
        const bank = sale.brebBankLabel?.trim() || null;
        brebGroupKey = llave ? `llave:${normalize(llave)}` : bank ? `banco:${bank}` : 'sin_identificar';
        const label = llave
          ? labelForLlave(llave)
            ? `${labelForLlave(llave)} (${llave})`
            : llave
          : bank ?? 'Sin identificar';
        const g = brebByLlave.get(brebGroupKey) ?? { key: brebGroupKey, label, count: 0, total: 0, received: 0 };
        g.count += 1;
        g.total = round2(g.total + brebPart);
        g.received = round2(g.received + Number(sale.brebAmountReceived ?? brebPart));
        brebByLlave.set(brebGroupKey, g);
      }

      return {
        id: sale.id,
        number: sale.number,
        total,
        createdAt: sale.createdAt,
        soldBy: sale.soldBy,
        paymentMethodId: pm.id,
        paymentMethodName: pm.name,
        isCash: pm.isCash,
        isBreb: pm.code === 'breb',
        // Pago mixto: cada parte con su método (ej. Bre-B + Efectivo).
        payments: parts,
        isSplit: parts.length > 1,
        brebAmount: brebPart > 0 ? round2(brebPart) : null,
        brebPayerName: sale.brebPayerName ?? null,
        brebBankLabel: sale.brebBankLabel ?? null,
        brebLlave: sale.brebLlave ?? null,
        brebLlaveLabel: sale.brebLlave ? labelForLlave(sale.brebLlave) ?? null : null,
        brebReference: sale.brebReference ?? null,
        brebAmountReceived: sale.brebAmountReceived != null ? Number(sale.brebAmountReceived) : null,
        brebGroupKey,
      };
    });

    const expenses = await this.expensesRepository.find({
      where: { cashSessionId: sessionId, fundingSource: ExpenseFundingSource.CAJA },
      order: { createdAt: 'ASC' },
    });
    const purchases = await this.purchasesRepository.find({
      where: { cashSessionId: sessionId, fundingSource: PurchaseFundingSource.CAJA, isActive: true },
      order: { createdAt: 'ASC' },
    });

    const sortDesc = <T extends { total: number }>(arr: T[]) => arr.sort((a, b) => b.total - a.total);
    const totalSales = salesList.reduce((acc, s) => acc + s.total, 0);

    return {
      session,
      isClosed,
      openingAmount: Number(session.openingAmount),
      cashSales: totals.cashSales,
      cashExpenses: totals.cashExpenses,
      cashPurchases: totals.cashPurchases,
      expectedAmount: isClosed ? Number(session.expectedAmount) : expectedLive,
      closingAmount: isClosed ? Number(session.closingAmount) : null,
      difference: isClosed ? Number(session.difference) : null,
      totalSales: Math.round(totalSales * 100) / 100,
      salesCount: salesList.length,
      byMethod: sortDesc([...byMethod.values()]),
      brebByLlave: sortDesc([...brebByLlave.values()]),
      sales: salesList,
      expenses: expenses.map((e) => ({ id: e.id, description: e.description, amount: Number(e.amount), createdAt: e.createdAt, createdBy: e.createdBy })),
      purchases: purchases.map((p) => ({ id: p.id, number: p.number, total: Number(p.total), createdAt: p.createdAt, createdBy: p.createdBy })),
    };
  }
}
