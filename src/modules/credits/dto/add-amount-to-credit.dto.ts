import { IsNumber, IsString, IsNotEmpty, Min } from 'class-validator';

export class AddAmountToCreditDto {
  @IsNumber()
  @Min(0.01)
  @IsNotEmpty()
  amount: number;

  @IsString()
  @IsNotEmpty()
  description: string;
}
