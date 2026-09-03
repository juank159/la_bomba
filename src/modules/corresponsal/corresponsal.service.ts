import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CorresponsalEntry } from './entities/corresponsal-entry.entity';
import { CreateCorresponsalEntryDto } from './dto/create-corresponsal-entry.dto';

@Injectable()
export class CorresponsalService {
  constructor(
    @InjectRepository(CorresponsalEntry)
    private entriesRepository: Repository<CorresponsalEntry>,
  ) {}

  async create(dto: CreateCorresponsalEntryDto, userId: string): Promise<CorresponsalEntry> {
    const entry = this.entriesRepository.create({
      ...dto,
      createdById: userId,
    });
    return this.entriesRepository.save(entry);
  }

  async findAll(): Promise<CorresponsalEntry[]> {
    return this.entriesRepository.find({
      relations: ['createdBy'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<CorresponsalEntry> {
    const entry = await this.entriesRepository.findOne({
      where: { id },
      relations: ['createdBy'],
    });
    if (!entry) {
      throw new NotFoundException(`Registro de corresponsal con ID ${id} no encontrado`);
    }
    return entry;
  }

  async remove(id: string): Promise<void> {
    const entry = await this.findOne(id);
    await this.entriesRepository.remove(entry);
  }
}
