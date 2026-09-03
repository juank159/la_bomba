import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { VegetableExpense } from './entities/vegetable-expense.entity';
import { CreateVegetableExpenseDto } from './dto/create-vegetable-expense.dto';
import { UpdateVegetableExpenseDto } from './dto/update-vegetable-expense.dto';

@Injectable()
export class VegetableExpensesService {
  constructor(
    @InjectRepository(VegetableExpense)
    private expensesRepository: Repository<VegetableExpense>,
  ) {}

  async create(dto: CreateVegetableExpenseDto, userId: string): Promise<VegetableExpense> {
    const expense = this.expensesRepository.create({
      ...dto,
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
