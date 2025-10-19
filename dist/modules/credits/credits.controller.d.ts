import { CreditsService } from './credits.service';
import { CreateCreditDto } from './dto/create-credit.dto';
import { UpdateCreditDto } from './dto/update-credit.dto';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { AddAmountToCreditDto } from './dto/add-amount-to-credit.dto';
export declare class CreditsController {
    private readonly creditsService;
    constructor(creditsService: CreditsService);
    create(createCreditDto: CreateCreditDto, req: any): Promise<import("./entities/credit.entity").Credit>;
    findAll(): Promise<import("./entities/credit.entity").Credit[]>;
    findPendingCreditByClient(clientId: string): Promise<import("./entities/credit.entity").Credit>;
    findOne(id: string): Promise<import("./entities/credit.entity").Credit>;
    update(id: string, updateCreditDto: UpdateCreditDto, req: any): Promise<import("./entities/credit.entity").Credit>;
    addAmountToCredit(id: string, addAmountDto: AddAmountToCreditDto, req: any): Promise<import("./entities/credit.entity").Credit>;
    addPayment(id: string, createPaymentDto: CreatePaymentDto, req: any): Promise<import("./entities/credit.entity").Credit>;
}
