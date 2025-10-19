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
exports.ProductUpdateTasksService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const product_update_task_entity_1 = require("./entities/product-update-task.entity");
let ProductUpdateTasksService = class ProductUpdateTasksService {
    constructor(tasksRepository) {
        this.tasksRepository = tasksRepository;
    }
    async create(createTaskDto, createdById) {
        console.log('📝 Creating new task:', { ...createTaskDto, createdById });
        const task = this.tasksRepository.create({
            ...createTaskDto,
            createdById,
            status: product_update_task_entity_1.TaskStatus.PENDING,
        });
        const savedTask = await this.tasksRepository.save(task);
        console.log('✅ Task created:', savedTask.id);
        const taskWithRelations = await this.tasksRepository.findOne({
            where: { id: savedTask.id },
            relations: ['product', 'createdBy'],
        });
        return taskWithRelations;
    }
    async getPendingTasks(page = 0, limit = 20) {
        console.log('📋 Getting pending tasks:', { page, limit });
        return await this.tasksRepository.find({
            where: { status: product_update_task_entity_1.TaskStatus.PENDING },
            order: { createdAt: 'DESC' },
            skip: page * limit,
            take: limit,
            relations: ['product', 'createdBy'],
        });
    }
    async getCompletedTasks(page = 0, limit = 20) {
        console.log('✅ Getting completed tasks:', { page, limit });
        return await this.tasksRepository.find({
            where: { status: product_update_task_entity_1.TaskStatus.COMPLETED },
            order: { completedAt: 'DESC' },
            skip: page * limit,
            take: limit,
            relations: ['product', 'createdBy', 'completedBy'],
        });
    }
    async getAllTasks(page = 0, limit = 20) {
        console.log('📊 Getting all tasks:', { page, limit });
        return await this.tasksRepository.find({
            order: { createdAt: 'DESC' },
            skip: page * limit,
            take: limit,
        });
    }
    async findOne(id) {
        const task = await this.tasksRepository.findOne({
            where: { id },
            relations: ['product', 'createdBy', 'completedBy'],
        });
        if (!task) {
            throw new common_1.NotFoundException(`Task with ID ${id} not found`);
        }
        return task;
    }
    async completeTask(id, completeTaskDto, completedById) {
        console.log('🎯 Completing task:', { id, completedById, notes: completeTaskDto.notes });
        const task = await this.findOne(id);
        if (task.status !== product_update_task_entity_1.TaskStatus.PENDING) {
            throw new common_1.ForbiddenException('Only pending tasks can be completed');
        }
        task.status = product_update_task_entity_1.TaskStatus.COMPLETED;
        task.completedById = completedById;
        task.completedAt = new Date();
        task.notes = completeTaskDto.notes;
        const updatedTask = await this.tasksRepository.save(task);
        console.log('✅ Task completed:', updatedTask.id);
        return updatedTask;
    }
    async getTasksCount() {
        const [pending, completed, total] = await Promise.all([
            this.tasksRepository.count({ where: { status: product_update_task_entity_1.TaskStatus.PENDING } }),
            this.tasksRepository.count({ where: { status: product_update_task_entity_1.TaskStatus.COMPLETED } }),
            this.tasksRepository.count(),
        ]);
        return { pending, completed, total };
    }
    async createTaskForProductUpdate(productId, changeType, oldValue, newValue, createdById, description) {
        console.log('🔄 Auto-creating task for product update:', {
            productId,
            changeType,
            createdById
        });
        const createTaskDto = {
            productId,
            changeType,
            oldValue,
            newValue,
            description: description || `${changeType} update for product`,
        };
        return await this.create(createTaskDto, createdById);
    }
};
exports.ProductUpdateTasksService = ProductUpdateTasksService;
exports.ProductUpdateTasksService = ProductUpdateTasksService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(product_update_task_entity_1.ProductUpdateTask)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], ProductUpdateTasksService);
//# sourceMappingURL=product-update-tasks.service.js.map