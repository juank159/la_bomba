"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TodosService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const todo_entity_1 = require("./entities/todo.entity");
const task_entity_1 = require("./entities/task.entity");
const user_entity_1 = require("../users/entities/user.entity");
let TodosService = class TodosService {
    constructor(todosRepository, tasksRepository) {
        this.todosRepository = todosRepository;
        this.tasksRepository = tasksRepository;
    }
    async create(createTodoDto, userId, userRole) {
        if (createTodoDto.assignedToId && userRole !== user_entity_1.UserRole.ADMIN) {
            throw new common_1.ForbiddenException('Only admins can assign todos to other users');
        }
        const todo = this.todosRepository.create({
            description: createTodoDto.description,
            createdById: userId,
            assignedToId: createTodoDto.assignedToId || userId,
        });
        const savedTodo = await this.todosRepository.save(todo);
        if (createTodoDto.tasks && createTodoDto.tasks.length > 0) {
            const tasks = createTodoDto.tasks.map(task => this.tasksRepository.create({
                description: task.description,
                todoId: savedTodo.id,
            }));
            await this.tasksRepository.save(tasks);
        }
        return this.findOne(savedTodo.id);
    }
    async findAll(userId, userRole) {
        const whereCondition = userRole === user_entity_1.UserRole.ADMIN
            ? {}
            : { assignedToId: userId };
        return this.todosRepository.find({
            where: whereCondition,
            relations: ['createdBy', 'assignedTo', 'tasks'],
            order: { createdAt: 'DESC' },
        });
    }
    async findOne(id) {
        const todo = await this.todosRepository.findOne({
            where: { id },
            relations: ['createdBy', 'assignedTo', 'tasks'],
        });
        if (!todo) {
            throw new common_1.NotFoundException(`Todo with ID ${id} not found`);
        }
        return todo;
    }
    async update(id, updateTodoDto, userId, userRole) {
        const todo = await this.findOne(id);
        if (userRole !== user_entity_1.UserRole.ADMIN && todo.assignedToId !== userId) {
            throw new common_1.ForbiddenException('You can only update your own todos');
        }
        if (updateTodoDto.assignedToId && userRole !== user_entity_1.UserRole.ADMIN) {
            throw new common_1.ForbiddenException('Only admins can reassign todos');
        }
        Object.assign(todo, updateTodoDto);
        await this.todosRepository.save(todo);
        if (updateTodoDto.tasks) {
            await this.tasksRepository.delete({ todoId: id });
            const tasks = updateTodoDto.tasks.map(task => this.tasksRepository.create({
                description: task.description,
                todoId: id,
            }));
            await this.tasksRepository.save(tasks);
        }
        return this.findOne(id);
    }
    async updateTask(todoId, taskId, updateTaskDto, userId, userRole) {
        const todo = await this.findOne(todoId);
        if (userRole !== user_entity_1.UserRole.ADMIN && todo.assignedToId !== userId) {
            throw new common_1.ForbiddenException('You can only update tasks from your own todos');
        }
        const task = await this.tasksRepository.findOne({
            where: { id: taskId, todoId },
        });
        if (!task) {
            throw new common_1.NotFoundException(`Task with ID ${taskId} not found`);
        }
        Object.assign(task, updateTaskDto);
        return this.tasksRepository.save(task);
    }
    async remove(id, userId, userRole) {
        const todo = await this.findOne(id);
        if (userRole !== user_entity_1.UserRole.ADMIN && todo.createdById !== userId) {
            throw new common_1.ForbiddenException('You can only delete todos you created');
        }
        await this.todosRepository.remove(todo);
    }
};
exports.TodosService = TodosService;
exports.TodosService = TodosService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(todo_entity_1.Todo)),
    __param(1, (0, typeorm_1.InjectRepository)(task_entity_1.Task)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], TodosService);
//# sourceMappingURL=todos.service.js.map