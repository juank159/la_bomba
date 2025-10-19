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
exports.ProductUpdateTasksController = void 0;
const common_1 = require("@nestjs/common");
const product_update_tasks_service_1 = require("./product-update-tasks.service");
const create_task_dto_1 = require("./dto/create-task.dto");
const complete_task_dto_1 = require("./dto/complete-task.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../../common/guards/roles.guard");
const roles_decorator_1 = require("../../common/decorators/roles.decorator");
const user_entity_1 = require("../users/entities/user.entity");
let ProductUpdateTasksController = class ProductUpdateTasksController {
    constructor(tasksService) {
        this.tasksService = tasksService;
    }
    create(createTaskDto, req) {
        console.log('📝 CREATE task endpoint called by admin:', req.user?.userId);
        return this.tasksService.create(createTaskDto, req.user?.userId);
    }
    getPendingTasks(page, limit) {
        console.log('📋 GET pending tasks called:', { page, limit });
        return this.tasksService.getPendingTasks(page || 0, limit || 20);
    }
    getCompletedTasks(page, limit) {
        console.log('✅ GET completed tasks called:', { page, limit });
        return this.tasksService.getCompletedTasks(page || 0, limit || 20);
    }
    getTasksStats() {
        console.log('📊 GET tasks stats called');
        return this.tasksService.getTasksCount();
    }
    getAllTasks(page, limit) {
        console.log('📊 GET all tasks called:', { page, limit });
        return this.tasksService.getAllTasks(page || 0, limit || 20);
    }
    findOne(id) {
        console.log('🔍 GET task by ID called:', id);
        return this.tasksService.findOne(id);
    }
    completeTask(id, completeTaskDto, req) {
        console.log('🎯 COMPLETE task endpoint called by supervisor:', { id, supervisorId: req.user?.userId });
        return this.tasksService.completeTask(id, completeTaskDto, req.user?.userId);
    }
};
exports.ProductUpdateTasksController = ProductUpdateTasksController;
__decorate([
    (0, common_1.Post)(),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.ADMIN),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_task_dto_1.CreateTaskDto, Object]),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "create", null);
__decorate([
    (0, common_1.Get)('pending'),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.SUPERVISOR, user_entity_1.UserRole.ADMIN),
    __param(0, (0, common_1.Query)('page')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number]),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "getPendingTasks", null);
__decorate([
    (0, common_1.Get)('completed'),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.SUPERVISOR, user_entity_1.UserRole.ADMIN),
    __param(0, (0, common_1.Query)('page')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number]),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "getCompletedTasks", null);
__decorate([
    (0, common_1.Get)('stats'),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.SUPERVISOR, user_entity_1.UserRole.ADMIN),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "getTasksStats", null);
__decorate([
    (0, common_1.Get)(),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.SUPERVISOR, user_entity_1.UserRole.ADMIN),
    __param(0, (0, common_1.Query)('page')),
    __param(1, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number]),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "getAllTasks", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.SUPERVISOR, user_entity_1.UserRole.ADMIN),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id/complete'),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.SUPERVISOR),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, complete_task_dto_1.CompleteTaskDto, Object]),
    __metadata("design:returntype", void 0)
], ProductUpdateTasksController.prototype, "completeTask", null);
exports.ProductUpdateTasksController = ProductUpdateTasksController = __decorate([
    (0, common_1.Controller)('product-update-tasks'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    __metadata("design:paramtypes", [product_update_tasks_service_1.ProductUpdateTasksService])
], ProductUpdateTasksController);
//# sourceMappingURL=product-update-tasks.controller.js.map