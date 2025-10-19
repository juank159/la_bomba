import { Repository } from 'typeorm';
import { Expense } from './entities/expense.entity';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
export declare class ExpensesService {
    private expensesRepository;
    constructor(expensesRepository: Repository<Expense>);
    create(createExpenseDto: CreateExpenseDto, userId: string): Promise<Expense>;
    findAll(): Promise<Expense[]>;
    findOne(id: string): Promise<Expense>;
    update(id: string, updateExpenseDto: UpdateExpenseDto): Promise<Expense>;
    remove(id: string): Promise<void>;
}
