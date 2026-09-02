import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsNumber,
  IsBoolean,
  IsOptional,
  Min,
  MaxLength,
  ValidateIf,
} from 'class-validator';
import { PricingType } from '../entities/vegetable-item.entity';

export class CreateVegetableItemDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEnum(PricingType)
  pricingType: PricingType;

  @IsOptional()
  @IsString()
  categoryId?: string;

  // Requerido solo si pricingType = WEIGHT
  @ValidateIf((dto) => dto.pricingType === PricingType.WEIGHT)
  @IsNumber()
  @Min(0.01)
  pricePerKg?: number;

  // Requerido solo si pricingType = FIXED
  @ValidateIf((dto) => dto.pricingType === PricingType.FIXED)
  @IsNumber()
  @Min(0.01)
  fixedPrice?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  // Base64 (sin prefijo data:), ya comprimida en el cliente antes de subir.
  @IsOptional()
  @IsString()
  @MaxLength(2_000_000)
  image?: string;
}
