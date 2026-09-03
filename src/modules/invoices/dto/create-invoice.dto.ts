import { IsString, IsNotEmpty, IsArray, ValidateNested, IsOptional, IsNumber, Min, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateInvoiceItemDto {
  @IsString()
  @IsNotEmpty()
  productId: string;

  @IsNumber()
  @Min(1)
  quantity: number;

  // Precio unitario elegido en el cliente (precioA, precioB o precioC del
  // producto). Opcional: si no se envía, se usa precioA. El service SIEMPRE
  // valida que coincida con uno de los precios reales del producto antes de
  // usarlo - nunca se confía en un monto arbitrario venido del cliente.
  @IsOptional()
  @IsNumber()
  @Min(0)
  unitPrice?: number;
}

export class CreateInvoiceDto {
  @IsOptional()
  @IsString()
  clientId?: string;

  @IsString()
  @IsNotEmpty()
  paymentMethodId: string;

  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateInvoiceItemDto)
  items: CreateInvoiceItemDto[];
}
