"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreditsModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const credits_service_1 = require("./credits.service");
const credits_controller_1 = require("./credits.controller");
const credit_entity_1 = require("./entities/credit.entity");
const payment_entity_1 = require("./entities/payment.entity");
const transaction_entity_1 = require("./entities/transaction.entity");
const client_entity_1 = require("../clients/entities/client.entity");
let CreditsModule = class CreditsModule {
};
exports.CreditsModule = CreditsModule;
exports.CreditsModule = CreditsModule = __decorate([
    (0, common_1.Module)({
        imports: [typeorm_1.TypeOrmModule.forFeature([credit_entity_1.Credit, payment_entity_1.Payment, transaction_entity_1.CreditTransaction, client_entity_1.Client])],
        controllers: [credits_controller_1.CreditsController],
        providers: [credits_service_1.CreditsService],
    })
], CreditsModule);
//# sourceMappingURL=credits.module.js.map