import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsIn,
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  IsPositive,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { BrebChargeModule } from '../entities/breb-pending-charge.entity';

/**
 * `POST /breb/charge` — iniciar un cobro. `draft` es exactamente el cuerpo
 * que se mandaría a POST /vegetables/sales o POST /invoices (sin
 * `paymentMethodId`, que lo pone el backend): la venta se registra con eso
 * cuando el banco confirme el pago.
 */
export class CreateBrebChargeDto {
  @IsIn(['vegetables', 'invoices'])
  module: BrebChargeModule;

  @IsObject()
  draft: Record<string, any>;

  @IsNumber()
  @IsPositive()
  amount: number;
}

export class PreviewBrebQrDto {
  @IsString()
  @MinLength(20)
  template: string;

  @IsNumber()
  @IsPositive()
  amount: number;
}

export class AssignBrebPaymentDto {
  @IsUUID()
  chargeId: string;

  @IsUUID()
  emailId: string;
}

export class BrebLlaveDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(64)
  id: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(60)
  label: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  llave: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  qr_template?: string;

  @IsBoolean()
  show_in_invoices: boolean;

  @IsBoolean()
  show_in_vegetables: boolean;
}

export class UpdateBrebSettingsDto {
  @IsArray()
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => BrebLlaveDto)
  llaves: BrebLlaveDto[];
}
