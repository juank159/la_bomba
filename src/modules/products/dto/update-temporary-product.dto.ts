import { IsString, IsOptional, IsNumber, IsBoolean, Min } from 'class-validator';

export class UpdateTemporaryProductDto {
  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  barcode?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsNumber()
  @Min(0)
  precioA?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  precioB?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  precioC?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  costo?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  iva?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
