import { Repository } from 'typeorm';
import { Credit } from './entities/credit.entity';
import { Payment } from './entities/payment.entity';
import { CreditTransaction } from './entities/transaction.entity';
import { Client } from '../clients/entities/client.entity';
import { CreateCreditDto } from './dto/create-credit.dto';
import { UpdateCreditDto } from './dto/update-credit.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
export declare class CreditsService {
    private creditsRepository;
    private paymentsRepository;
    private transactionsRepository;
    private clientsRepository;
    constructor(creditsRepository: Repository<Credit>, paymentsRepository: Repository<Payment>, transactionsRepository: Repository<CreditTransaction>, clientsRepository: Repository<Client>);
    create(createCreditDto: CreateCreditDto, username: string): Promise<Credit>;
    findAll(): Promise<Credit[]>;
    findPendingCreditByClient(clientId: string): Promise<Credit | null>;
    findOne(id: string): Promise<Credit>;
    update(id: string, updateCreditDto: UpdateCreditDto, username: string): Promise<Credit>;
    addAmountToCredit(id: string, amount: number, description: string, username: string): Promise<Credit>;
    addPayment(creditId: string, createPaymentDto: CreatePaymentDto, username: string): Promise<Credit>;
    remove(id: string, username: string): Promise<void>;
    removePayment(creditId: string, paymentId: string, username: string): Promise<Credit>;
}
