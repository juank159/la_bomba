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
exports.ProductsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const product_entity_1 = require("./entities/product.entity");
const product_update_tasks_service_1 = require("./product-update-tasks.service");
const product_update_task_entity_1 = require("./entities/product-update-task.entity");
let ProductsService = class ProductsService {
    constructor(productsRepository, tasksService) {
        this.productsRepository = productsRepository;
        this.tasksService = tasksService;
    }
    async create(createProductDto) {
        const product = this.productsRepository.create(createProductDto);
        return this.productsRepository.save(product);
    }
    async findAll(search, page, limit) {
        if (search && search.trim().length > 0) {
            return this.searchProducts(search, page || 0, limit || 20);
        }
        return this.productsRepository.find({
            where: { isActive: true },
            order: { createdAt: 'DESC' },
            skip: page ? page * (limit || 20) : undefined,
            take: limit || undefined,
        });
    }
    async findOne(id) {
        const product = await this.productsRepository.findOne({
            where: { id, isActive: true }
        });
        if (!product) {
            throw new common_1.NotFoundException(`Product with ID ${id} not found`);
        }
        return product;
    }
    async findOneForAdmin(id) {
        const product = await this.productsRepository.findOne({
            where: { id }
        });
        if (!product) {
            throw new common_1.NotFoundException(`Product with ID ${id} not found`);
        }
        return product;
    }
    async update(id, updateProductDto, updatedById) {
        console.log('🔄 ProductsService.update called with:', { id, updateProductDto, updatedById });
        console.log('🔍 Searching for product with ID:', id);
        const product = await this.productsRepository.findOne({
            where: { id }
        });
        console.log('🔍 Found product:', product ? 'YES' : 'NO');
        if (product) {
            console.log('📊 Product details:', {
                id: product.id,
                description: product.description,
                isActive: product.isActive
            });
        }
        if (!product) {
            console.log('❌ Product not found with ID:', id);
            throw new common_1.NotFoundException(`Product with ID ${id} not found`);
        }
        const oldValues = {
            precioA: product.precioA,
            precioB: product.precioB,
            precioC: product.precioC,
            costo: product.costo,
            iva: product.iva,
            description: product.description,
        };
        console.log('✏️ Updating product with data:', updateProductDto);
        Object.assign(product, updateProductDto);
        console.log('💾 Saving updated product...');
        const savedProduct = await this.productsRepository.save(product);
        console.log('✅ Product saved successfully:', savedProduct.id);
        if (updatedById) {
            try {
                await this.createUpdateTask(oldValues, updateProductDto, savedProduct, updatedById);
            }
            catch (error) {
                console.error('⚠️ Failed to create update task:', error);
            }
        }
        return savedProduct;
    }
    async createUpdateTask(oldValues, updateData, product, updatedById) {
        const priceFields = ['precioA', 'precioB', 'precioC', 'costo'];
        const infoFields = ['description', 'iva'];
        let hasChanges = false;
        let changeType = product_update_task_entity_1.ChangeType.INFO;
        let description = '';
        const priceChanges = priceFields.filter(field => updateData[field] !== undefined && updateData[field] !== oldValues[field]);
        const infoChanges = infoFields.filter(field => updateData[field] !== undefined && updateData[field] !== oldValues[field]);
        if (priceChanges.length > 0) {
            hasChanges = true;
            changeType = product_update_task_entity_1.ChangeType.PRICE;
            description = `Precio actualizado: ${priceChanges.join(', ')}`;
        }
        else if (infoChanges.length > 0) {
            hasChanges = true;
            changeType = product_update_task_entity_1.ChangeType.INFO;
            description = `Información actualizada: ${infoChanges.join(', ')}`;
        }
        if (hasChanges) {
            console.log('📝 Creating update task for product:', {
                productId: product.id,
                changeType,
                description,
            });
            await this.tasksService.createTaskForProductUpdate(product.id, changeType, oldValues, updateData, updatedById, description);
        }
    }
    async remove(id) {
        const product = await this.findOne(id);
        product.isActive = false;
        await this.productsRepository.save(product);
    }
    async searchProducts(query, page = 0, limit = 20) {
        console.log('searchProducts called with:', { query, page, limit });
        if (!query || query.trim().length === 0) {
            console.log('No query provided, returning all products');
            return this.findAll();
        }
        const searchTerm = `%${query.trim()}%`;
        console.log('Searching with term:', searchTerm);
        try {
            const result = await this.productsRepository.find({
                where: [
                    { description: (0, typeorm_2.ILike)(searchTerm), isActive: true },
                    { barcode: (0, typeorm_2.ILike)(searchTerm), isActive: true },
                ],
                order: { createdAt: 'DESC' },
                skip: page * limit,
                take: limit,
            });
            console.log('Search result count:', result.length);
            return result;
        }
        catch (error) {
            console.error('Database search error:', error);
            throw error;
        }
    }
};
exports.ProductsService = ProductsService;
exports.ProductsService = ProductsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(product_entity_1.Product)),
    __param(1, (0, common_1.Inject)((0, common_1.forwardRef)(() => product_update_tasks_service_1.ProductUpdateTasksService))),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        product_update_tasks_service_1.ProductUpdateTasksService])
], ProductsService);
//# sourceMappingURL=products.service.js.map