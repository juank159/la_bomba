import { IsString, IsNotEmpty, IsNumber, IsPositive, IsEnum } from 'class-validator';
import { ExpenseFundingSource } from '../entities/vegetable-expense.entity';

export class CreateVegetableExpenseDto {
  @IsString()
  @IsNotEmpty()
  description: string;

  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  amount: number;

  // 'caja': se descuenta del turno de caja abierto (debe haber uno abierto).
  // 'external': dinero que no pasó por la caja del puesto.
  @IsEnum(ExpenseFundingSource)
  fundingSource: ExpenseFundingSource;
}
