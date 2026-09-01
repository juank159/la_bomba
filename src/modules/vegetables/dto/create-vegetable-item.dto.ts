import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsNumber,
  IsBoolean,
  IsOptional,
  Min,
  ValidateIf,
} from 'class-validator';
import { PricingType } from '../entities/vegetable-item.entity';

export class CreateVegetableItemDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEnum(PricingType)
  pricingType: PricingType;

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
}
