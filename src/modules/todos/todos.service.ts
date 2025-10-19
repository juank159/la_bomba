import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Todo } from './entities/todo.entity';
import { Task } from './entities/task.entity';
import { CreateTodoDto } from './dto/create-todo.dto';
import { UpdateTodoDto } from './dto/update-todo.dto';
import { UpdateTaskDto } from './dto/update-task.dto';
import { UserRole } from '../users/entities/user.entity';

@Injectable()
export class TodosService {
  constructor(
    @InjectRepository(Todo)
    private todosRepository: Repository<Todo>,
    @InjectRepository(Task)
    private tasksRepository: Repository<Task>,
  ) {}

  async create(createTodoDto: CreateTodoDto, userId: string, userRole: UserRole): Promise<Todo> {
    if (createTodoDto.assignedToId && userRole !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can assign todos to other users');
    }

    const todo = this.todosRepository.create({
      description: createTodoDto.description,
      createdById: userId,
      assignedToId: createTodoDto.assignedToId || userId,
    });

    const savedTodo = await this.todosRepository.save(todo);

    if (createTodoDto.tasks && createTodoDto.tasks.length > 0) {
      const tasks = createTodoDto.tasks.map(task => 
        this.tasksRepository.create({
          description: task.description,
          todoId: savedTodo.id,
        })
      );

      await this.tasksRepository.save(tasks);
    }

    return this.findOne(savedTodo.id);
  }

  async findAll(userId: string, userRole: UserRole): Promise<Todo[]> {
    const whereCondition = userRole === UserRole.ADMIN 
      ? {} 
      : { assignedToId: userId };

    return this.todosRepository.find({
      where: whereCondition,
      relations: ['createdBy', 'assignedTo', 'tasks'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Todo> {
    const todo = await this.todosRepository.findOne({
      where: { id },
      relations: ['createdBy', 'assignedTo', 'tasks'],
    });

    if (!todo) {
      throw new NotFoundException(`Todo with ID ${id} not found`);
    }

    return todo;
  }

  async update(id: string, updateTodoDto: UpdateTodoDto, userId: string, userRole: UserRole): Promise<Todo> {
    const todo = await this.findOne(id);

    if (userRole !== UserRole.ADMIN && todo.assignedToId !== userId) {
      throw new ForbiddenException('You can only update your own todos');
    }

    if (updateTodoDto.assignedToId && userRole !== UserRole.ADMIN) {
      throw new ForbiddenException('Only admins can reassign todos');
    }

    Object.assign(todo, updateTodoDto);
    await this.todosRepository.save(todo);

    if (updateTodoDto.tasks) {
      await this.tasksRepository.delete({ todoId: id });
      
      const tasks = updateTodoDto.tasks.map(task => 
        this.tasksRepository.create({
          description: task.description,
          todoId: id,
        })
      );

      await this.tasksRepository.save(tasks);
    }

    return this.findOne(id);
  }

  async updateTask(todoId: string, taskId: string, updateTaskDto: UpdateTaskDto, userId: string, userRole: UserRole): Promise<Task> {
    const todo = await this.findOne(todoId);

    if (userRole !== UserRole.ADMIN && todo.assignedToId !== userId) {
      throw new ForbiddenException('You can only update tasks from your own todos');
    }

    const task = await this.tasksRepository.findOne({
      where: { id: taskId, todoId },
    });

    if (!task) {
      throw new NotFoundException(`Task with ID ${taskId} not found`);
    }

    Object.assign(task, updateTaskDto);
    return this.tasksRepository.save(task);
  }

  async remove(id: string, userId: string, userRole: UserRole): Promise<void> {
    const todo = await this.findOne(id);

    if (userRole !== UserRole.ADMIN && todo.createdById !== userId) {
      throw new ForbiddenException('You can only delete todos you created');
    }

    await this.todosRepository.remove(todo);
  }
}