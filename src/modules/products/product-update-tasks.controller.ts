import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Query, Request, ForbiddenException } from '@nestjs/common';
import { ProductUpdateTasksService } from './product-update-tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { CompleteTaskDto } from './dto/complete-task.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';
import { AssignedRole } from './entities/product-update-task.entity';

/**
 * Mapea el rol del usuario logueado al filtro `assignedRole` que debe aplicarse.
 * - SUPERVISOR ve solo sus tareas
 * - DIGITADOR ve solo las suyas
 * - ADMIN no tiene filtro (ve todo)
 */
function assignedRoleFilterFor(userRole: string): AssignedRole | undefined {
  if (userRole === UserRole.SUPERVISOR) return AssignedRole.SUPERVISOR;
  if (userRole === UserRole.DIGITADOR) return AssignedRole.DIGITADOR;
  return undefined; // admin u otro: sin filtro
}

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
  @Roles(UserRole.SUPERVISOR, UserRole.DIGITADOR, UserRole.ADMIN)
  getPendingTasks(
    @Request() req: any,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const filter = assignedRoleFilterFor(req.user?.role);
    return this.tasksService.getPendingTasks(page || 1, limit || 20, filter);
  }

  @Get('completed')
  @Roles(UserRole.SUPERVISOR, UserRole.DIGITADOR, UserRole.ADMIN)
  getCompletedTasks(
    @Request() req: any,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const filter = assignedRoleFilterFor(req.user?.role);
    return this.tasksService.getCompletedTasks(page || 1, limit || 20, filter);
  }

  @Get('stats')
  @Roles(UserRole.SUPERVISOR, UserRole.DIGITADOR, UserRole.ADMIN)
  getTasksStats(@Request() req: any) {
    const filter = assignedRoleFilterFor(req.user?.role);
    return this.tasksService.getTasksCount(filter);
  }

  @Get()
  @Roles(UserRole.SUPERVISOR, UserRole.DIGITADOR, UserRole.ADMIN)
  getAllTasks(
    @Request() req: any,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const filter = assignedRoleFilterFor(req.user?.role);
    return this.tasksService.getAllTasks(page || 1, limit || 20, filter);
  }

  @Get(':id')
  @Roles(UserRole.SUPERVISOR, UserRole.DIGITADOR, UserRole.ADMIN)
  findOne(@Param('id') id: string) {
    return this.tasksService.findOne(id);
  }

  @Patch(':id/complete')
  @Roles(UserRole.SUPERVISOR, UserRole.DIGITADOR, UserRole.ADMIN)
  async completeTask(
    @Param('id') id: string,
    @Body() completeTaskDto: CompleteTaskDto,
    @Request() req: any,
  ) {
    console.log('🎯 COMPLETE task endpoint called:', {
      id,
      userId: req.user?.userId,
      role: req.user?.role,
    });

    // Un rol no-admin solo puede completar tareas asignadas a su propio rol
    const filter = assignedRoleFilterFor(req.user?.role);
    if (filter) {
      const task = await this.tasksService.findOne(id);
      if (task.assignedRole !== filter) {
        throw new ForbiddenException(
          'Esta tarea no está asignada a tu rol',
        );
      }
    }

    return this.tasksService.completeTask(id, completeTaskDto, req.user?.userId);
  }
}