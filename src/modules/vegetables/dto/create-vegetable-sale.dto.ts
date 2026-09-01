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
}
