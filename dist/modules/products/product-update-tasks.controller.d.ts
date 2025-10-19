import { ProductUpdateTasksService } from './product-update-tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { CompleteTaskDto } from './dto/complete-task.dto';
export declare class ProductUpdateTasksController {
    private readonly tasksService;
    constructor(tasksService: ProductUpdateTasksService);
    create(createTaskDto: CreateTaskDto, req: any): Promise<import("./entities/product-update-task.entity").ProductUpdateTask>;
    getPendingTasks(page?: number, limit?: number): Promise<import("./entities/product-update-task.entity").ProductUpdateTask[]>;
    getCompletedTasks(page?: number, limit?: number): Promise<import("./entities/product-update-task.entity").ProductUpdateTask[]>;
    getTasksStats(): Promise<{
        pending: number;
        completed: number;
        total: number;
    }>;
    getAllTasks(page?: number, limit?: number): Promise<import("./entities/product-update-task.entity").ProductUpdateTask[]>;
    findOne(id: string): Promise<import("./entities/product-update-task.entity").ProductUpdateTask>;
    completeTask(id: string, completeTaskDto: CompleteTaskDto, req: any): Promise<import("./entities/product-update-task.entity").ProductUpdateTask>;
}
