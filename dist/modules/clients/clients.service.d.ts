import { Repository } from 'typeorm';
import { Client } from './entities/client.entity';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';
export declare class ClientsService {
    private clientsRepository;
    constructor(clientsRepository: Repository<Client>);
    create(createClientDto: CreateClientDto): Promise<Client>;
    findAll(search?: string, page?: number, limit?: number): Promise<Client[]>;
    searchClients(search: string, page?: number, limit?: number): Promise<Client[]>;
    findOne(id: string): Promise<Client>;
    update(id: string, updateClientDto: UpdateClientDto): Promise<Client>;
    remove(id: string): Promise<void>;
    count(): Promise<number>;
}
