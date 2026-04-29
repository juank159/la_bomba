import { IsString, IsNotEmpty, IsEnum, IsOptional, IsObject } from 'class-validator';
import { ChangeType, AssignedRole } from '../entities/product-update-task.entity';

export class CreateTaskDto {
  @IsString()
  @IsNotEmpty()
  productId: string;

  @IsEnum(ChangeType)
  changeType: ChangeType;

  @IsOptional()
  @IsObject()
  oldValue?: any;

  @IsOptional()
  @IsObject()
  newValue?: any;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  adminNotes?: string;

  @IsOptional()
  @IsEnum(AssignedRole)
  assignedRole?: AssignedRole;
}