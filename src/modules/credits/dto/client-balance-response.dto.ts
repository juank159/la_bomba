import { ApiProperty } from '@nestjs/swagger';

export class ClientBalanceTransactionResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  type: string;

  @ApiProperty()
  amount: number;

  @ApiProperty()
  description: string;

  @ApiProperty()
  balanceAfter: number;

  @ApiProperty({ required: false })
  relatedCreditId?: string;

  @ApiProperty({ required: false })
  relatedOrderId?: string;

  @ApiProperty()
  createdBy: string;

  @ApiProperty()
  createdAt: Date;
}

export class ClientBalanceResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  clientId: string;

  @ApiProperty()
  clientName: string;

  @ApiProperty()
  balance: number;

  @ApiProperty({ type: [ClientBalanceTransactionResponseDto] })
  transactions: ClientBalanceTransactionResponseDto[];

  @ApiProperty()
  createdBy: string;

  @ApiProperty({ required: false })
  updatedBy?: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
