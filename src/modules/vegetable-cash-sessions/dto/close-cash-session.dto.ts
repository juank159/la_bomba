import { IsNumber, Min, IsOptional, IsString } from 'class-validator';

export class CloseCashSessionDto {
  // Conteo físico real del efectivo en caja al momento de cerrar.
  @IsNumber()
  @Min(0)
  closingAmount: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
