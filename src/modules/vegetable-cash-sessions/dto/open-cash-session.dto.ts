import { IsNumber, Min, IsOptional, IsString } from 'class-validator';

export class OpenCashSessionDto {
  @IsNumber()
  @Min(0)
  openingAmount: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
