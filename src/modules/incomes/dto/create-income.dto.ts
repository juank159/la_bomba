import { IsString, IsNotEmpty, IsNumber, IsPositive } from 'class-validator';

export class CreateIncomeDto {
  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;
}
