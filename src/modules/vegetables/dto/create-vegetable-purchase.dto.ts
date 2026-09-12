import { IsString, IsNotEmpty, IsArray, ValidateNested, IsNumber, IsEnum, IsOptional, Min, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';
import { PurchaseFundingSource } from '../entities/vegetable-purchase.entity';

export class CreateVegetablePurchaseItemDto {
  // Uno de los dos debe venir: vegetableItemId+quantity+unitCost (producto
  // del catálogo, afecta inventario) o description+amount (compra libre,
  // sin producto asociado ni efecto en inventario) - mismo patrón que
  // CreateVegetableSaleItemDto, se valida en el service.
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

  // Compra libre: descripción y monto total de la línea, sin producto de
  // catálogo ni cantidad/costo unitario.
  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  @Min(0.01)
  amount?: number;
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
