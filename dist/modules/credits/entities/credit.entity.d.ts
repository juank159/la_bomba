import { Payment } from './payment.entity';
import { Client } from '../../clients/entities/client.entity';
export declare enum CreditStatus {
    PENDING = "pending",
    PAID = "paid"
}
export declare class Credit {
    id: string;
    client: Client;
    clientId: string;
    description: string;
    totalAmount: number;
    paidAmount: number;
    status: CreditStatus;
    payments: Payment[];
    createdBy: string;
    updatedBy: string;
    deletedBy: string;
    createdAt: Date;
    updatedAt: Date;
    deletedAt?: Date;
    get remainingAmount(): number;
}
