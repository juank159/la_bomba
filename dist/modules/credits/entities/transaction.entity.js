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
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreditTransaction = exports.TransactionType = void 0;
const typeorm_1 = require("typeorm");
const credit_entity_1 = require("./credit.entity");
var TransactionType;
(function (TransactionType) {
    TransactionType["DEBT_INCREASE"] = "debt_increase";
    TransactionType["PAYMENT"] = "payment";
})(TransactionType || (exports.TransactionType = TransactionType = {}));
let CreditTransaction = class CreditTransaction {
};
exports.CreditTransaction = CreditTransaction;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], CreditTransaction.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => credit_entity_1.Credit, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'credit_id' }),
    __metadata("design:type", credit_entity_1.Credit)
], CreditTransaction.prototype, "credit", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'credit_id' }),
    __metadata("design:type", String)
], CreditTransaction.prototype, "creditId", void 0);
__decorate([
    (0, typeorm_1.Column)({
        type: 'enum',
        enum: TransactionType,
    }),
    __metadata("design:type", String)
], CreditTransaction.prototype, "type", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'decimal', precision: 10, scale: 2 }),
    __metadata("design:type", Number)
], CreditTransaction.prototype, "amount", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'text', nullable: true }),
    __metadata("design:type", String)
], CreditTransaction.prototype, "description", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'created_by', nullable: true }),
    __metadata("design:type", String)
], CreditTransaction.prototype, "createdBy", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], CreditTransaction.prototype, "createdAt", void 0);
exports.CreditTransaction = CreditTransaction = __decorate([
    (0, typeorm_1.Entity)('credit_transactions')
], CreditTransaction);
//# sourceMappingURL=transaction.entity.js.map