import { User } from '../../users/entities/user.entity';
import { Task } from './task.entity';
export declare class Todo {
    id: string;
    description: string;
    isCompleted: boolean;
    createdBy: User;
    createdById: string;
    assignedTo: User;
    assignedToId: string;
    tasks: Task[];
    createdAt: Date;
    updatedAt: Date;
}
