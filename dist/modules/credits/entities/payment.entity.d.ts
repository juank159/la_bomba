import { Credit } from './credit.entity';
export declare class Payment {
    id: string;
    credit: Credit;
    creditId: string;
    amount: number;
    description: string;
    createdBy: string;
    deletedBy: string;
    createdAt: Date;
    deletedAt?: Date;
}
