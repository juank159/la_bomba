import { IsString, IsNotEmpty, IsArray, ValidateNested, IsNumber, Min, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateVegetablePurchaseItemDto {
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

// A propósito, editar una compra NO permite cambiar fundingSource/a qué
// turno de caja queda ligada - eso movería plata entre cuadres de caja
// distintos, un caso mucho más delicado que "corregir un valor mal
// digitado" (el pedido original). Si hace falta más adelante, es un
// cambio aparte.
export class UpdateVegetablePurchaseDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => UpdateVegetablePurchaseItemDto)
  items: UpdateVegetablePurchaseItemDto[];
}
