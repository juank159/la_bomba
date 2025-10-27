import { IsNumber, IsString, IsUUID } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class AdjustBalanceDto {
  @ApiProperty({
    description: 'ID del cliente',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  clientId: string;

  @ApiProperty({
    description: 'Monto del ajuste (positivo para agregar, negativo para reducir)',
    example: -5000,
  })
  @IsNumber()
  amount: number;

  @ApiProperty({
    description: 'Razón del ajuste',
    example: 'Corrección por error en registro anterior',
  })
  @IsString()
  description: string;
}
