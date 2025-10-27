import { IsNumber, IsString, IsUUID, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefundBalanceDto {
  @ApiProperty({
    description: 'ID del cliente',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  @IsUUID()
  clientId: string;

  @ApiProperty({
    description: 'Monto a devolver al cliente',
    example: 25000,
    minimum: 0.01,
  })
  @IsNumber()
  @Min(0.01)
  amount: number;

  @ApiProperty({
    description: 'Descripción de la devolución',
    example: 'Devolución de saldo a petición del cliente',
  })
  @IsString()
  description: string;
}
