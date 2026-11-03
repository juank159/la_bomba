import { BankAdapter, BankParseResult } from './bank-adapter.interface';

/**
 * Bancolombia NO manda ninguna referencia/comprobante único en este
 * correo (a diferencia de Nequi) — es una sola oración en lenguaje
 * natural, sin campos estructurados. Y, a diferencia de Nequi, el
 * formato exacto de esa oración YA CAMBIÓ una vez en producción sin
 * aviso — por eso acá se prueban VARIAS plantillas en orden en vez de
 * una sola, y `matchesTemplate` reconoce las frases de todas.
 *
 * Plantilla vieja (transferencia normal, sin mención de llave Bre-B):
 *   "Bancolombia: Recibiste una transferencia por $1,000 de ELIAN
 *    URBINA en tu cuenta **4273, el 28/08/2026 a las 13:29."
 *
 * Plantilla nueva (pago vía llave Bre-B — la que Bancolombia manda
 * ahora para pagos a una llave registrada):
 *   "Bancolombia: ALTOSTIERRA123, recibiste un pago de JUAN CARLOS
 *    PABON PAEZ por $1,000.00 en tu cuenta *4273 conectado a la
 *    llave @altostierra123 el 11/09/2026 a las 17:37. Con llaves es
 *    desde una y gratis. Dudas al 018000912345."
 *
 * Diferencias clave entre ambas (todo lo que rompía el regex viejo):
 *   - Orden invertido: "un pago de NOMBRE por $X" en vez de
 *     "una transferencia por $X de NOMBRE".
 *   - Un solo asterisco antes del número de cuenta ("*4273"), no dos
 *     ("**4273").
 *   - Ya no hay coma antes de "el DD/MM/YYYY" — y ahora hay texto
 *     extra en el medio ("conectado a la llave @xxx") que la vieja
 *     no contemplaba.
 *   - Trae la llave Bre-B que recibió el pago — dato nuevo, útil para
 *     desambiguar cuando el tenant tiene varias llaves registradas.
 */
const NEW_TEMPLATE_REGEX =
  /recibiste un pago de\s+(?<payerName>.+?)\s+por\s*\$\s?(?<amount>[\d.,]+)\s+en tu cuenta\s+\*+(?<accountLast4>\d+)(?:\s+conectado a la llave\s+(?<llave>@\w(?:[\w.-]*\w)?))?(?:.*?el\s+(?<date>\d{2}\/\d{2}\/\d{4})\s+a las\s+(?<time>\d{2}:\d{2}))?/is;

const OLD_TEMPLATE_REGEX =
  /recibiste una transferencia por\s*\$\s?(?<amount>[\d.,]+)\s+de\s+(?<payerName>.+?)\s+en tu cuenta\s+\*{2}(?<accountLast4>\d+)(?:,?\s*el\s+(?<date>\d{2}\/\d{2}\/\d{4})\s+a las\s+(?<time>\d{2}:\d{2}))?/is;

/**
 * "$1,000.00" (coma = separador de miles, punto = decimales — el correo
 * nuevo SÍ manda centavos, aunque siempre sean ".00") se rompía con un
 * `replace(/[^\d]/g, '')` ingenuo: se comía el punto decimal también y
 * convertía "1,000.00" en 100000 (¡100 veces el monto real!). Bancolombia
 * nunca maneja centavos reales en pesos colombianos, así que basta con
 * quitar las comas de miles y truncar cualquier decimal.
 */
function parseColombianAmount(raw: string): number {
  const withoutThousandsSeparators = raw.replace(/,/g, '');
  return Math.round(Number(withoutThousandsSeparators));
}

export const bancolombiaAdapter: BankAdapter = {
  bankLabel: 'Bancolombia',

  matchesSender(fromHeader: string): boolean {
    return fromHeader.toLowerCase().includes('notificacionesbancolombia.com');
  },

  matchesTemplate(bodyText: string): boolean {
    const text = bodyText.toLowerCase();
    return (
      text.includes('recibiste una transferencia') ||
      text.includes('recibiste un pago')
    );
  },

  parse(bodyText: string): BankParseResult {
    const match =
      bodyText.match(NEW_TEMPLATE_REGEX) ?? bodyText.match(OLD_TEMPLATE_REGEX);
    if (!match?.groups) return { approved: false };

    const { payerName, amount: rawAmount, accountLast4, llave, date, time } =
      match.groups;
    const amount = parseColombianAmount(rawAmount);

    // Referencia sintética: no es tan fuerte como un comprobante real de
    // banco, pero es lo más específico disponible (monto + quién +
    // cuenta + minuto exacto) para evitar procesar el mismo correo dos
    // veces si Mailgun llegara a reintentar la entrega.
    const syntheticReference = [
      'bancolombia',
      amount,
      payerName.trim().toLowerCase(),
      accountLast4,
      date ?? '',
      time ?? '',
    ].join(':');

    return {
      amount: amount > 0 ? amount : undefined,
      payerName: payerName.trim(),
      reference: syntheticReference,
      syntheticReference: true,
      llave: llave?.toLowerCase(),
      approved: true, // este correo solo se manda para transferencias ya recibidas
    };
  },
};
