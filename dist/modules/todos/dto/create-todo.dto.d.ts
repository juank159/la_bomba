export declare class CreateTaskDto {
    description: string;
}
export declare class CreateTodoDto {
    description: string;
    assignedToId?: string;
    tasks?: CreateTaskDto[];
}
