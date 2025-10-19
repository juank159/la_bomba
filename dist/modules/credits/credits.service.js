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
exports.CreditsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const credit_entity_1 = require("./entities/credit.entity");
const payment_entity_1 = require("./entities/payment.entity");
const transaction_entity_1 = require("./entities/transaction.entity");
const client_entity_1 = require("../clients/entities/client.entity");
let CreditsService = class CreditsService {
    constructor(creditsRepository, paymentsRepository, transactionsRepository, clientsRepository) {
        this.creditsRepository = creditsRepository;
        this.paymentsRepository = paymentsRepository;
        this.transactionsRepository = transactionsRepository;
        this.clientsRepository = clientsRepository;
    }
    async create(createCreditDto, username) {
        const client = await this.clientsRepository.findOne({
            where: { id: createCreditDto.clientId },
        });
        if (!client) {
            throw new common_1.NotFoundException(`Client with ID ${createCreditDto.clientId} not found`);
        }
        const pendingCredit = await this.creditsRepository.findOne({
            where: {
                clientId: createCreditDto.clientId,
                status: credit_entity_1.CreditStatus.PENDING,
            },
        });
        if (pendingCredit) {
            throw new common_1.BadRequestException(`El cliente ya tiene un crédito pendiente. Debe pagar o agregar el monto al crédito existente (ID: ${pendingCredit.id}).`);
        }
        const credit = this.creditsRepository.create({
            ...createCreditDto,
            createdBy: username,
        });
        const savedCredit = await this.creditsRepository.save(credit);
        return this.findOne(savedCredit.id);
    }
    async findAll() {
        return this.creditsRepository.find({
            relations: ['payments', 'client'],
            order: { createdAt: 'DESC' },
        });
    }
    async findPendingCreditByClient(clientId) {
        const credit = await this.creditsRepository.findOne({
            where: {
                clientId,
                status: credit_entity_1.CreditStatus.PENDING,
            },
            relations: ['payments', 'client'],
        });
        return credit;
    }
    async findOne(id) {
        const credit = await this.creditsRepository.findOne({
            where: { id },
            relations: ['payments', 'client'],
        });
        if (!credit) {
            throw new common_1.NotFoundException(`Credit with ID ${id} not found`);
        }
        const transactions = await this.transactionsRepository.find({
            where: { creditId: id },
            order: { createdAt: 'DESC' },
        });
        credit.transactions = transactions;
        return credit;
    }
    async update(id, updateCreditDto, username) {
        const credit = await this.findOne(id);
        Object.assign(credit, updateCreditDto);
        credit.updatedBy = username;
        return this.creditsRepository.save(credit);
    }
    async addAmountToCredit(id, amount, description, username) {
        const credit = await this.creditsRepository.findOne({
            where: { id },
        });
        if (!credit) {
            throw new common_1.NotFoundException(`Credit with ID ${id} not found`);
        }
        if (credit.status !== credit_entity_1.CreditStatus.PENDING) {
            throw new common_1.BadRequestException('Solo se puede agregar monto a créditos pendientes');
        }
        if (amount <= 0) {
            throw new common_1.BadRequestException('El monto debe ser mayor a cero');
        }
        const newTotalAmount = Number(credit.totalAmount) + Number(amount);
        const transaction = this.transactionsRepository.create({
            creditId: id,
            type: transaction_entity_1.TransactionType.DEBT_INCREASE,
            amount: amount,
            description: description,
            createdBy: username,
        });
        await this.transactionsRepository.save(transaction);
        await this.creditsRepository
            .createQueryBuilder()
            .update(credit_entity_1.Credit)
            .set({
            totalAmount: newTotalAmount,
            updatedBy: username,
        })
            .where('id = :id', { id })
            .execute();
        return this.findOne(id);
    }
    async addPayment(creditId, createPaymentDto, username) {
        const credit = await this.creditsRepository.findOne({
            where: { id: creditId },
        });
        if (!credit) {
            throw new common_1.NotFoundException(`Credit with ID ${creditId} not found`);
        }
        const remainingAmount = credit.totalAmount - credit.paidAmount;
        if (createPaymentDto.amount > remainingAmount) {
            throw new common_1.BadRequestException('Payment amount exceeds remaining balance');
        }
        const payment = this.paymentsRepository.create({
            ...createPaymentDto,
            creditId,
            createdBy: username,
        });
        await this.paymentsRepository.save(payment);
        const transaction = this.transactionsRepository.create({
            creditId: creditId,
            type: transaction_entity_1.TransactionType.PAYMENT,
            amount: createPaymentDto.amount,
            description: createPaymentDto.description || 'Pago',
            createdBy: username,
        });
        await this.transactionsRepository.save(transaction);
        const result = await this.paymentsRepository
            .createQueryBuilder('payment')
            .select('SUM(payment.amount)', 'total')
            .where('payment.creditId = :creditId', { creditId })
            .andWhere('payment.deleted_at IS NULL')
            .getRawOne();
        const newPaidAmount = parseFloat(result.total) || 0;
        const newStatus = newPaidAmount >= Number(credit.totalAmount) ? credit_entity_1.CreditStatus.PAID : credit.status;
        await this.creditsRepository
            .createQueryBuilder()
            .update(credit_entity_1.Credit)
            .set({
            paidAmount: newPaidAmount,
            status: newStatus,
            updatedBy: username,
        })
            .where('id = :id', { id: creditId })
            .execute();
        return this.findOne(creditId);
    }
    async remove(id, username) {
        const credit = await this.findOne(id);
        credit.deletedBy = username;
        await this.creditsRepository.save(credit);
        await this.creditsRepository.softRemove(credit);
    }
    async removePayment(creditId, paymentId, username) {
        const credit = await this.creditsRepository.findOne({
            where: { id: creditId },
        });
        if (!credit) {
            throw new common_1.NotFoundException(`Credit with ID ${creditId} not found`);
        }
        const payment = await this.paymentsRepository.findOne({
            where: { id: paymentId, creditId },
        });
        if (!payment) {
            throw new common_1.NotFoundException(`Payment with ID ${paymentId} not found`);
        }
        payment.deletedBy = username;
        await this.paymentsRepository.save(payment);
        await this.paymentsRepository.softRemove(payment);
        const result = await this.paymentsRepository
            .createQueryBuilder('payment')
            .select('SUM(payment.amount)', 'total')
            .where('payment.creditId = :creditId', { creditId })
            .andWhere('payment.deleted_at IS NULL')
            .getRawOne();
        const newPaidAmount = parseFloat(result.total) || 0;
        await this.creditsRepository
            .createQueryBuilder()
            .update(credit_entity_1.Credit)
            .set({
            paidAmount: newPaidAmount,
            status: credit_entity_1.CreditStatus.PENDING,
            updatedBy: username,
        })
            .where('id = :id', { id: creditId })
            .execute();
        return this.findOne(creditId);
    }
};
exports.CreditsService = CreditsService;
exports.CreditsService = CreditsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(credit_entity_1.Credit)),
    __param(1, (0, typeorm_1.InjectRepository)(payment_entity_1.Payment)),
    __param(2, (0, typeorm_1.InjectRepository)(transaction_entity_1.CreditTransaction)),
    __param(3, (0, typeorm_1.InjectRepository)(client_entity_1.Client)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository,
        typeorm_2.Repository])
], CreditsService);
//# sourceMappingURL=credits.service.js.map