import { PartialType } from '@nestjs/mapped-types';
import { CreateVegetableExpenseDto } from './create-vegetable-expense.dto';

export class UpdateVegetableExpenseDto extends PartialType(CreateVegetableExpenseDto) {}
