// src/modules/credits/payment-method.controller.ts

import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { PaymentMethodService } from './payment-method.service';
import { CreatePaymentMethodDto } from './dto/create-payment-method.dto';
import { UpdatePaymentMethodDto } from './dto/update-payment-method.dto';

@Controller('payment-methods')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PaymentMethodController {
  constructor(private readonly paymentMethodService: PaymentMethodService) {}

  @Get()
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR)
  async findAll(@Query('includeInactive') includeInactive?: string) {
    return this.paymentMethodService.findAll(includeInactive === 'true');
  }

  @Get(':id')
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR)
  async findOne(@Param('id') id: string) {
    return this.paymentMethodService.findOne(id);
  }

  @Post()
  @Roles(UserRole.ADMIN)
  async create(@Body() createPaymentMethodDto: CreatePaymentMethodDto, @Request() req) {
    return this.paymentMethodService.create(createPaymentMethodDto, req.user.username);
  }

  @Put(':id')
  @Roles(UserRole.ADMIN)
  async update(
    @Param('id') id: string,
    @Body() updatePaymentMethodDto: UpdatePaymentMethodDto,
    @Request() req,
  ) {
    return this.paymentMethodService.update(id, updatePaymentMethodDto, req.user.username);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  async remove(@Param('id') id: string, @Request() req) {
    await this.paymentMethodService.remove(id, req.user.username);
    return { message: 'Payment method deactivated successfully' };
  }

  @Put(':id/activate')
  @Roles(UserRole.ADMIN)
  async activate(@Param('id') id: string, @Request() req) {
    return this.paymentMethodService.activate(id, req.user.username);
  }
}
