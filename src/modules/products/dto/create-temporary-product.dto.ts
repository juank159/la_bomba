import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateTemporaryProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsString()
  @IsNotEmpty()
  createdBy: string;
}
