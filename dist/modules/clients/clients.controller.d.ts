import { ClientsService } from './clients.service';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';
export declare class ClientsController {
    private readonly clientsService;
    constructor(clientsService: ClientsService);
    create(createClientDto: CreateClientDto): Promise<import("./entities/client.entity").Client>;
    findAll(search?: string, page?: number, limit?: number): Promise<import("./entities/client.entity").Client[]>;
    count(): Promise<number>;
    findOne(id: string): Promise<import("./entities/client.entity").Client>;
    update(id: string, updateClientDto: UpdateClientDto): Promise<import("./entities/client.entity").Client>;
    remove(id: string): Promise<void>;
}
