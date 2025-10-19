import { User } from '../../users/entities/user.entity';
export declare class Expense {
    id: string;
    description: string;
    amount: number;
    createdBy: User;
    createdById: string;
    createdAt: Date;
    updatedAt: Date;
}
