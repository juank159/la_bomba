/**
 * Datos del pago Bre-B confirmado que se adjuntan a la venta/factura que
 * registra BrebService. `expectedTotal` es el total de la venta: si al
 * recalcularla da otro valor (cambió un precio entre que se creó el cobro y
 * llegó el pago) se rechaza en vez de registrar algo distinto a lo cobrado.
 *
 * Pago parcial: si el cliente paga solo una parte por Bre-B (ej. $20.000 de
 * una cuenta de $50.000), `brebAmount` es esa parte y el resto se registra
 * con `restPaymentMethodId` (efectivo, otra transferencia...). Sin
 * `restPaymentMethodId`, todo el total es Bre-B.
 */
export interface BrebSaleInfo {
  chargeId: string;
  payerName: string | null;
  bankLabel: string | null;
  llave: string | null;
  reference: string | null;
  amountReceived: number;
  expectedTotal: number;
  brebAmount?: number | null;
  restPaymentMethodId?: string | null;
}

export const BREB_PAYMENT_METHOD_CODE = 'breb';
