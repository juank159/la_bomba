/**
 * EMV QR Code (Merchant Presented Mode) — utilidades para tomar una
 * plantilla de QR Bre-B tal cual la genera el banco (Nequi, Bancolombia,
 * vía switch RBM) y devolver una copia con el monto actualizado.
 *
 * Formato: una cadena de campos TLV (tag de 2 dígitos + largo de 2
 * dígitos + valor), en orden, terminada siempre en el tag 63 (checksum
 * CRC16). El tag 54 es el "Transaction Amount" — cuando está presente,
 * se reemplaza en el lugar; cuando no está (algunos QR de Bancolombia
 * vienen sin monto fijo), se inserta justo después del tag 53
 * ("Transaction Currency"), que es su posición estándar del spec — se
 * puede confirmar comparando cualquier QR Bre-B que sí traiga monto:
 * el 54 siempre queda pegado al 53.
 *
 * Nunca se reordena ni se toca ningún otro campo — la única garantía
 * que necesitamos es "el monto que dice el QR es el correcto" y "el
 * checksum es válido"; cualquier otro campo (llave, nombre, ciudad,
 * TRXID, firma) se preserva byte a byte tal cual vino del banco.
 */

export class InvalidEmvQrTemplateError extends Error {}

interface TlvSegment {
  tag: string;
  length: number;
  value: string;
  start: number;
  end: number;
}

/** Recorre los campos de NIVEL SUPERIOR del payload (no baja a los
 *  sub-campos anidados de templates como el 26/62/90/91 — no hace
 *  falta para lo que necesitamos: solo tocamos 53/54/63). */
function walkTopLevelTlv(raw: string): TlvSegment[] {
  const segments: TlvSegment[] = [];
  let i = 0;
  while (i + 4 <= raw.length) {
    const tag = raw.substring(i, i + 2);
    const lenStr = raw.substring(i + 2, i + 4);
    if (!/^\d{2}$/.test(lenStr)) break; // payload corrupto — cortamos acá
    const length = parseInt(lenStr, 10);
    const valueStart = i + 4;
    const valueEnd = valueStart + length;
    if (valueEnd > raw.length) break;
    segments.push({
      tag,
      length,
      value: raw.substring(valueStart, valueEnd),
      start: i,
      end: valueEnd,
    });
    i = valueEnd;
  }
  return segments;
}

/** CRC16-CCITT (poly 0x1021, init 0xFFFF) — el algoritmo que exige el
 *  spec EMVCo para el tag 63. */
function crc16ccitt(data: string): number {
  let crc = 0xffff;
  for (let i = 0; i < data.length; i++) {
    crc ^= data.charCodeAt(i) << 8;
    for (let bit = 0; bit < 8; bit++) {
      crc = (crc & 0x8000) !== 0 ? ((crc << 1) ^ 0x1021) & 0xffff : (crc << 1) & 0xffff;
    }
  }
  return crc & 0xffff;
}

/**
 * Devuelve una copia de `template` con el monto (tag 54) puesto en
 * `amount`, y el checksum (tag 63) recalculado. Si la plantilla ya
 * traía un monto, se reemplaza en el lugar; si no, se inserta después
 * del tag 53 (moneda).
 *
 * Lanza `InvalidEmvQrTemplateError` si la plantilla no es un QR EMV
 * válido (sin tag 53 para ubicar dónde insertar, o sin tag 63) — mejor
 * fallar temprano con un mensaje claro que generar un QR que el banco
 * del cliente va a rechazar.
 */
export function buildDynamicQrPayload(template: string, amount: number): string {
  const trimmed = template.trim();
  const segments = walkTopLevelTlv(trimmed);

  if (!segments.find((s) => s.tag === '63')) {
    throw new InvalidEmvQrTemplateError(
      'La plantilla no parece un QR Bre-B válido (falta el checksum, tag 63).',
    );
  }

  const amountValue = amount.toFixed(2);
  const newAmountSegment = `54${amountValue.length.toString().padStart(2, '0')}${amountValue}`;

  const existingAmount = segments.find((s) => s.tag === '54');
  let withAmount: string;
  if (existingAmount) {
    withAmount =
      trimmed.slice(0, existingAmount.start) +
      newAmountSegment +
      trimmed.slice(existingAmount.end);
  } else {
    const currency = segments.find((s) => s.tag === '53');
    if (!currency) {
      throw new InvalidEmvQrTemplateError(
        'La plantilla no tiene el campo de moneda (tag 53) — no se sabe dónde insertar el monto.',
      );
    }
    withAmount = trimmed.slice(0, currency.end) + newAmountSegment + trimmed.slice(currency.end);
  }

  // El checksum cubre TODO el payload hasta e incluyendo "6304" (tag +
  // largo del propio campo CRC) — nunca el valor del CRC en sí. Como el
  // monto puede haber cambiado de longitud, ubicamos el marcador en el
  // string YA reconstruido (el CRC es siempre el último campo del
  // payload, así que la última ocurrencia es la real).
  const marker = '6304';
  const markerIndex = withAmount.lastIndexOf(marker);
  if (markerIndex === -1) {
    throw new InvalidEmvQrTemplateError(
      'No se pudo ubicar el campo de checksum tras actualizar el monto.',
    );
  }
  const payloadForCrc = withAmount.slice(0, markerIndex + marker.length);
  const crc = crc16ccitt(payloadForCrc).toString(16).toUpperCase().padStart(4, '0');
  return payloadForCrc + crc;
}
