import { IsString, IsNotEmpty, IsNumber, IsPositive } from 'class-validator';

export class CreateVegetableExpenseDto {
  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;
}
