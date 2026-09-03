import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VegetableExpense, ExpenseFundingSource } from './entities/vegetable-expense.entity';
import { CreateVegetableExpenseDto } from './dto/create-vegetable-expense.dto';
import { UpdateVegetableExpenseDto } from './dto/update-vegetable-expense.dto';
import { VegetableCashSessionsService } from '../vegetable-cash-sessions/vegetable-cash-sessions.service';

@Injectable()
export class VegetableExpensesService {
  constructor(
    @InjectRepository(VegetableExpense)
    private expensesRepository: Repository<VegetableExpense>,
    private cashSessionsService: VegetableCashSessionsService,
  ) {}

  async create(dto: CreateVegetableExpenseDto, userId: string): Promise<VegetableExpense> {
    let cashSessionId: string | undefined;

    if (dto.fundingSource === ExpenseFundingSource.CAJA) {
      const openSession = await this.cashSessionsService.getCurrentOpenSessionForToday();
      if (!openSession) {
        const staleSession = await this.cashSessionsService.getCurrentOpenSession();
        if (staleSession) {
          throw new BadRequestException(
            'Hay una caja abierta desde un día anterior sin cerrar. Ciérrala y abre una nueva caja de hoy, o registra este gasto como dinero externo.',
          );
        }
        throw new BadRequestException(
          'No hay una caja abierta - abre caja primero o registra este gasto como dinero externo',
        );
      }
      cashSessionId = openSession.id;
    }

    const expense = this.expensesRepository.create({
      ...dto,
      cashSessionId,
      createdById: userId,
    });
    return this.expensesRepository.save(expense);
  }

  async findAll(): Promise<VegetableExpense[]> {
    return this.expensesRepository.find({
      relations: ['createdBy'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<VegetableExpense> {
    const expense = await this.expensesRepository.findOne({
      where: { id },
      relations: ['createdBy'],
    });

    if (!expense) {
      throw new NotFoundException(`Gasto con ID ${id} no encontrado`);
    }

    return expense;
  }

  async update(id: string, dto: UpdateVegetableExpenseDto): Promise<VegetableExpense> {
    const expense = await this.findOne(id);
    Object.assign(expense, dto);
    return this.expensesRepository.save(expense);
  }

  async remove(id: string): Promise<void> {
    const expense = await this.findOne(id);
    await this.expensesRepository.remove(expense);
  }
}
