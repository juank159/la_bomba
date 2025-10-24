import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request } from '@nestjs/common';
import { ProductUpdateTasksService } from './product-update-tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { CompleteTaskDto } from './dto/complete-task.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('product-update-tasks')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProductUpdateTasksController {
  constructor(private readonly tasksService: ProductUpdateTasksService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  create(@Body() createTaskDto: CreateTaskDto, @Request() req: any) {
    console.log('📝 CREATE task endpoint called by admin:', req.user?.userId);
    return this.tasksService.create(createTaskDto, req.user?.userId);
  }

  @Get('pending')
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  getPendingTasks(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    console.log('📋 GET pending tasks called:', { page, limit });
    return this.tasksService.getPendingTasks(page || 0, limit || 20);
  }

  @Get('completed')
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  getCompletedTasks(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    console.log('✅ GET completed tasks called:', { page, limit });
    return this.tasksService.getCompletedTasks(page || 0, limit || 20);
  }

  @Get('stats')
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  getTasksStats() {
    console.log('📊 GET tasks stats called');
    return this.tasksService.getTasksCount();
  }

  @Get()
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  getAllTasks(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    console.log('📊 GET all tasks called:', { page, limit });
    return this.tasksService.getAllTasks(page || 0, limit || 20);
  }

  @Get(':id')
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  findOne(@Param('id') id: string) {
    console.log('🔍 GET task by ID called:', id);
    return this.tasksService.findOne(id);
  }

  @Patch(':id/complete')
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  completeTask(
    @Param('id') id: string,
    @Body() completeTaskDto: CompleteTaskDto,
    @Request() req: any,
  ) {
    console.log('🎯 COMPLETE task endpoint called:', {
      id,
      userId: req.user?.userId,
      role: req.user?.role
    });
    return this.tasksService.completeTask(id, completeTaskDto, req.user?.userId);
  }
}