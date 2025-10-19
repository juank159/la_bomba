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
exports.ProductsSearchController = void 0;
const common_1 = require("@nestjs/common");
const products_service_1 = require("./products.service");
let ProductsSearchController = class ProductsSearchController {
    constructor(productsService) {
        this.productsService = productsService;
    }
    async search(query, page, limit) {
        try {
            console.log('Search called with:', { query, page, limit });
            return this.productsService.searchProducts(query || '', page || 0, limit || 20);
        }
        catch (error) {
            console.error('Error in search controller:', error);
            throw error;
        }
    }
};
exports.ProductsSearchController = ProductsSearchController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)('q')),
    __param(1, (0, common_1.Query)('page')),
    __param(2, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Number, Number]),
    __metadata("design:returntype", Promise)
], ProductsSearchController.prototype, "search", null);
exports.ProductsSearchController = ProductsSearchController = __decorate([
    (0, common_1.Controller)('products-search'),
    __metadata("design:paramtypes", [products_service_1.ProductsService])
], ProductsSearchController);
//# sourceMappingURL=search.controller.js.map