import { IsString, IsNotEmpty, IsNumber, IsPositive, IsOptional, IsUUID } from 'class-validator';

export class CreatePaymentDto {
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;

  @IsString()
  @IsOptional()
  description?: string;

  @IsUUID()
  @IsOptional()
  paymentMethodId?: string;
}