import { PartialType } from '@nestjs/mapped-types';
import { CreateVegetableCategoryDto } from './create-vegetable-category.dto';

export class UpdateVegetableCategoryDto extends PartialType(CreateVegetableCategoryDto) {}
