import { BankAdapter } from './bank-adapter.interface';
import { nequiAdapter } from './nequi.adapter';
import { bancolombiaAdapter } from './bancolombia.adapter';

export { BankAdapter, BankParseResult } from './bank-adapter.interface';

/** Agregar un banco nuevo = agregar un adaptador acá, nada más. */
export const BANK_ADAPTERS: BankAdapter[] = [nequiAdapter, bancolombiaAdapter];

export function findBankAdapter(fromHeader: string): BankAdapter | undefined {
  return BANK_ADAPTERS.find((a) => a.matchesSender(fromHeader));
}
