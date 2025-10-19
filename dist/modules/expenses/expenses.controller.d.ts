import { ExpensesService } from './expenses.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
export declare class ExpensesController {
    private readonly expensesService;
    constructor(expensesService: ExpensesService);
    create(createExpenseDto: CreateExpenseDto, req: any): Promise<import("./entities/expense.entity").Expense>;
    findAll(): Promise<import("./entities/expense.entity").Expense[]>;
    findOne(id: string): Promise<import("./entities/expense.entity").Expense>;
    update(id: string, updateExpenseDto: UpdateExpenseDto): Promise<import("./entities/expense.entity").Expense>;
    remove(id: string): Promise<void>;
}
