// src/modules/credits/dto/update-payment-method.dto.ts

import { IsString, IsOptional, IsBoolean, MaxLength } from 'class-validator';

export class UpdatePaymentMethodDto {
  @IsString()
  @IsOptional()
  @MaxLength(100)
  name?: string;

  @IsString()
  @IsOptional()
  @MaxLength(255)
  description?: string;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  icon?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
