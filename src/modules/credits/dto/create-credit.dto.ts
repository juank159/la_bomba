import { IsString, IsNotEmpty, IsNumber, IsPositive, IsUUID, IsBoolean, IsOptional } from 'class-validator';

export class CreateCreditDto {
  @IsUUID()
  @IsNotEmpty()
  clientId: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  totalAmount: number;

  @IsBoolean()
  @IsOptional()
  useClientBalance?: boolean;
}