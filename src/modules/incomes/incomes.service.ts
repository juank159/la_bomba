import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Income } from './entities/income.entity';
import { CreateIncomeDto } from './dto/create-income.dto';
import { UpdateIncomeDto } from './dto/update-income.dto';

@Injectable()
export class IncomesService {
  constructor(
    @InjectRepository(Income)
    private incomesRepository: Repository<Income>,
  ) {}

  async create(createIncomeDto: CreateIncomeDto, userId: string): Promise<Income> {
    const income = this.incomesRepository.create({
      ...createIncomeDto,
      createdById: userId,
    });
    return this.incomesRepository.save(income);
  }

  async findAll(): Promise<Income[]> {
    return this.incomesRepository.find({
      relations: ['createdBy'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Income> {
    const income = await this.incomesRepository.findOne({
      where: { id },
      relations: ['createdBy'],
    });

    if (!income) {
      throw new NotFoundException(`Income with ID ${id} not found`);
    }

    return income;
  }

  async update(id: string, updateIncomeDto: UpdateIncomeDto): Promise<Income> {
    const income = await this.findOne(id);
    Object.assign(income, updateIncomeDto);
    return this.incomesRepository.save(income);
  }

  async remove(id: string): Promise<void> {
    const income = await this.findOne(id);
    await this.incomesRepository.remove(income);
  }
}
