import { IsEnum, IsOptional, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { OrderStatus } from '../entities/order.entity';
import { CreateOrderItemDto } from './create-order.dto';

export class UpdateOrderDto {
  @IsOptional()
  description?: string;

  // IMPORTANT: provider can be null to indicate a mixed order
  // (where each product has its own supplier assigned)
  @IsOptional()
  provider?: string | null;

  @IsEnum(OrderStatus)
  @IsOptional()
  status?: OrderStatus;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  @IsOptional()
  items?: CreateOrderItemDto[];
}