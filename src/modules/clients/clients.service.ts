import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Client } from './entities/client.entity';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';

@Injectable()
export class ClientsService {
  constructor(
    @InjectRepository(Client)
    private clientsRepository: Repository<Client>,
  ) {}

  async create(createClientDto: CreateClientDto): Promise<Client> {
    // Verificar que el nombre no exista
    const existingClientByName = await this.clientsRepository.findOne({
      where: { nombre: createClientDto.nombre },
    });

    if (existingClientByName) {
      throw new ConflictException(
        `Ya existe un cliente con el nombre "${createClientDto.nombre}"`,
      );
    }

    // Verificar que el celular no exista (si se proporciona)
    if (createClientDto.celular) {
      const existingClientByPhone = await this.clientsRepository.findOne({
        where: { celular: createClientDto.celular },
      });

      if (existingClientByPhone) {
        throw new ConflictException(
          `Ya existe un cliente con el celular "${createClientDto.celular}"`,
        );
      }
    }

    const client = this.clientsRepository.create(createClientDto);
    return this.clientsRepository.save(client);
  }

  async findAll(search?: string, page?: number, limit?: number): Promise<Client[]> {
    if (search && search.trim().length > 0) {
      return this.searchClients(search, page || 0, limit || 20);
    }

    return this.clientsRepository.find({
      where: { isActive: true },
      order: { createdAt: 'DESC' },
      skip: page ? page * (limit || 20) : undefined,
      take: limit || undefined,
    });
  }

  async searchClients(
    search: string,
    page: number = 0,
    limit: number = 20,
  ): Promise<Client[]> {
    const searchTerm = `%${search}%`;

    return this.clientsRepository.find({
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

  async findOne(id: string): Promise<Client> {
    const client = await this.clientsRepository.findOne({
      where: { id, isActive: true },
    });

    if (!client) {
      throw new NotFoundException(`Cliente con ID ${id} no encontrado`);
    }

    return client;
  }

  async update(id: string, updateClientDto: UpdateClientDto): Promise<Client> {
    const client = await this.findOne(id);

    // Verificar que el nombre no exista (si se está cambiando)
    if (updateClientDto.nombre && updateClientDto.nombre !== client.nombre) {
      const existingClientByName = await this.clientsRepository.findOne({
        where: { nombre: updateClientDto.nombre },
      });

      if (existingClientByName) {
        throw new ConflictException(
          `Ya existe un cliente con el nombre "${updateClientDto.nombre}"`,
        );
      }
    }

    // Verificar que el celular no exista (si se está cambiando)
    if (updateClientDto.celular && updateClientDto.celular !== client.celular) {
      const existingClientByPhone = await this.clientsRepository.findOne({
        where: { celular: updateClientDto.celular },
      });

      if (existingClientByPhone) {
        throw new ConflictException(
          `Ya existe un cliente con el celular "${updateClientDto.celular}"`,
        );
      }
    }

    Object.assign(client, updateClientDto);
    return this.clientsRepository.save(client);
  }

  async remove(id: string): Promise<void> {
    const client = await this.findOne(id);
    client.isActive = false;
    await this.clientsRepository.save(client);
  }

  async count(): Promise<number> {
    return this.clientsRepository.count({ where: { isActive: true } });
  }
}
