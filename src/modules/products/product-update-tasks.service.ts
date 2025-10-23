import { Injectable, NotFoundException, ForbiddenException, forwardRef, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProductUpdateTask, TaskStatus, ChangeType } from './entities/product-update-task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { CompleteTaskDto } from './dto/complete-task.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/entities/notification.entity';
import { Product } from './entities/product.entity';

@Injectable()
export class ProductUpdateTasksService {
  constructor(
    @InjectRepository(ProductUpdateTask)
    private tasksRepository: Repository<ProductUpdateTask>,
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    private notificationsService: NotificationsService,
  ) {}

  /// Create a new update task
  async create(createTaskDto: CreateTaskDto, createdById: string): Promise<ProductUpdateTask> {
    console.log('📝 Creating new task:', { ...createTaskDto, createdById });

    const task = this.tasksRepository.create({
      ...createTaskDto,
      createdById,
      status: TaskStatus.PENDING,
    });

    const savedTask = await this.tasksRepository.save(task);
    console.log('✅ Task created:', savedTask.id);

    // Load the task with relations to return complete data
    const taskWithRelations = await this.tasksRepository.findOne({
      where: { id: savedTask.id },
      relations: ['product', 'createdBy'],
    });

    return taskWithRelations;
  }

  /// Get pending tasks for supervisors
  async getPendingTasks(page: number = 0, limit: number = 20): Promise<ProductUpdateTask[]> {
    console.log('📋 Getting pending tasks:', { page, limit });
    
    return await this.tasksRepository.find({
      where: { status: TaskStatus.PENDING },
      order: { createdAt: 'DESC' },
      skip: page * limit,
      take: limit,
      relations: ['product', 'createdBy'],
    });
  }

  /// Get completed tasks
  async getCompletedTasks(page: number = 0, limit: number = 20): Promise<ProductUpdateTask[]> {
    console.log('✅ Getting completed tasks:', { page, limit });
    
    return await this.tasksRepository.find({
      where: { status: TaskStatus.COMPLETED },
      order: { completedAt: 'DESC' },
      skip: page * limit,
      take: limit,
      relations: ['product', 'createdBy', 'completedBy'],
    });
  }

  /// Get all tasks
  async getAllTasks(page: number = 0, limit: number = 20): Promise<ProductUpdateTask[]> {
    console.log('📊 Getting all tasks:', { page, limit });
    
    return await this.tasksRepository.find({
      order: { createdAt: 'DESC' },
      skip: page * limit,
      take: limit,
    });
  }

  /// Get task by ID
  async findOne(id: string): Promise<ProductUpdateTask> {
    const task = await this.tasksRepository.findOne({
      where: { id },
      relations: ['product', 'createdBy', 'completedBy'],
    });

    if (!task) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }

    return task;
  }

  /// Complete a task (only supervisors)
  async completeTask(
    id: string,
    completeTaskDto: CompleteTaskDto,
    completedById: string,
  ): Promise<ProductUpdateTask> {
    console.log('🎯 Completing task:', { id, completedById, notes: completeTaskDto.notes });

    const task = await this.findOne(id);

    if (task.status !== TaskStatus.PENDING) {
      throw new ForbiddenException('Only pending tasks can be completed');
    }

    task.status = TaskStatus.COMPLETED;
    task.completedById = completedById;
    task.completedAt = new Date();
    task.notes = completeTaskDto.notes;

    const updatedTask = await this.tasksRepository.save(task);
    console.log('✅ Task completed:', updatedTask.id);

    // Create notification for admin if there's a note
    if (completeTaskDto.notes && completeTaskDto.notes.trim().length > 0) {
      try {
        // Get product details
        const product = await this.productsRepository.findOne({
          where: { id: task.productId },
        });

        if (product) {
          // Build notification title and message based on change type
          let changeTypeText = 'información';
          switch (task.changeType) {
            case ChangeType.PRICE:
              changeTypeText = 'precios';
              break;
            case ChangeType.INFO:
              changeTypeText = 'información';
              break;
            case ChangeType.ARRIVAL:
              changeTypeText = 'llegada';
              break;
          }

          const title = `Tarea completada: ${product.description}`;
          const message = `El supervisor completó la tarea de ${changeTypeText} del producto "${product.description}".\n\nNota: ${completeTaskDto.notes}`;

          // Get admin user (assuming there's one admin with role 'admin')
          // In production, you might want to notify all admins
          await this.notificationsService.createNotification(
            task.createdById, // The admin who created the task
            title,
            message,
            NotificationType.TASK_COMPLETED,
            product.id,
            task.id,
          );

          console.log('📬 Notification created for admin:', task.createdById);
        }
      } catch (error) {
        console.error('⚠️ Failed to create notification:', error);
        // Don't fail the task completion if notification fails
      }
    }

    return updatedTask;
  }

  /// Get tasks count by status
  async getTasksCount(): Promise<{ pending: number; completed: number; total: number }> {
    const [pending, completed, total] = await Promise.all([
      this.tasksRepository.count({ where: { status: TaskStatus.PENDING } }),
      this.tasksRepository.count({ where: { status: TaskStatus.COMPLETED } }),
      this.tasksRepository.count(),
    ]);

    return { pending, completed, total };
  }

  /// Create task automatically when product is updated
  async createTaskForProductUpdate(
    productId: string,
    changeType: ChangeType,
    oldValue: any,
    newValue: any,
    createdById: string,
    description?: string,
  ): Promise<ProductUpdateTask> {
    console.log('🔄 Auto-creating task for product update:', { 
      productId, 
      changeType, 
      createdById 
    });

    const createTaskDto: CreateTaskDto = {
      productId,
      changeType,
      oldValue,
      newValue,
      description: description || `${changeType} update for product`,
    };

    return await this.create(createTaskDto, createdById);
  }
}