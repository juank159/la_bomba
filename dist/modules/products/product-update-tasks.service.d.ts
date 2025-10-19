import { Repository } from 'typeorm';
import { ProductUpdateTask, ChangeType } from './entities/product-update-task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { CompleteTaskDto } from './dto/complete-task.dto';
export declare class ProductUpdateTasksService {
    private tasksRepository;
    constructor(tasksRepository: Repository<ProductUpdateTask>);
    create(createTaskDto: CreateTaskDto, createdById: string): Promise<ProductUpdateTask>;
    getPendingTasks(page?: number, limit?: number): Promise<ProductUpdateTask[]>;
    getCompletedTasks(page?: number, limit?: number): Promise<ProductUpdateTask[]>;
    getAllTasks(page?: number, limit?: number): Promise<ProductUpdateTask[]>;
    findOne(id: string): Promise<ProductUpdateTask>;
    completeTask(id: string, completeTaskDto: CompleteTaskDto, completedById: string): Promise<ProductUpdateTask>;
    getTasksCount(): Promise<{
        pending: number;
        completed: number;
        total: number;
    }>;
    createTaskForProductUpdate(productId: string, changeType: ChangeType, oldValue: any, newValue: any, createdById: string, description?: string): Promise<ProductUpdateTask>;
}
