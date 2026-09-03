import { IsString, IsNotEmpty, IsArray, ValidateNested, IsNumber, Min, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';

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
}
