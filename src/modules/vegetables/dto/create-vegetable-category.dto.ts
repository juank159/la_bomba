import { IsString, IsNotEmpty } from 'class-validator';

export class CreateVegetableCategoryDto {
  @IsString()
  @IsNotEmpty()
  name: string;
}
