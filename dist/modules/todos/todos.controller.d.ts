import { TodosService } from './todos.service';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
export declare class TodosController {
    private readonly todosService;
    constructor(todosService: TodosService);
    create(createTodoDto: CreateTodoDto, req: any): Promise<import("./entities/todo.entity").Todo>;
    findAll(req: any): Promise<import("./entities/todo.entity").Todo[]>;
    findOne(id: string): Promise<import("./entities/todo.entity").Todo>;
    update(id: string, updateTodoDto: UpdateTodoDto, req: any): Promise<import("./entities/todo.entity").Todo>;
    updateTask(todoId: string, taskId: string, updateTaskDto: UpdateTaskDto, req: any): Promise<import("./entities/task.entity").Task>;
    remove(id: string, req: any): Promise<void>;
}
