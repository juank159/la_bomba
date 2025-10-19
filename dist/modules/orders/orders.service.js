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
exports.OrdersService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const order_entity_1 = require("./entities/order.entity");
const order_item_entity_1 = require("./entities/order-item.entity");
const user_entity_1 = require("../users/entities/user.entity");
let OrdersService = class OrdersService {
    constructor(ordersRepository, orderItemsRepository) {
        this.ordersRepository = ordersRepository;
        this.orderItemsRepository = orderItemsRepository;
    }
    async create(createOrderDto, userId) {
        const order = this.ordersRepository.create({
            description: createOrderDto.description,
            provider: createOrderDto.provider,
            createdById: userId,
        });
        const savedOrder = await this.ordersRepository.save(order);
        const orderItems = createOrderDto.items.map(item => this.orderItemsRepository.create({
            orderId: savedOrder.id,
            productId: item.productId,
            existingQuantity: item.existingQuantity,
            requestedQuantity: item.requestedQuantity,
            measurementUnit: item.measurementUnit,
        }));
        await this.orderItemsRepository.save(orderItems);
        return this.findOne(savedOrder.id);
    }
    async findAll() {
        return this.ordersRepository.find({
            relations: ['createdBy', 'items', 'items.product'],
            order: { createdAt: 'DESC' },
        });
    }
    async findOne(id) {
        const order = await this.ordersRepository.findOne({
            where: { id },
            relations: ['createdBy', 'items', 'items.product'],
        });
        if (!order) {
            throw new common_1.NotFoundException(`Order with ID ${id} not found`);
        }
        return order;
    }
    async update(id, updateOrderDto, userRole, userId) {
        const order = await this.findOne(id);
        if (userRole === user_entity_1.UserRole.EMPLOYEE) {
            if (order.createdById !== userId) {
                throw new common_1.ForbiddenException('Employees can only edit their own orders');
            }
        }
        if (updateOrderDto.status && userRole !== user_entity_1.UserRole.ADMIN) {
            throw new common_1.ForbiddenException('Only admins can change order status');
        }
        Object.assign(order, updateOrderDto);
        await this.ordersRepository.save(order);
        if (updateOrderDto.items) {
            await this.orderItemsRepository.delete({ orderId: id });
            const orderItems = updateOrderDto.items.map(item => this.orderItemsRepository.create({
                orderId: id,
                productId: item.productId,
                existingQuantity: item.existingQuantity,
                requestedQuantity: item.requestedQuantity,
                measurementUnit: item.measurementUnit,
            }));
            await this.orderItemsRepository.save(orderItems);
        }
        return this.findOne(id);
    }
    async updateRequestedQuantities(updateItemsDto, userRole) {
        if (userRole !== user_entity_1.UserRole.ADMIN) {
            throw new common_1.ForbiddenException('Only admins can update requested quantities');
        }
        for (const item of updateItemsDto) {
            await this.orderItemsRepository.update(item.itemId, { requestedQuantity: item.requestedQuantity });
        }
    }
    async addProductToOrder(orderId, addProductDto, userRole, userId) {
        const order = await this.findOne(orderId);
        if (userRole === user_entity_1.UserRole.EMPLOYEE && order.createdById !== userId) {
            throw new common_1.ForbiddenException('Employees can only modify their own orders');
        }
        const existingItem = order.items.find(item => item.productId === addProductDto.productId);
        if (existingItem) {
            throw new common_1.ForbiddenException('Product already exists in order. Use update quantity instead.');
        }
        const orderItem = this.orderItemsRepository.create({
            orderId,
            productId: addProductDto.productId,
            existingQuantity: addProductDto.existingQuantity,
            requestedQuantity: addProductDto.requestedQuantity,
            measurementUnit: addProductDto.measurementUnit,
        });
        await this.orderItemsRepository.save(orderItem);
        return this.findOne(orderId);
    }
    async removeProductFromOrder(orderId, itemId, userRole, userId) {
        const order = await this.findOne(orderId);
        if (userRole === user_entity_1.UserRole.EMPLOYEE && order.createdById !== userId) {
            throw new common_1.ForbiddenException('Employees can only modify their own orders');
        }
        const orderItem = await this.orderItemsRepository.findOne({
            where: { id: itemId, orderId }
        });
        if (!orderItem) {
            throw new common_1.NotFoundException('Order item not found');
        }
        await this.orderItemsRepository.remove(orderItem);
        return this.findOne(orderId);
    }
    async updateOrderItemQuantity(orderId, itemId, updateDto, userRole, userId) {
        const order = await this.findOne(orderId);
        if (userRole === user_entity_1.UserRole.EMPLOYEE && order.createdById !== userId) {
            throw new common_1.ForbiddenException('Employees can only modify their own orders');
        }
        const orderItem = await this.orderItemsRepository.findOne({
            where: { id: itemId, orderId }
        });
        if (!orderItem) {
            throw new common_1.NotFoundException('Order item not found');
        }
        if (updateDto.existingQuantity !== undefined) {
            orderItem.existingQuantity = updateDto.existingQuantity;
        }
        if (updateDto.requestedQuantity !== undefined) {
            orderItem.requestedQuantity = updateDto.requestedQuantity;
        }
        await this.orderItemsRepository.save(orderItem);
        return this.findOne(orderId);
    }
    async remove(id) {
        const order = await this.findOne(id);
        await this.ordersRepository.remove(order);
    }
};
exports.OrdersService = OrdersService;
exports.OrdersService = OrdersService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(order_entity_1.Order)),
    __param(1, (0, typeorm_1.InjectRepository)(order_item_entity_1.OrderItem)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], OrdersService);
//# sourceMappingURL=orders.service.js.map