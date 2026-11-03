/** Resultado de parsear un correo de confirmación de pago de un banco. */
export interface BankParseResult {
  amount?: number;
  payerName?: string;
  /**
   * Referencia/comprobante único que da el banco (ej. "M15752366" de
   * Nequi). Si el banco no da ninguna (ej. Bancolombia), queda undefined
   * y el caller arma una sintética con lo que sí haya disponible.
   */
  reference?: string;
  /**
   * La referencia la armamos nosotros (el banco no da comprobante). Dos
   * pagos reales iguales (mismo pagador, monto y minuto) generan la MISMA
   * referencia: el servicio le suma el Message-Id del correo para no
   * descartar el segundo como "repetido".
   */
  syntheticReference?: boolean;
  /**
   * Llave Bre-B a la que llegó la plata, si el correo la menciona (ej.
   * "@altostierra123" en el correo nuevo de Bancolombia). Nequi no la
   * incluye. Sirve para desambiguar cuando el tenant tiene registradas
   * varias llaves — ver `BrebPendingCharge.llave` / matching en
   * `BrebService`.
   */
  llave?: string;
  /** true si el correo representa una transacción exitosa/confirmada. */
  approved: boolean;
}

/**
 * Un "adaptador" por banco: sabe reconocer sus propios correos y
 * extraer los datos de un pago recibido. Cada banco tiene un formato de
 * correo completamente distinto (Nequi es una lista de campos fijos;
 * Bancolombia es una sola oración en lenguaje natural) — por eso esto
 * está separado en vez de un único parser gigante con ifs.
 */
export interface BankAdapter {
  /** Nombre para mostrar/hablar — "Nequi", "Bancolombia". */
  readonly bankLabel: string;

  /** true si el header `From` corresponde a este banco. */
  matchesSender(fromHeader: string): boolean;

  /**
   * true si el cuerpo del correo tiene la plantilla de "pago recibido"
   * de este banco — filtro extra para no confundir otros tipos de aviso
   * del mismo remitente (promociones, seguridad, etc.) con una venta real.
   */
  matchesTemplate(bodyText: string): boolean;

  /** Extrae monto/pagador/referencia del cuerpo. Ya se confirmó el template antes de llamar esto. */
  parse(bodyText: string): BankParseResult;
}
