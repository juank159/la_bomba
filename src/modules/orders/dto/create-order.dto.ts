import { IsString, IsNotEmpty, IsArray, ValidateNested, IsEnum, IsOptional, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';
import { MeasurementUnit } from '../entities/order-item.entity';

export class CreateOrderItemDto {
  @IsString()
  @IsNotEmpty()
  productId: string;

  @IsNumber()
  @IsNotEmpty()
  existingQuantity: number;

  @IsOptional()
  @IsNumber()
  requestedQuantity?: number;

  @IsOptional()
  @IsEnum(MeasurementUnit)
  measurementUnit?: MeasurementUnit;
}

export class CreateOrderDto {
  @IsString()
  @IsNotEmpty()
  description: string;

  @IsString()
  @IsOptional()
  provider?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items: CreateOrderItemDto[];
}