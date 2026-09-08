import { IsString, IsNotEmpty, IsArray, ValidateNested, IsNumber, IsEnum, Min, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';
import { PurchaseFundingSource } from '../entities/vegetable-purchase.entity';

export class CreateVegetablePurchaseItemDto {
  // Solo productos ya existentes en el catálogo - a diferencia de los
  // pedidos (lista de reabastecimiento), una compra siempre es sobre algo
  // que ya se puede vender y llevar en inventario.
  @IsString()
  @IsNotEmpty()
  vegetableItemId: string;

  @IsNumber()
  @Min(0.001)
  quantity: number;

  @IsNumber()
  @Min(0)
  unitCost: number;
}

export class CreateVegetablePurchaseDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateVegetablePurchaseItemDto)
  items: CreateVegetablePurchaseItemDto[];

  // 'caja': se descuenta del turno de caja abierto (debe haber uno abierto).
  // 'external': dinero que no pasó por la caja del puesto.
  @IsEnum(PurchaseFundingSource)
  fundingSource: PurchaseFundingSource;
}
