import { Repository } from 'typeorm';
import { Todo } from './entities/todo.entity';
import { Task } from './entities/task.entity';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { UserRole } from '../users/entities/user.entity';
export declare class TodosService {
    private todosRepository;
    private tasksRepository;
    constructor(todosRepository: Repository<Todo>, tasksRepository: Repository<Task>);
    create(createTodoDto: CreateTodoDto, userId: string, userRole: UserRole): Promise<Todo>;
    findAll(userId: string, userRole: UserRole): Promise<Todo[]>;
    findOne(id: string): Promise<Todo>;
    update(id: string, updateTodoDto: UpdateTodoDto, userId: string, userRole: UserRole): Promise<Todo>;
    updateTask(todoId: string, taskId: string, updateTaskDto: UpdateTaskDto, userId: string, userRole: UserRole): Promise<Task>;
    remove(id: string, userId: string, userRole: UserRole): Promise<void>;
}
