import { BadRequestException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { PaymentMethod } from '../../modules/credits/entities/payment-method.entity';
import { BrebSaleInfo, BREB_PAYMENT_METHOD_CODE } from '../types/breb-sale-info';

export interface PaymentPart {
  paymentMethodId: string;
  amount: number;
}

const round2 = (v: number) => Math.round(v * 100) / 100;

/**
 * Valida el método de pago "del resto" en un pago parcial con Bre-B: tiene
 * que existir, estar activo y no ser Bre-B (el resto se cobra aparte, en
 * caja: efectivo o una transferencia normal).
 */
export async function findRestPaymentMethod(
  repo: Repository<PaymentMethod>,
  id: string | null | undefined,
  requireActive = true,
): Promise<PaymentMethod> {
  const pm = id ? await repo.findOne({ where: { id } }) : null;
  if (!pm || (requireActive && !pm.isActive)) {
    throw new BadRequestException('Elige con qué se paga el resto (efectivo u otra cuenta).');
  }
  if (pm.code === BREB_PAYMENT_METHOD_CODE) {
    throw new BadRequestException('El resto no puede ser Bre-B: cóbralo en efectivo u otra cuenta.');
  }
  return pm;
}

/**
 * Arma las partes del pago de una venta/factura:
 * - sin Bre-B: una sola parte, el método elegido, por el total;
 * - Bre-B total: una parte Bre-B por el total;
 * - Bre-B parcial: Bre-B por lo que pagó el cliente + el resto con el otro
 *   método. Las partes siempre suman exactamente el total.
 * `primary` es el método que se guarda en la venta (Bre-B cuando hubo
 * Bre-B, para que se identifique en listados).
 */
export async function buildPaymentParts(
  repo: Repository<PaymentMethod>,
  total: number,
  primary: PaymentMethod,
  breb?: BrebSaleInfo,
): Promise<PaymentPart[]> {
  const t = round2(total);
  if (!breb) return [{ paymentMethodId: primary.id, amount: t }];

  const brebPart = round2(Math.min(Number(breb.brebAmount ?? t), t));
  const rest = round2(t - brebPart);
  if (!breb.restPaymentMethodId || rest < 0.01) {
    return [{ paymentMethodId: primary.id, amount: t }];
  }
  // Al registrar (el cliente YA pagó) no se exige que siga activo: se
  // validó al crear el cobro y no se debe perder la venta por eso.
  const restPm = await findRestPaymentMethod(repo, breb.restPaymentMethodId, false);
  return [
    { paymentMethodId: primary.id, amount: brebPart },
    { paymentMethodId: restPm.id, amount: rest },
  ];
}
