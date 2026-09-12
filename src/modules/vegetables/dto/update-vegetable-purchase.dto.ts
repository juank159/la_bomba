import { IsString, IsNotEmpty, IsArray, ValidateNested, IsNumber, IsOptional, Min, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateVegetablePurchaseItemDto {
  // Mismo patrón que CreateVegetablePurchaseItemDto: catálogo
  // (vegetableItemId+quantity+unitCost) o compra libre (description+amount).
  @IsOptional()
  @IsString()
  vegetableItemId?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.001)
  quantity?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  unitCost?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.01)
  amount?: number;
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
