import { IsNumber, IsPositive, IsOptional, IsString } from 'class-validator';

export class CreateCorresponsalEntryDto {
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;

  @IsOptional()
  @IsString()
  note?: string;
}
