/**
 * Datos del pago Bre-B confirmado que se adjuntan a la venta/factura que
 * registra BrebService. `expectedTotal` es el total que se le cobró al
 * cliente: si al recalcular la venta da otro valor (cambió un precio entre
 * que se creó el cobro y llegó el pago) se rechaza en vez de registrar algo
 * distinto a lo cobrado.
 */
export interface BrebSaleInfo {
  chargeId: string;
  payerName: string | null;
  bankLabel: string | null;
  llave: string | null;
  reference: string | null;
  amountReceived: number;
  expectedTotal: number;
}

export const BREB_PAYMENT_METHOD_CODE = 'breb';
