import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { ClientBalance } from './entities/client-balance.entity';
import { ClientBalanceTransaction, BalanceTransactionType } from './entities/client-balance-transaction.entity';
import { Client } from '../clients/entities/client.entity';
import { UseBalanceDto } from './dto/use-balance.dto';
import { RefundBalanceDto } from './dto/refund-balance.dto';
import { AdjustBalanceDto } from './dto/adjust-balance.dto';
import { ClientBalanceResponseDto } from './dto/client-balance-response.dto';

@Injectable()
export class ClientBalanceService {
  constructor(
    @InjectRepository(ClientBalance)
    private clientBalanceRepository: Repository<ClientBalance>,
    @InjectRepository(ClientBalanceTransaction)
    private transactionsRepository: Repository<ClientBalanceTransaction>,
    @InjectRepository(Client)
    private clientsRepository: Repository<Client>,
    private dataSource: DataSource,
  ) {}

  /**
   * Obtener o crear el saldo de un cliente
   */
  async getOrCreateClientBalance(clientId: string, username: string): Promise<ClientBalance> {
    // Verificar que el cliente existe
    const client = await this.clientsRepository.findOne({
      where: { id: clientId },
    });

    if (!client) {
      throw new NotFoundException(`Client with ID ${clientId} not found`);
    }

    // Buscar saldo existente
    let clientBalance = await this.clientBalanceRepository.findOne({
      where: { clientId },
      relations: ['client', 'transactions'],
    });

    // Si no existe, crear uno nuevo
    if (!clientBalance) {
      clientBalance = this.clientBalanceRepository.create({
        clientId,
        balance: 0,
        createdBy: username,
      });
      await this.clientBalanceRepository.save(clientBalance);

      // Recargar con relaciones
      clientBalance = await this.clientBalanceRepository.findOne({
        where: { clientId },
        relations: ['client', 'transactions'],
      });
    }

    return clientBalance;
  }

  /**
   * Obtener el saldo de un cliente por ID de cliente
   */
  async getClientBalance(clientId: string): Promise<ClientBalance | null> {
    const balance = await this.clientBalanceRepository.findOne({
      where: { clientId },
      relations: ['client', 'transactions'],
      order: {
        transactions: {
          createdAt: 'DESC',
        },
      },
    });

    return balance;
  }

  /**
   * Obtener todos los saldos de clientes (con saldo > 0)
   */
  async getAllClientBalances(): Promise<ClientBalance[]> {
    return this.clientBalanceRepository
      .createQueryBuilder('balance')
      .leftJoinAndSelect('balance.client', 'client')
      .leftJoinAndSelect('balance.transactions', 'transactions')
      .where('balance.balance > 0')
      .orderBy('balance.balance', 'DESC')
      .addOrderBy('transactions.createdAt', 'DESC')
      .getMany();
  }

  /**
   * Depositar dinero al saldo del cliente (sobrepago)
   */
  async depositBalance(
    clientId: string,
    amount: number,
    description: string,
    username: string,
    relatedCreditId?: string,
    relatedOrderId?: string,
  ): Promise<ClientBalance> {
    if (amount <= 0) {
      throw new BadRequestException('El monto debe ser mayor a cero');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Obtener o crear saldo del cliente
      let clientBalance = await queryRunner.manager.findOne(ClientBalance, {
        where: { clientId },
      });

      if (!clientBalance) {
        clientBalance = queryRunner.manager.create(ClientBalance, {
          clientId,
          balance: 0,
          createdBy: username,
        });
        await queryRunner.manager.save(ClientBalance, clientBalance);
      }

      // Calcular nuevo saldo
      const currentBalance = Number(clientBalance.balance);
      const newBalance = currentBalance + amount;

      // Actualizar saldo
      await queryRunner.manager.update(
        ClientBalance,
        { id: clientBalance.id },
        {
          balance: newBalance,
          updatedBy: username,
        },
      );

      // Crear transacción
      const transaction = queryRunner.manager.create(ClientBalanceTransaction, {
        clientBalanceId: clientBalance.id,
        type: BalanceTransactionType.DEPOSIT,
        amount,
        description,
        balanceAfter: newBalance,
        relatedCreditId,
        relatedOrderId,
        createdBy: username,
      });
      await queryRunner.manager.save(ClientBalanceTransaction, transaction);

      await queryRunner.commitTransaction();

      // Recargar con relaciones
      return this.getClientBalance(clientId);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Usar saldo del cliente para pagar crédito u orden
   */
  async useBalance(useBalanceDto: UseBalanceDto, username: string): Promise<ClientBalance> {
    const { clientId, amount, description, relatedCreditId, relatedOrderId } = useBalanceDto;

    if (amount <= 0) {
      throw new BadRequestException('El monto debe ser mayor a cero');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const clientBalance = await queryRunner.manager.findOne(ClientBalance, {
        where: { clientId },
      });

      if (!clientBalance) {
        throw new NotFoundException(`Client balance not found for client ${clientId}`);
      }

      const currentBalance = Number(clientBalance.balance);

      if (amount > currentBalance) {
        throw new BadRequestException(
          `Saldo insuficiente. Disponible: $${currentBalance}, Solicitado: $${amount}`,
        );
      }

      const newBalance = currentBalance - amount;

      // Actualizar saldo
      await queryRunner.manager.update(
        ClientBalance,
        { id: clientBalance.id },
        {
          balance: newBalance,
          updatedBy: username,
        },
      );

      // Crear transacción
      const transaction = queryRunner.manager.create(ClientBalanceTransaction, {
        clientBalanceId: clientBalance.id,
        type: BalanceTransactionType.USAGE,
        amount,
        description,
        balanceAfter: newBalance,
        relatedCreditId,
        relatedOrderId,
        createdBy: username,
      });
      await queryRunner.manager.save(ClientBalanceTransaction, transaction);

      await queryRunner.commitTransaction();

      return this.getClientBalance(clientId);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Devolver saldo al cliente (reembolso)
   */
  async refundBalance(refundBalanceDto: RefundBalanceDto, username: string): Promise<ClientBalance> {
    const { clientId, amount, description } = refundBalanceDto;

    if (amount <= 0) {
      throw new BadRequestException('El monto debe ser mayor a cero');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const clientBalance = await queryRunner.manager.findOne(ClientBalance, {
        where: { clientId },
      });

      if (!clientBalance) {
        throw new NotFoundException(`Client balance not found for client ${clientId}`);
      }

      const currentBalance = Number(clientBalance.balance);

      if (amount > currentBalance) {
        throw new BadRequestException(
          `Monto de reembolso excede el saldo disponible. Disponible: $${currentBalance}, Solicitado: $${amount}`,
        );
      }

      const newBalance = currentBalance - amount;

      // Actualizar saldo
      await queryRunner.manager.update(
        ClientBalance,
        { id: clientBalance.id },
        {
          balance: newBalance,
          updatedBy: username,
        },
      );

      // Crear transacción
      const transaction = queryRunner.manager.create(ClientBalanceTransaction, {
        clientBalanceId: clientBalance.id,
        type: BalanceTransactionType.REFUND,
        amount,
        description,
        balanceAfter: newBalance,
        createdBy: username,
      });
      await queryRunner.manager.save(ClientBalanceTransaction, transaction);

      await queryRunner.commitTransaction();

      return this.getClientBalance(clientId);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Ajustar saldo manualmente (corrección)
   */
  async adjustBalance(adjustBalanceDto: AdjustBalanceDto, username: string): Promise<ClientBalance> {
    const { clientId, amount, description } = adjustBalanceDto;

    if (amount === 0) {
      throw new BadRequestException('El monto del ajuste no puede ser cero');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      let clientBalance = await queryRunner.manager.findOne(ClientBalance, {
        where: { clientId },
      });

      if (!clientBalance) {
        // Si no existe, crear uno nuevo
        clientBalance = queryRunner.manager.create(ClientBalance, {
          clientId,
          balance: 0,
          createdBy: username,
        });
        await queryRunner.manager.save(ClientBalance, clientBalance);
      }

      const currentBalance = Number(clientBalance.balance);
      const newBalance = currentBalance + amount;

      if (newBalance < 0) {
        throw new BadRequestException(
          `El ajuste resultaría en un saldo negativo. Saldo actual: $${currentBalance}, Ajuste: $${amount}`,
        );
      }

      // Actualizar saldo
      await queryRunner.manager.update(
        ClientBalance,
        { id: clientBalance.id },
        {
          balance: newBalance,
          updatedBy: username,
        },
      );

      // Crear transacción
      const transaction = queryRunner.manager.create(ClientBalanceTransaction, {
        clientBalanceId: clientBalance.id,
        type: BalanceTransactionType.ADJUSTMENT,
        amount: Math.abs(amount),
        description: `${amount > 0 ? 'Aumento' : 'Reducción'} - ${description}`,
        balanceAfter: newBalance,
        createdBy: username,
      });
      await queryRunner.manager.save(ClientBalanceTransaction, transaction);

      await queryRunner.commitTransaction();

      return this.getClientBalance(clientId);
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Obtener historial de transacciones de un cliente
   */
  async getClientTransactions(clientId: string): Promise<ClientBalanceTransaction[]> {
    const clientBalance = await this.clientBalanceRepository.findOne({
      where: { clientId },
    });

    if (!clientBalance) {
      return [];
    }

    return this.transactionsRepository.find({
      where: { clientBalanceId: clientBalance.id },
      relations: ['relatedCredit'],
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Convertir entidad a DTO de respuesta
   */
  toResponseDto(clientBalance: ClientBalance): ClientBalanceResponseDto {
    return {
      id: clientBalance.id,
      clientId: clientBalance.clientId,
      clientName: clientBalance.client ? clientBalance.client.nombre : 'Unknown',
      balance: Number(clientBalance.balance),
      transactions: clientBalance.transactions
        ? clientBalance.transactions.map((t) => ({
            id: t.id,
            type: t.type,
            amount: Number(t.amount),
            description: t.description,
            balanceAfter: Number(t.balanceAfter),
            relatedCreditId: t.relatedCreditId,
            relatedOrderId: t.relatedOrderId,
            createdBy: t.createdBy,
            createdAt: t.createdAt,
          }))
        : [],
      createdBy: clientBalance.createdBy,
      updatedBy: clientBalance.updatedBy,
      createdAt: clientBalance.createdAt,
      updatedAt: clientBalance.updatedAt,
    };
  }
}
