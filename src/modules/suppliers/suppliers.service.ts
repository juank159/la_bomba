import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Supplier } from './entities/supplier.entity';
import { CreateSupplierDto } from './dto/create-supplier.dto';
import { UpdateSupplierDto } from './dto/update-supplier.dto';

@Injectable()
export class SuppliersService {
  constructor(
    @InjectRepository(Supplier)
    private suppliersRepository: Repository<Supplier>,
  ) {}

  async create(createSupplierDto: CreateSupplierDto): Promise<Supplier> {
    // Verificar que el nombre no exista
    const existingSupplierByName = await this.suppliersRepository.findOne({
      where: { nombre: createSupplierDto.nombre },
    });

    if (existingSupplierByName) {
      throw new ConflictException(
        `Ya existe un proveedor con el nombre "${createSupplierDto.nombre}"`,
      );
    }

    // Verificar que el celular no exista (si se proporciona)
    if (createSupplierDto.celular) {
      const existingSupplierByPhone = await this.suppliersRepository.findOne({
        where: { celular: createSupplierDto.celular },
      });

      if (existingSupplierByPhone) {
        throw new ConflictException(
          `Ya existe un proveedor con el celular "${createSupplierDto.celular}"`,
        );
      }
    }

    const supplier = this.suppliersRepository.create(createSupplierDto);
    return this.suppliersRepository.save(supplier);
  }

  async findAll(search?: string, page?: number, limit?: number): Promise<Supplier[]> {
    if (search && search.trim().length > 0) {
      return this.searchSuppliers(search, page || 0, limit || 20);
    }

    return this.suppliersRepository.find({
      where: { isActive: true },
      order: { createdAt: 'DESC' },
      skip: page ? page * (limit || 20) : undefined,
      take: limit || undefined,
    });
  }

  async searchSuppliers(
    search: string,
    page: number = 0,
    limit: number = 20,
  ): Promise<Supplier[]> {
    const searchTerm = `%${search}%`;

    return this.suppliersRepository.find({
      where: [
        { nombre: ILike(searchTerm), isActive: true },
        { celular: ILike(searchTerm), isActive: true },
        { email: ILike(searchTerm), isActive: true },
        { direccion: ILike(searchTerm), isActive: true },
      ],
      order: { createdAt: 'DESC' },
      skip: page * limit,
      take: limit,
    });
  }

  async findOne(id: string): Promise<Supplier> {
    const supplier = await this.suppliersRepository.findOne({
      where: { id, isActive: true },
    });

    if (!supplier) {
      throw new NotFoundException(`Proveedor con ID ${id} no encontrado`);
    }

    return supplier;
  }

  async update(id: string, updateSupplierDto: UpdateSupplierDto): Promise<Supplier> {
    const supplier = await this.findOne(id);

    // Verificar que el nombre no exista (si se está cambiando)
    if (updateSupplierDto.nombre && updateSupplierDto.nombre !== supplier.nombre) {
      const existingSupplierByName = await this.suppliersRepository.findOne({
        where: { nombre: updateSupplierDto.nombre },
      });

      if (existingSupplierByName) {
        throw new ConflictException(
          `Ya existe un proveedor con el nombre "${updateSupplierDto.nombre}"`,
        );
      }
    }

    // Verificar que el celular no exista (si se está cambiando)
    if (updateSupplierDto.celular && updateSupplierDto.celular !== supplier.celular) {
      const existingSupplierByPhone = await this.suppliersRepository.findOne({
        where: { celular: updateSupplierDto.celular },
      });

      if (existingSupplierByPhone) {
        throw new ConflictException(
          `Ya existe un proveedor con el celular "${updateSupplierDto.celular}"`,
        );
      }
    }

    Object.assign(supplier, updateSupplierDto);
    return this.suppliersRepository.save(supplier);
  }

  async remove(id: string): Promise<void> {
    const supplier = await this.findOne(id);
    supplier.isActive = false;
    await this.suppliersRepository.save(supplier);
  }

  async count(): Promise<number> {
    return this.suppliersRepository.count({ where: { isActive: true } });
  }
}
