"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ClientsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const client_entity_1 = require("./entities/client.entity");
let ClientsService = class ClientsService {
    constructor(clientsRepository) {
        this.clientsRepository = clientsRepository;
    }
    async create(createClientDto) {
        const existingClientByName = await this.clientsRepository.findOne({
            where: { nombre: createClientDto.nombre },
        });
        if (existingClientByName) {
            throw new common_1.ConflictException(`Ya existe un cliente con el nombre "${createClientDto.nombre}"`);
        }
        if (createClientDto.celular) {
            const existingClientByPhone = await this.clientsRepository.findOne({
                where: { celular: createClientDto.celular },
            });
            if (existingClientByPhone) {
                throw new common_1.ConflictException(`Ya existe un cliente con el celular "${createClientDto.celular}"`);
            }
        }
        const client = this.clientsRepository.create(createClientDto);
        return this.clientsRepository.save(client);
    }
    async findAll(search, page, limit) {
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
    async searchClients(search, page = 0, limit = 20) {
        const searchTerm = `%${search}%`;
        return this.clientsRepository.find({
            where: [
                { nombre: (0, typeorm_2.ILike)(searchTerm), isActive: true },
                { celular: (0, typeorm_2.ILike)(searchTerm), isActive: true },
                { email: (0, typeorm_2.ILike)(searchTerm), isActive: true },
                { direccion: (0, typeorm_2.ILike)(searchTerm), isActive: true },
            ],
            order: { createdAt: 'DESC' },
            skip: page * limit,
            take: limit,
        });
    }
    async findOne(id) {
        const client = await this.clientsRepository.findOne({
            where: { id, isActive: true },
        });
        if (!client) {
            throw new common_1.NotFoundException(`Cliente con ID ${id} no encontrado`);
        }
        return client;
    }
    async update(id, updateClientDto) {
        const client = await this.findOne(id);
        if (updateClientDto.nombre && updateClientDto.nombre !== client.nombre) {
            const existingClientByName = await this.clientsRepository.findOne({
                where: { nombre: updateClientDto.nombre },
            });
            if (existingClientByName) {
                throw new common_1.ConflictException(`Ya existe un cliente con el nombre "${updateClientDto.nombre}"`);
            }
        }
        if (updateClientDto.celular && updateClientDto.celular !== client.celular) {
            const existingClientByPhone = await this.clientsRepository.findOne({
                where: { celular: updateClientDto.celular },
            });
            if (existingClientByPhone) {
                throw new common_1.ConflictException(`Ya existe un cliente con el celular "${updateClientDto.celular}"`);
            }
        }
        Object.assign(client, updateClientDto);
        return this.clientsRepository.save(client);
    }
    async remove(id) {
        const client = await this.findOne(id);
        client.isActive = false;
        await this.clientsRepository.save(client);
    }
    async count() {
        return this.clientsRepository.count({ where: { isActive: true } });
    }
};
exports.ClientsService = ClientsService;
exports.ClientsService = ClientsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(client_entity_1.Client)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], ClientsService);
//# sourceMappingURL=clients.service.js.map