import { Credit } from './credit.entity';
export declare enum TransactionType {
    DEBT_INCREASE = "debt_increase",
    PAYMENT = "payment"
}
export declare class CreditTransaction {
    id: string;
    credit: Credit;
    creditId: string;
    type: TransactionType;
    amount: number;
    description: string;
    createdBy: string;
    createdAt: Date;
}
