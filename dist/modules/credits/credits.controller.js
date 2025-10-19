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
exports.CreditsController = void 0;
const common_1 = require("@nestjs/common");
const credits_service_1 = require("./credits.service");
const create_credit_dto_1 = require("./dto/create-credit.dto");
const update_credit_dto_1 = require("./dto/update-credit.dto");
const create_payment_dto_1 = require("./dto/create-payment.dto");
const add_amount_to_credit_dto_1 = require("./dto/add-amount-to-credit.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const roles_guard_1 = require("../../common/guards/roles.guard");
const roles_decorator_1 = require("../../common/decorators/roles.decorator");
const user_entity_1 = require("../users/entities/user.entity");
let CreditsController = class CreditsController {
    constructor(creditsService) {
        this.creditsService = creditsService;
    }
    create(createCreditDto, req) {
        return this.creditsService.create(createCreditDto, req.user.username);
    }
    findAll() {
        return this.creditsService.findAll();
    }
    findPendingCreditByClient(clientId) {
        return this.creditsService.findPendingCreditByClient(clientId);
    }
    findOne(id) {
        return this.creditsService.findOne(id);
    }
    update(id, updateCreditDto, req) {
        return this.creditsService.update(id, updateCreditDto, req.user.username);
    }
    addAmountToCredit(id, addAmountDto, req) {
        return this.creditsService.addAmountToCredit(id, addAmountDto.amount, addAmountDto.description, req.user.username);
    }
    addPayment(id, createPaymentDto, req) {
        return this.creditsService.addPayment(id, createPaymentDto, req.user.username);
    }
};
exports.CreditsController = CreditsController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_credit_dto_1.CreateCreditDto, Object]),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)('client/:clientId/pending'),
    __param(0, (0, common_1.Param)('clientId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "findPendingCreditByClient", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, update_credit_dto_1.UpdateCreditDto, Object]),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "update", null);
__decorate([
    (0, common_1.Post)(':id/add-amount'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, add_amount_to_credit_dto_1.AddAmountToCreditDto, Object]),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "addAmountToCredit", null);
__decorate([
    (0, common_1.Post)(':id/payments'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_payment_dto_1.CreatePaymentDto, Object]),
    __metadata("design:returntype", void 0)
], CreditsController.prototype, "addPayment", null);
exports.CreditsController = CreditsController = __decorate([
    (0, common_1.Controller)('credits'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, roles_guard_1.RolesGuard),
    (0, roles_decorator_1.Roles)(user_entity_1.UserRole.ADMIN),
    __metadata("design:paramtypes", [credits_service_1.CreditsService])
], CreditsController);
//# sourceMappingURL=credits.controller.js.map