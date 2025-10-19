import { Todo } from './todo.entity';
export declare class Task {
    id: string;
    description: string;
    isCompleted: boolean;
    todo: Todo;
    todoId: string;
    createdAt: Date;
    updatedAt: Date;
}
