import { IsNumber, IsString, IsUUID, Min, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UseBalanceDto {
  @ApiProperty({
    description: 'ID del cliente',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  clientId: string;

  @ApiProperty({
    description: 'Monto a usar del saldo',
    example: 50000,
    minimum: 0.01,
  })
  @IsNumber()
  @Min(0.01)
  amount: number;

  @ApiProperty({
    description: 'Descripción de la transacción',
    example: 'Saldo usado para pagar crédito #123',
  })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'ID del crédito relacionado (opcional)',
    example: '550e8400-e29b-41d4-a716-446655440001',
    required: false,
  })
  @IsOptional()
  @IsUUID()
  relatedCreditId?: string;

  @ApiProperty({
    description: 'ID del pedido relacionado (opcional)',
    example: '550e8400-e29b-41d4-a716-446655440002',
    required: false,
  })
  @IsOptional()
  @IsUUID()
  relatedOrderId?: string;
}
