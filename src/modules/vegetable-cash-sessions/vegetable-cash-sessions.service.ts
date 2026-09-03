import { Injectable, NotFoundException, BadRequestException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VegetableCashSession, CashSessionStatus } from './entities/vegetable-cash-session.entity';
import { VegetableSale } from '../vegetables/entities/vegetable-sale.entity';
import { VegetableExpense, ExpenseFundingSource } from '../vegetable-expenses/entities/vegetable-expense.entity';
import { OpenCashSessionDto } from './dto/open-cash-session.dto';
import { CloseCashSessionDto } from './dto/close-cash-session.dto';

interface SessionTotals {
  cashSales: number;
  cashExpenses: number;
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
    // desglose por método de pago (ver getBreakdown).
    const { cashSales, cashExpenses } = await this.computeSessionTotals(session.id);
    const expectedAmount = Number(session.openingAmount) + cashSales - cashExpenses;
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

  /// Sesión abierta ahora mismo (o null si la caja está cerrada), con los
  /// totales en vivo (solo efectivo) y el desglose por método de pago
  /// para mostrar antes de cerrar.
  async getCurrent(): Promise<{
    session: VegetableCashSession | null;
    cashSales: number;
    cashExpenses: number;
    expectedAmount: number;
    paymentBreakdown: PaymentBreakdownRow[];
  }> {
    const session = await this.getCurrentOpenSession();
    if (!session) {
      return { session: null, cashSales: 0, cashExpenses: 0, expectedAmount: 0, paymentBreakdown: [] };
    }

    const { cashSales, cashExpenses } = await this.computeSessionTotals(session.id);
    const expectedAmount = Number(session.openingAmount) + cashSales - cashExpenses;
    const paymentBreakdown = await this.computePaymentBreakdown(session.id);
    return { session, cashSales, cashExpenses, expectedAmount, paymentBreakdown };
  }

  async getCurrentOpenSession(): Promise<VegetableCashSession | null> {
    return this.sessionsRepository.findOne({ where: { status: CashSessionStatus.OPEN } });
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

  private async computeSessionTotals(sessionId: string): Promise<SessionTotals> {
    const salesResult = await this.salesRepository
      .createQueryBuilder('sale')
      .innerJoin('sale.paymentMethod', 'pm')
      .select('COALESCE(SUM(sale.total), 0)', 'sum')
      .where('sale.cashSessionId = :sessionId', { sessionId })
      .andWhere('pm.isCash = true')
      .getRawOne<{ sum: string }>();

    const expensesResult = await this.expensesRepository
      .createQueryBuilder('expense')
      .select('COALESCE(SUM(expense.amount), 0)', 'sum')
      .where('expense.cashSessionId = :sessionId', { sessionId })
      .andWhere('expense.fundingSource = :source', { source: ExpenseFundingSource.CAJA })
      .getRawOne<{ sum: string }>();

    return {
      cashSales: Number(salesResult?.sum ?? 0),
      cashExpenses: Number(expensesResult?.sum ?? 0),
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
