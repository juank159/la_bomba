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
  /// totales en vivo para mostrar antes de cerrar.
  async getCurrent(): Promise<{
    session: VegetableCashSession | null;
    cashSales: number;
    cashExpenses: number;
    expectedAmount: number;
  }> {
    const session = await this.getCurrentOpenSession();
    if (!session) {
      return { session: null, cashSales: 0, cashExpenses: 0, expectedAmount: 0 };
    }

    const { cashSales, cashExpenses } = await this.computeSessionTotals(session.id);
    const expectedAmount = Number(session.openingAmount) + cashSales - cashExpenses;
    return { session, cashSales, cashExpenses, expectedAmount };
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

  private async computeSessionTotals(sessionId: string): Promise<SessionTotals> {
    const salesResult = await this.salesRepository
      .createQueryBuilder('sale')
      .select('COALESCE(SUM(sale.total), 0)', 'sum')
      .where('sale.cashSessionId = :sessionId', { sessionId })
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
}
