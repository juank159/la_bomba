import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Credit, CreditStatus } from './entities/credit.entity';
import { Payment } from './entities/payment.entity';
import { CreditTransaction, TransactionType } from './entities/transaction.entity';
import { Client } from '../clients/entities/client.entity';
import { CreateCreditDto } from './dto/create-credit.dto';
import { UpdateCreditDto } from './dto/update-credit.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';

@Injectable()
export class CreditsService {
  constructor(
    @InjectRepository(Credit)
    private creditsRepository: Repository<Credit>,
    @InjectRepository(Payment)
    private paymentsRepository: Repository<Payment>,
    @InjectRepository(CreditTransaction)
    private transactionsRepository: Repository<CreditTransaction>,
    @InjectRepository(Client)
    private clientsRepository: Repository<Client>,
  ) {}

  async create(createCreditDto: CreateCreditDto, username: string): Promise<Credit> {
    // Validate that client exists
    const client = await this.clientsRepository.findOne({
      where: { id: createCreditDto.clientId },
    });

    if (!client) {
      throw new NotFoundException(`Client with ID ${createCreditDto.clientId} not found`);
    }

    // Check if client has pending credits
    const pendingCredit = await this.creditsRepository.findOne({
      where: {
        clientId: createCreditDto.clientId,
        status: CreditStatus.PENDING,
      },
    });

    if (pendingCredit) {
      throw new BadRequestException(
        `El cliente ya tiene un crédito pendiente. Debe pagar o agregar el monto al crédito existente (ID: ${pendingCredit.id}).`
      );
    }

    const credit = this.creditsRepository.create({
      ...createCreditDto,
      createdBy: username,
    });
    const savedCredit = await this.creditsRepository.save(credit);

    // Reload with relations to ensure client is loaded
    return this.findOne(savedCredit.id);
  }

  async findAll(): Promise<Credit[]> {
    return this.creditsRepository.find({
      relations: ['payments', 'client'],
      order: { createdAt: 'DESC' },
    });
  }

  async findPendingCreditByClient(clientId: string): Promise<Credit | null> {
    const credit = await this.creditsRepository.findOne({
      where: {
        clientId,
        status: CreditStatus.PENDING,
      },
      relations: ['payments', 'client'],
    });

    return credit;
  }

  async findOne(id: string): Promise<Credit> {
    const credit = await this.creditsRepository.findOne({
      where: { id },
      relations: ['payments', 'client'],
    });

    if (!credit) {
      throw new NotFoundException(`Credit with ID ${id} not found`);
    }

    // Load transactions separately to include in response
    const transactions = await this.transactionsRepository.find({
      where: { creditId: id },
      order: { createdAt: 'DESC' },
    });

    // Attach transactions to credit object for API response
    (credit as any).transactions = transactions;

    return credit;
  }

  async update(id: string, updateCreditDto: UpdateCreditDto, username: string): Promise<Credit> {
    const credit = await this.findOne(id);
    Object.assign(credit, updateCreditDto);
    credit.updatedBy = username;
    return this.creditsRepository.save(credit);
  }

  async addAmountToCredit(id: string, amount: number, description: string, username: string): Promise<Credit> {
    const credit = await this.creditsRepository.findOne({
      where: { id },
    });

    if (!credit) {
      throw new NotFoundException(`Credit with ID ${id} not found`);
    }

    if (credit.status !== CreditStatus.PENDING) {
      throw new BadRequestException('Solo se puede agregar monto a créditos pendientes');
    }

    if (amount <= 0) {
      throw new BadRequestException('El monto debe ser mayor a cero');
    }

    const newTotalAmount = Number(credit.totalAmount) + Number(amount);

    // Register transaction
    const transaction = this.transactionsRepository.create({
      creditId: id,
      type: TransactionType.DEBT_INCREASE,
      amount: amount,
      description: description,
      createdBy: username,
    });
    await this.transactionsRepository.save(transaction);

    await this.creditsRepository
      .createQueryBuilder()
      .update(Credit)
      .set({
        totalAmount: newTotalAmount,
        updatedBy: username,
      })
      .where('id = :id', { id })
      .execute();

    return this.findOne(id);
  }

  async addPayment(creditId: string, createPaymentDto: CreatePaymentDto, username: string): Promise<Credit> {
    // Load credit WITHOUT relations to avoid TypeORM trying to sync the bidirectional relationship
    const credit = await this.creditsRepository.findOne({
      where: { id: creditId },
    });

    if (!credit) {
      throw new NotFoundException(`Credit with ID ${creditId} not found`);
    }

    const remainingAmount = credit.totalAmount - credit.paidAmount;

    if (createPaymentDto.amount > remainingAmount) {
      throw new BadRequestException('Payment amount exceeds remaining balance');
    }

    const payment = this.paymentsRepository.create({
      ...createPaymentDto,
      creditId,
      createdBy: username,
    });

    await this.paymentsRepository.save(payment);

    // Register transaction
    const transaction = this.transactionsRepository.create({
      creditId: creditId,
      type: TransactionType.PAYMENT,
      amount: createPaymentDto.amount,
      description: createPaymentDto.description || 'Pago',
      createdBy: username,
    });
    await this.transactionsRepository.save(transaction);

    // Calculate total paid amount by summing all payments
    const result = await this.paymentsRepository
      .createQueryBuilder('payment')
      .select('SUM(payment.amount)', 'total')
      .where('payment.creditId = :creditId', { creditId })
      .andWhere('payment.deleted_at IS NULL')
      .getRawOne();

    const newPaidAmount = parseFloat(result.total) || 0;
    const newStatus = newPaidAmount >= Number(credit.totalAmount) ? CreditStatus.PAID : credit.status;

    // Use QueryBuilder to update directly without loading relations
    await this.creditsRepository
      .createQueryBuilder()
      .update(Credit)
      .set({
        paidAmount: newPaidAmount,
        status: newStatus,
        updatedBy: username,
      })
      .where('id = :id', { id: creditId })
      .execute();

    return this.findOne(creditId);
  }

  async remove(id: string, username: string): Promise<void> {
    const credit = await this.findOne(id);
    credit.deletedBy = username;
    await this.creditsRepository.save(credit);
    await this.creditsRepository.softRemove(credit);
  }

  async removePayment(creditId: string, paymentId: string, username: string): Promise<Credit> {
    // Load credit WITHOUT relations to avoid TypeORM trying to sync the bidirectional relationship
    const credit = await this.creditsRepository.findOne({
      where: { id: creditId },
    });

    if (!credit) {
      throw new NotFoundException(`Credit with ID ${creditId} not found`);
    }

    const payment = await this.paymentsRepository.findOne({
      where: { id: paymentId, creditId },
    });

    if (!payment) {
      throw new NotFoundException(`Payment with ID ${paymentId} not found`);
    }

    payment.deletedBy = username;
    await this.paymentsRepository.save(payment);
    await this.paymentsRepository.softRemove(payment);

    // Calculate total paid amount by summing all remaining payments
    const result = await this.paymentsRepository
      .createQueryBuilder('payment')
      .select('SUM(payment.amount)', 'total')
      .where('payment.creditId = :creditId', { creditId })
      .andWhere('payment.deleted_at IS NULL')
      .getRawOne();

    const newPaidAmount = parseFloat(result.total) || 0;

    // Use QueryBuilder to update directly without loading relations
    await this.creditsRepository
      .createQueryBuilder()
      .update(Credit)
      .set({
        paidAmount: newPaidAmount,
        status: CreditStatus.PENDING,
        updatedBy: username,
      })
      .where('id = :id', { id: creditId })
      .execute();

    return this.findOne(creditId);
  }
}