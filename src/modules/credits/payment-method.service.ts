// src/modules/credits/payment-method.service.ts

import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PaymentMethod } from './entities/payment-method.entity';
import { CreatePaymentMethodDto } from './dto/create-payment-method.dto';
import { UpdatePaymentMethodDto } from './dto/update-payment-method.dto';

@Injectable()
export class PaymentMethodService {
  constructor(
    @InjectRepository(PaymentMethod)
    private readonly paymentMethodRepository: Repository<PaymentMethod>,
  ) {}

  /**
   * Obtener todos los métodos de pago
   */
  async findAll(includeInactive = false): Promise<PaymentMethod[]> {
    const query = this.paymentMethodRepository.createQueryBuilder('pm');

    if (!includeInactive) {
      query.where('pm.is_active = :isActive', { isActive: true });
    }

    return query.orderBy('pm.name', 'ASC').getMany();
  }

  /**
   * Obtener un método de pago por ID
   */
  async findOne(id: string): Promise<PaymentMethod> {
    const paymentMethod = await this.paymentMethodRepository.findOne({
      where: { id },
    });

    if (!paymentMethod) {
      throw new NotFoundException(`Payment method with ID ${id} not found`);
    }

    return paymentMethod;
  }

  /**
   * Crear un nuevo método de pago
   */
  async create(
    createPaymentMethodDto: CreatePaymentMethodDto,
    username: string,
  ): Promise<PaymentMethod> {
    // Verificar si ya existe un método con el mismo nombre
    const existing = await this.paymentMethodRepository.findOne({
      where: { name: createPaymentMethodDto.name },
    });

    if (existing) {
      throw new BadRequestException(
        `Payment method with name "${createPaymentMethodDto.name}" already exists`,
      );
    }

    const paymentMethod = this.paymentMethodRepository.create({
      ...createPaymentMethodDto,
      createdBy: username,
    });

    return this.paymentMethodRepository.save(paymentMethod);
  }

  /**
   * Actualizar un método de pago
   */
  async update(
    id: string,
    updatePaymentMethodDto: UpdatePaymentMethodDto,
    username: string,
  ): Promise<PaymentMethod> {
    const paymentMethod = await this.findOne(id);

    // Si se está actualizando el nombre, verificar que no exista otro con ese nombre
    if (
      updatePaymentMethodDto.name &&
      updatePaymentMethodDto.name !== paymentMethod.name
    ) {
      const existing = await this.paymentMethodRepository.findOne({
        where: { name: updatePaymentMethodDto.name },
      });

      if (existing) {
        throw new BadRequestException(
          `Payment method with name "${updatePaymentMethodDto.name}" already exists`,
        );
      }
    }

    Object.assign(paymentMethod, updatePaymentMethodDto);
    paymentMethod.updatedBy = username;

    return this.paymentMethodRepository.save(paymentMethod);
  }

  /**
   * Eliminar (desactivar) un método de pago
   */
  async remove(id: string, username: string): Promise<void> {
    const paymentMethod = await this.findOne(id);

    // No eliminar físicamente, solo desactivar
    paymentMethod.isActive = false;
    paymentMethod.updatedBy = username;

    await this.paymentMethodRepository.save(paymentMethod);
  }

  /**
   * Reactivar un método de pago
   */
  async activate(id: string, username: string): Promise<PaymentMethod> {
    const paymentMethod = await this.findOne(id);

    paymentMethod.isActive = true;
    paymentMethod.updatedBy = username;

    return this.paymentMethodRepository.save(paymentMethod);
  }
}
