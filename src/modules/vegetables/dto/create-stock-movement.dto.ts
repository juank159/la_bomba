import { IsEnum, IsNumber, IsNotEmpty, IsString, ValidateIf, NotEquals } from 'class-validator';

// Solo estos tres son creables desde afuera - SALE lo genera el propio
// service al registrar una venta, nunca llega por este DTO.
export enum CreatableStockMovementType {
  IN = 'in',
  MERMA = 'merma',
  ADJUSTMENT = 'adjustment',
}

export class CreateStockMovementDto {
  @IsEnum(CreatableStockMovementType)
  type: CreatableStockMovementType;

  // IN y MERMA: magnitud positiva (el service decide el signo según type).
  // ADJUSTMENT: delta con signo, puede ser positivo o negativo, pero no 0.
  @IsNumber()
  @NotEquals(0)
  quantity: number;

  // Obligatorio para MERMA (por qué se dio de baja); para el resto no se
  // valida en absoluto (ValidateIf en false = se salta todo lo de abajo).
  @ValidateIf((dto: CreateStockMovementDto) => dto.type === CreatableStockMovementType.MERMA)
  @IsString()
  @IsNotEmpty({ message: 'La razón es obligatoria para registrar una merma' })
  reason?: string;
}
