import { Injectable, NotFoundException, BadRequestException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, MoreThan, DataSource } from 'typeorm';
import { Credit, CreditStatus } from './entities/credit.entity';
import { Payment } from './entities/payment.entity';
import { CreditTransaction, TransactionType } from './entities/transaction.entity';
import { Client } from '../clients/entities/client.entity';
import { CreateCreditDto } from './dto/create-credit.dto';
import { UpdateCreditDto } from './dto/update-credit.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { ClientBalanceService } from './client-balance.service';
import { Notification, NotificationType } from '../notifications/entities/notification.entity';
import { User, UserRole } from '../users/entities/user.entity';

// Ventana para detectar envíos duplicados (doble clic / reintentos de red)
const DUPLICATE_SUBMISSION_WINDOW_MS = 15000;

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
    @InjectRepository(Notification)
    private notificationsRepository: Repository<Notification>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @Inject(forwardRef(() => ClientBalanceService))
    private clientBalanceService: ClientBalanceService,
    private dataSource: DataSource,
  ) {}

  async create(createCreditDto: CreateCreditDto, username: string): Promise<Credit> {
    console.log(`📝 [Credits] create iniciado para cliente ${createCreditDto.clientId}, monto: ${createCreditDto.totalAmount}`);
    console.log(`📝 [Credits] useClientBalance recibido:`, {
      value: createCreditDto.useClientBalance,
      type: typeof createCreditDto.useClientBalance,
      isTrue: createCreditDto.useClientBalance === true,
      isTruthy: !!createCreditDto.useClientBalance,
    });

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

    // Crear el crédito primero
    const credit = this.creditsRepository.create({
      clientId: createCreditDto.clientId,
      description: createCreditDto.description,
      totalAmount: createCreditDto.totalAmount,
      createdBy: username,
    });
    const savedCredit = await this.creditsRepository.save(credit);
    console.log(`✅ [Credits] Crédito creado con ID: ${savedCredit.id}`);

    // ✅ Crear transacción inicial para registrar el crédito original en el historial
    const initialTransaction = this.transactionsRepository.create({
      creditId: savedCredit.id,
      type: TransactionType.CHARGE,
      amount: createCreditDto.totalAmount,
      description: createCreditDto.description,
      paymentMethodId: null, // No aplica para cargos iniciales
      createdBy: username,
      balanceAfter: createCreditDto.totalAmount,
    });
    await this.transactionsRepository.save(initialTransaction);
    console.log(`✅ [Credits] Transacción inicial creada`);

    // 💰 Si el cliente quiere usar su saldo a favor, aplicarlo automáticamente
    console.log(`🔍 [Credits] Verificando si debe usar saldo a favor: ${!!createCreditDto.useClientBalance}`);
    if (createCreditDto.useClientBalance) {
      console.log(`💰💰💰 [Credits] ✅ SÍ ENTRA AL BLOQUE - Cliente solicitó usar saldo a favor para crédito ${savedCredit.id}`);

      try {
        // Obtener el saldo actual del cliente
        const clientBalance = await this.clientBalanceService.getClientBalance(createCreditDto.clientId);

        if (clientBalance && Number(clientBalance.balance) > 0) {
          const availableBalance = Number(clientBalance.balance);
          const remainingAmount = Number(savedCredit.totalAmount);

          // Determinar cuánto saldo usar (no puede exceder el monto del crédito)
          const balanceToUse = Math.min(availableBalance, remainingAmount);

          console.log(`💰 [Credits] Saldo disponible: ${availableBalance}, Deuda: ${remainingAmount}, Usando: ${balanceToUse}`);

          if (balanceToUse > 0) {
            // Usar el saldo a favor para pagar parcial o totalmente el crédito
            await this.clientBalanceService.useBalance(
              {
                clientId: createCreditDto.clientId,
                amount: balanceToUse,
                description: `Aplicado automáticamente al crédito #${savedCredit.id.substring(0, 8)}... - ${createCreditDto.description}`,
                relatedCreditId: savedCredit.id,
              },
              username,
            );

            console.log(`✅ [Credits] Saldo a favor de $${balanceToUse} aplicado exitosamente`);

            // CRÍTICO: pago virtual + transacción + actualización del
            // crédito deben ser atómicos (misma razón que
            // addAmountToCredit/addPayment).
            const queryRunner = this.dataSource.createQueryRunner();
            await queryRunner.connect();
            await queryRunner.startTransaction();

            try {
              // Crear un "pago" virtual que represente el uso del saldo
              const balancePayment = queryRunner.manager.create(Payment, {
                creditId: savedCredit.id,
                amount: balanceToUse,
                description: `Abono de saldo a favor`,
                createdBy: username,
              });
              await queryRunner.manager.save(Payment, balancePayment);

              // Registrar transacción de pago con saldo
              const paymentTransaction = queryRunner.manager.create(CreditTransaction, {
                creditId: savedCredit.id,
                type: TransactionType.PAYMENT,
                amount: balanceToUse,
                description: `Abono de saldo a favor`,
                paymentMethodId: null, // No aplica método de pago para saldo a favor
                createdBy: username,
                balanceAfter: remainingAmount - balanceToUse,
              });
              await queryRunner.manager.save(CreditTransaction, paymentTransaction);

              // Actualizar el crédito
              const newPaidAmount = balanceToUse;
              const newStatus = newPaidAmount >= Number(savedCredit.totalAmount) ? CreditStatus.PAID : CreditStatus.PENDING;

              await queryRunner.manager.update(
                Credit,
                { id: savedCredit.id },
                {
                  paidAmount: newPaidAmount,
                  status: newStatus,
                  updatedBy: username,
                },
              );

              await queryRunner.commitTransaction();
              console.log(`✅ [Credits] Crédito actualizado. Pagado: ${newPaidAmount}, Estado: ${newStatus}`);
            } catch (txError) {
              await queryRunner.rollbackTransaction();
              throw txError;
            } finally {
              await queryRunner.release();
            }
          }
        } else {
          console.log(`ℹ️ [Credits] Cliente no tiene saldo a favor disponible`);
        }
      } catch (balanceError) {
        console.error(`❌❌❌ [Credits] ERROR CRÍTICO al aplicar saldo a favor:`, balanceError);
        console.error(`❌❌❌ [Credits] Stack trace:`, balanceError.stack);
        console.error(`❌❌❌ [Credits] Error details:`, {
          message: balanceError.message,
          name: balanceError.name,
          clientId: createCreditDto.clientId,
          creditId: savedCredit.id,
        });
        // No lanzar el error para que el crédito se cree de todas formas
        // El saldo simplemente no se aplicará
        // IMPORTANTE: Este error debe ser visible en los logs de producción
      }
    } else {
      console.log(`⚠️ [Credits] NO SE APLICARÁ saldo a favor porque useClientBalance = ${createCreditDto.useClientBalance}`);
    }

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

  /**
   * 🔧 Método auxiliar para aplicar saldo a favor manualmente a un crédito existente
   * Útil cuando el saldo no se aplicó automáticamente al crear el crédito
   */
  async applyClientBalanceManually(creditId: string, username: string): Promise<Credit> {
    console.log(`🔧 [Credits] Aplicando saldo a favor manualmente al crédito ${creditId}`);

    // Obtener el crédito
    const credit = await this.creditsRepository.findOne({
      where: { id: creditId },
      relations: ['payments', 'client'],
    });

    if (!credit) {
      throw new NotFoundException(`Credit with ID ${creditId} not found`);
    }

    if (credit.status === CreditStatus.PAID) {
      throw new BadRequestException('Este crédito ya está pagado completamente');
    }

    // Obtener el saldo actual del cliente
    const clientBalance = await this.clientBalanceService.getClientBalance(credit.clientId);

    if (!clientBalance || Number(clientBalance.balance) <= 0) {
      throw new BadRequestException('El cliente no tiene saldo a favor disponible');
    }

    const availableBalance = Number(clientBalance.balance);
    const remainingAmount = Number(credit.totalAmount) - Number(credit.paidAmount);

    // Determinar cuánto saldo usar
    const balanceToUse = Math.min(availableBalance, remainingAmount);

    console.log(`🔧 [Credits] Saldo disponible: ${availableBalance}, Deuda pendiente: ${remainingAmount}, Usando: ${balanceToUse}`);

    // Usar el saldo a favor
    await this.clientBalanceService.useBalance(
      {
        clientId: credit.clientId,
        amount: balanceToUse,
        description: `Aplicado manualmente al crédito #${creditId.substring(0, 8)}... - ${credit.description}`,
        relatedCreditId: creditId,
      },
      username,
    );

    console.log(`✅ [Credits] Saldo a favor de $${balanceToUse} usado en client_balance_transactions`);

    // CRÍTICO: pago + transacción + actualización del crédito deben ser
    // atómicos (misma razón que addAmountToCredit/addPayment).
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    let newPaidAmount: number;
    let newStatus: CreditStatus;

    try {
      // Crear un "pago" que represente el uso del saldo
      const balancePayment = queryRunner.manager.create(Payment, {
        creditId: creditId,
        amount: balanceToUse,
        description: `Abono de saldo a favor`,
        createdBy: username,
      });
      await queryRunner.manager.save(Payment, balancePayment);
      console.log(`✅ [Credits] Pago registrado en tabla payments`);

      // Registrar transacción de pago con saldo
      const paymentTransaction = queryRunner.manager.create(CreditTransaction, {
        creditId: creditId,
        type: TransactionType.PAYMENT,
        amount: balanceToUse,
        description: `Abono de saldo a favor`,
        paymentMethodId: null,
        createdBy: username,
        balanceAfter: remainingAmount - balanceToUse,
      });
      await queryRunner.manager.save(CreditTransaction, paymentTransaction);
      console.log(`✅ [Credits] Transacción registrada en credit_transactions`);

      // Actualizar el crédito
      newPaidAmount = Number(credit.paidAmount) + balanceToUse;
      newStatus = newPaidAmount >= Number(credit.totalAmount) ? CreditStatus.PAID : CreditStatus.PENDING;

      await queryRunner.manager.update(
        Credit,
        { id: creditId },
        {
          paidAmount: newPaidAmount,
          status: newStatus,
          updatedBy: username,
        },
      );

      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }

    console.log(`✅ [Credits] Crédito actualizado. Total pagado: ${newPaidAmount}, Estado: ${newStatus}`);

    return this.findOne(creditId);
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

    // Evita duplicados por doble clic / reintentos del cliente: si ya se registró
    // el mismo aumento de deuda (mismo crédito, monto, descripción y usuario) en
    // los últimos segundos, se responde con el crédito actual sin duplicar la transacción.
    const recentDuplicate = await this.transactionsRepository.findOne({
      where: {
        creditId: id,
        type: TransactionType.DEBT_INCREASE,
        amount,
        description,
        createdBy: username,
        createdAt: MoreThan(new Date(Date.now() - DUPLICATE_SUBMISSION_WINDOW_MS)),
      },
      order: { createdAt: 'DESC' },
    });
    if (recentDuplicate) {
      return this.findOne(id);
    }

    const newTotalAmount = Number(credit.totalAmount) + Number(amount);
    const newRemainingAmount = Number(credit.remainingAmount) + Number(amount);

    // CRÍTICO: registrar la transacción y actualizar el total del crédito
    // deben ser una sola operación atómica. Antes eran dos escrituras
    // separadas - si la segunda fallaba (ej. un desbordamiento numérico),
    // la primera ya había quedado guardada, dejando una transacción
    // "fantasma" en el historial que nunca se reflejó en el saldo real.
    // Con QueryRunner, si cualquiera de las dos falla, NINGUNA se guarda.
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const transaction = queryRunner.manager.create(CreditTransaction, {
        creditId: id,
        type: TransactionType.DEBT_INCREASE,
        amount: amount,
        description: description,
        paymentMethodId: null, // No aplica para aumentos de deuda
        createdBy: username,
        balanceAfter: newRemainingAmount, // Saldo pendiente después de aumentar la deuda
      });
      await queryRunner.manager.save(CreditTransaction, transaction);

      await queryRunner.manager.update(
        Credit,
        { id },
        {
          totalAmount: newTotalAmount,
          updatedBy: username,
        },
      );

      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }

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

    const remainingAmount = Number(credit.totalAmount) - Number(credit.paidAmount);
    const paymentAmount = Number(createPaymentDto.amount);

    // Validar que el monto del pago sea mayor a cero
    if (paymentAmount <= 0) {
      throw new BadRequestException('El monto del pago debe ser mayor a cero');
    }

    // Evita duplicados por doble clic / reintentos del cliente: si ya se registró
    // el mismo pago (mismo crédito, monto, método y usuario) en los últimos
    // segundos, se responde con el crédito actual sin duplicar el pago.
    const recentDuplicatePayment = await this.paymentsRepository.findOne({
      where: {
        creditId,
        amount: paymentAmount,
        description: createPaymentDto.description || 'Pago',
        createdBy: username,
        createdAt: MoreThan(new Date(Date.now() - DUPLICATE_SUBMISSION_WINDOW_MS)),
      },
      order: { createdAt: 'DESC' },
    });
    if (recentDuplicatePayment) {
      return this.findOne(creditId);
    }

    // 💡 MANEJO DE SOBREPAGOS
    // Si el pago excede el saldo pendiente, lo permitimos y creamos saldo a favor
    let overpaymentAmount = 0;
    let effectivePaymentAmount = paymentAmount;

    if (paymentAmount > remainingAmount) {
      // Hay sobrepago
      overpaymentAmount = paymentAmount - remainingAmount;
      effectivePaymentAmount = remainingAmount;

      console.log(`💰 [Credits] Sobrepago detectado:
        - Saldo pendiente: $${remainingAmount}
        - Pago recibido: $${paymentAmount}
        - Exceso (saldo a favor): $${overpaymentAmount}`);
    }

    // Calcular el nuevo saldo pendiente después del pago efectivo
    const newRemainingBalance = remainingAmount - effectivePaymentAmount;

    // CRÍTICO: registrar el pago, la transacción y actualizar el crédito
    // deben ser una sola operación atómica (ver nota en addAmountToCredit
    // sobre transacciones "fantasma" si una escritura falla y las demás
    // ya se guardaron).
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Registrar el pago completo (incluyendo el sobrepago)
      const payment = queryRunner.manager.create(Payment, {
        ...createPaymentDto,
        creditId,
        createdBy: username,
      });
      await queryRunner.manager.save(Payment, payment);

      // Register transaction con el saldo después del pago
      const transaction = queryRunner.manager.create(CreditTransaction, {
        creditId: creditId,
        type: TransactionType.PAYMENT,
        amount: paymentAmount, // Registramos el monto total pagado
        description: createPaymentDto.description || 'Pago',
        paymentMethodId: createPaymentDto.paymentMethodId,
        createdBy: username,
        balanceAfter: newRemainingBalance, // Saldo pendiente después del pago
      });
      await queryRunner.manager.save(CreditTransaction, transaction);

      // Calculate total paid amount by summing all payments (dentro de la
      // misma transacción, para que vea el pago recién insertado)
      const result = await queryRunner.manager
        .createQueryBuilder(Payment, 'payment')
        .select('SUM(payment.amount)', 'total')
        .where('payment.creditId = :creditId', { creditId })
        .andWhere('payment.deleted_at IS NULL')
        .getRawOne();

      const newPaidAmount = parseFloat(result.total) || 0;
      const newStatus = newPaidAmount >= Number(credit.totalAmount) ? CreditStatus.PAID : credit.status;

      await queryRunner.manager.update(
        Credit,
        { id: creditId },
        {
          paidAmount: newPaidAmount,
          status: newStatus,
          updatedBy: username,
        },
      );

      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }

    // 💰 Si hay sobrepago, depositarlo como saldo a favor del cliente
    if (overpaymentAmount > 0) {
      try {
        console.log(`💰 [Credits] Creando saldo a favor de $${overpaymentAmount} para cliente ${credit.clientId}`);

        await this.clientBalanceService.depositBalance(
          credit.clientId,
          overpaymentAmount,
          `Sobrepago de crédito #${creditId.substring(0, 8)}... - Exceso de pago aplicado como saldo a favor`,
          username,
          creditId, // Relacionar con el crédito
        );

        console.log(`✅ [Credits] Saldo a favor creado exitosamente: $${overpaymentAmount} para cliente ${credit.clientId}`);
      } catch (balanceError) {
        console.error(`❌ [Credits] ERROR al crear saldo a favor:`, balanceError);
        console.error(`❌ [Credits] Cliente ID: ${credit.clientId}, Monto: ${overpaymentAmount}`);
        // No lanzar el error para que el pago se complete, pero registrar el problema
        // TODO: Implementar sistema de reintentos o notificaciones para saldos fallidos
      }
    }

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

    // CRÍTICO: borrar el pago y recalcular el total pagado del crédito
    // deben ser atómicos (misma razón que addAmountToCredit/addPayment).
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      payment.deletedBy = username;
      await queryRunner.manager.save(Payment, payment);
      await queryRunner.manager.softRemove(Payment, payment);

      // Calculate total paid amount by summing all remaining payments
      const result = await queryRunner.manager
        .createQueryBuilder(Payment, 'payment')
        .select('SUM(payment.amount)', 'total')
        .where('payment.creditId = :creditId', { creditId })
        .andWhere('payment.deleted_at IS NULL')
        .getRawOne();

      const newPaidAmount = parseFloat(result.total) || 0;

      await queryRunner.manager.update(
        Credit,
        { id: creditId },
        {
          paidAmount: newPaidAmount,
          status: CreditStatus.PENDING,
          updatedBy: username,
        },
      );

      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }

    return this.findOne(creditId);
  }

  /**
   * Verifica créditos pendientes sin pagos en los últimos X días
   * y crea notificaciones para administradores
   * @param daysThreshold - Número de días sin pago (default: 30)
   */
  async checkOverdueCredits(daysThreshold: number = 30): Promise<void> {
    const daysLabel = daysThreshold < 1 ? `${Math.round(daysThreshold * 24 * 60)} minutos` : `${daysThreshold} días`;
    console.log(`🔍 [Credits] Verificando créditos vencidos (${daysLabel}+ sin pago)...`);

    try {
      // Buscar todos los créditos pendientes
      const pendingCredits = await this.creditsRepository.find({
        where: { status: CreditStatus.PENDING },
        relations: ['client', 'payments'],
      });

      console.log(`📊 [Credits] Se encontraron ${pendingCredits.length} créditos pendientes`);

      // Fecha límite: hace X días
      const thresholdDate = new Date();
      thresholdDate.setTime(thresholdDate.getTime() - (daysThreshold * 24 * 60 * 60 * 1000));

      // Obtener todos los administradores
      const adminUsers = await this.usersRepository.find({
        where: { role: UserRole.ADMIN },
      });

      console.log(`👥 [Credits] Se encontraron ${adminUsers.length} administradores`);

      let notificationsCreated = 0;

      for (const credit of pendingCredits) {
        // Verificar si tiene pagos
        if (!credit.payments || credit.payments.length === 0) {
          // No tiene pagos: verificar si el crédito fue creado hace más de X días
          if (credit.createdAt < thresholdDate) {
            await this.createOverdueNotifications(credit, adminUsers);
            notificationsCreated++;
          }
        } else {
          // Tiene pagos: verificar fecha del último pago
          const lastPayment = credit.payments
            .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())[0];

          if (lastPayment.createdAt < thresholdDate) {
            await this.createOverdueNotifications(credit, adminUsers);
            notificationsCreated++;
          }
        }
      }

      console.log(`✅ [Credits] Verificación completada. ${notificationsCreated} notificaciones creadas`);
    } catch (error) {
      console.error('❌ [Credits] Error al verificar créditos vencidos:', error);
      throw error;
    }
  }

  /**
   * Crea notificaciones de crédito vencido para los administradores
   */
  private async createOverdueNotifications(credit: Credit, adminUsers: User[]): Promise<void> {
    console.log(`📢 [Credits] Creando notificaciones para crédito vencido: ${credit.id} (Cliente: ${credit.client.nombre})`);

    for (const admin of adminUsers) {
      // Verificar si ya existe una notificación no leída para este crédito y este admin
      const existingNotification = await this.notificationsRepository.findOne({
        where: {
          userId: admin.id,
          creditId: credit.id,
          type: NotificationType.CREDIT_OVERDUE_30_DAYS,
          isRead: false,
        },
      });

      // Si ya existe una notificación no leída, no crear otra
      if (existingNotification) {
        console.log(`ℹ️ [Credits] Ya existe notificación para admin ${admin.username} sobre crédito ${credit.id}`);
        continue;
      }

      // Calcular días sin pago
      let daysSinceLastActivity = 0;
      if (credit.payments && credit.payments.length > 0) {
        const lastPayment = credit.payments
          .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime())[0];
        daysSinceLastActivity = Math.floor(
          (new Date().getTime() - lastPayment.createdAt.getTime()) / (1000 * 60 * 60 * 24)
        );
      } else {
        daysSinceLastActivity = Math.floor(
          (new Date().getTime() - credit.createdAt.getTime()) / (1000 * 60 * 60 * 24)
        );
      }

      // Crear la notificación
      const notification = this.notificationsRepository.create({
        type: NotificationType.CREDIT_OVERDUE_30_DAYS,
        title: 'Crédito sin pagos por más de 30 días',
        message: `El cliente ${credit.client.nombre} no ha realizado pagos en ${daysSinceLastActivity} días. Saldo pendiente: $${credit.remainingAmount.toLocaleString('es-CO')}`,
        userId: admin.id,
        creditId: credit.id,
        isRead: false,
      });

      await this.notificationsRepository.save(notification);
      console.log(`✅ [Credits] Notificación creada para admin ${admin.username}`);
    }
  }
}