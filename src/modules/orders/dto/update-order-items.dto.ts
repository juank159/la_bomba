import { IsNotEmpty, IsNumber, IsString } from 'class-validator';

export class UpdateOrderItemsDto {
  @IsString()
  @IsNotEmpty()
  itemId: string;

  @IsNumber()
  @IsNotEmpty()
  requestedQuantity: number;
}