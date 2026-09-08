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
  // Uno de los dos debe venir: vegetableItemId (producto del catálogo) o
  // description+amount (venta libre, sin producto asociado) - se valida en
  // el service, mismo patrón que CreateVegetableOrderItemDto.
  @IsOptional()
  @IsString()
  vegetableItemId?: string;

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

  // Total de la línea ya calculado por el cliente (ej. redondeado al
  // umbral configurado) para productos por peso - si viene, reemplaza el
  // unitPrice*weightKg que el service calcularía. Sin esto, comportamiento
  // igual al de siempre.
  @IsOptional()
  @IsNumber()
  @Min(0)
  lineTotal?: number;

  // Venta libre: descripción y monto libres, sin producto de catálogo.
  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.01)
  amount?: number;
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
