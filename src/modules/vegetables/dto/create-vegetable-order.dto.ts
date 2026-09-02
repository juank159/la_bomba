import {
  IsString,
  IsOptional,
  IsArray,
  ValidateNested,
  IsNumber,
  IsEnum,
  Min,
  ArrayMinSize,
} from 'class-validator';
import { Type } from 'class-transformer';
import { VegetableOrderUnit } from '../entities/vegetable-order-item.entity';

export class CreateVegetableOrderItemDto {
  // Uno de los dos debe venir: vegetableItemId (producto del catálogo) o
  // description (producto ocasional escrito a mano) - se valida en el service.
  @IsOptional()
  @IsString()
  vegetableItemId?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNumber()
  @Min(0.001)
  quantity: number;

  @IsEnum(VegetableOrderUnit)
  unit: VegetableOrderUnit;
}

export class CreateVegetableOrderDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateVegetableOrderItemDto)
  items: CreateVegetableOrderItemDto[];
}
