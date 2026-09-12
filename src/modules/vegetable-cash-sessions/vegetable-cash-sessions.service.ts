import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VegetableCashSession, CashSessionStatus } from './entities/vegetable-cash-session.entity';
import { VegetableSale } from '../vegetables/entities/vegetable-sale.entity';
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
    @InjectRepository(VegetablePurchase)
    private purchasesRepository: Repository<VegetablePurchase>,
    @InjectRepository(VegetableExpense)
    private expensesRepository: Repository<VegetableExpense>,
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
      relations: ['paymentMethod'],
      order: { createdAt: 'ASC' },
    });
  }

  private async computeSessionTotals(sessionId: string): Promise<SessionTotals> {
    const salesResult = await this.salesRepository
      .createQueryBuilder('sale')
      .innerJoin('sale.paymentMethod', 'pm')
      .select('COALESCE(SUM(sale.total), 0)', 'sum')
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
    const rows = await this.salesRepository
      .createQueryBuilder('sale')
      .innerJoin('sale.paymentMethod', 'pm')
      .select('pm.id', 'paymentMethodId')
      .addSelect('pm.name', 'paymentMethodName')
      .addSelect('pm.isCash', 'isCash')
      .addSelect('COALESCE(SUM(sale.total), 0)', 'total')
      .addSelect('COUNT(sale.id)', 'count')
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
}
