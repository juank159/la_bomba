import {
  IsString,
  IsNotEmpty,
  IsArray,
  ValidateNested,
  IsNumber,
  IsOptional,
  Min,
  ArrayMinSize,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateVegetableSaleItemDto {
  @IsString()
  @IsNotEmpty()
  vegetableItemId: string;

  // Peso en kg (para items que se venden por peso, viene de la báscula o se
  // ingresa manualmente). Uno de weightKg o quantity debe venir, según el
  // tipo de precio del producto.
  @IsOptional()
  @IsNumber()
  @Min(0.001)
  weightKg?: number;

  // Unidades (para items de precio fijo)
  @IsOptional()
  @IsNumber()
  @Min(1)
  quantity?: number;
}

export class CreateVegetableSaleDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateVegetableSaleItemDto)
  items: CreateVegetableSaleItemDto[];

  // Cómo pagó el cliente: efectivo o un método de transferencia (Nequi,
  // Bancolombia, etc.) - de la misma tabla payment_methods que usa
  // Facturación.
  @IsString()
  @IsNotEmpty()
  paymentMethodId: string;
}
