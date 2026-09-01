import { PartialType } from '@nestjs/mapped-types';
import { CreateVegetableItemDto } from './create-vegetable-item.dto';

export class UpdateVegetableItemDto extends PartialType(CreateVegetableItemDto) {}
