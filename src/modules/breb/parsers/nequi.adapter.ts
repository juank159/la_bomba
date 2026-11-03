import { BankAdapter, BankParseResult } from './bank-adapter.interface';

/**
 * Campos que aparecen en el correo "Venta exitosa" de Nequi, en cualquier
 * orden. Tienen que estar TODOS los que puede traer el correo real, aunque
 * no los usemos — si falta uno, el campo anterior "se come" todo el resto
 * del correo al extraerlo con regex (bug real que causó un 500 en
 * producción: "Referencia" se comió el link de seguimiento completo porque
 * "Número de transacción" no estaba en esta lista).
 */
const EMAIL_LABELS = [
  'Monto',
  'Estado',
  'Fecha',
  'Pagador',
  'Banco',
  'Referencia',
  'Número de transacción',
  'Método de pago',
];

function extract(text: string, label: string): string | undefined {
  const others = EMAIL_LABELS.filter((l) => l !== label).join('|');
  const re = new RegExp(`${label}:\\s*(.*?)(?=(?:${others}):|$)`, 'is');
  const m = text.match(re);
  return m ? m[1].trim() : undefined;
}

export const nequiAdapter: BankAdapter = {
  bankLabel: 'Nequi',

  matchesSender(fromHeader: string): boolean {
    return fromHeader.toLowerCase().includes('nequi.com.co');
  },

  matchesTemplate(bodyText: string): boolean {
    // Nequi manda varios TIPOS de correo desde el mismo remitente
    // (recargas, seguridad, promociones, rechazos, etc.), no solo ventas.
    // Si no dice literalmente "Venta exitosa" (frase fija de la plantilla
    // real de venta), no es lo que buscamos.
    return bodyText.toLowerCase().includes('venta exitosa');
  },

  parse(bodyText: string): BankParseResult {
    const rawAmount = extract(bodyText, 'Monto');
    const amount = rawAmount ? Number(rawAmount.replace(/[^\d]/g, '')) : undefined;
    const status = extract(bodyText, 'Estado');

    return {
      amount: amount && amount > 0 ? amount : undefined,
      payerName: extract(bodyText, 'Pagador'),
      reference: extract(bodyText, 'Referencia'),
      approved: (status ?? '').toLowerCase() === 'aprobada',
    };
  },
};
