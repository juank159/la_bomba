import { Injectable, NotFoundException, ForbiddenException, forwardRef, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ProductUpdateTask, TaskStatus, ChangeType, AssignedRole } from './entities/product-update-task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { CompleteTaskDto } from './dto/complete-task.dto';
import { NotificationsService } from '../notifications/notifications.service';
import { NotificationType } from '../notifications/entities/notification.entity';
import { Product } from './entities/product.entity';
import { User, UserRole } from '../users/entities/user.entity';
import { FirebaseNotificationService, NotificationTypeEnum } from '../notifications/firebase-notification.service';

@Injectable()
export class ProductUpdateTasksService {
  constructor(
    @InjectRepository(ProductUpdateTask)
    private tasksRepository: Repository<ProductUpdateTask>,
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    private notificationsService: NotificationsService,
    private firebaseNotificationService: FirebaseNotificationService,
  ) {}

  /// Create a new update task
  async create(createTaskDto: CreateTaskDto, createdById: string): Promise<ProductUpdateTask> {
    const assignedRole = createTaskDto.assignedRole ?? AssignedRole.SUPERVISOR;
    console.log('📝 Creating new task:', { ...createTaskDto, assignedRole, createdById });

    const task = this.tasksRepository.create({
      ...createTaskDto,
      assignedRole,
      createdById,
      status: TaskStatus.PENDING,
    });

    const savedTask = await this.tasksRepository.save(task);
    console.log('✅ Task created:', savedTask.id);

    const taskWithRelations = await this.tasksRepository.findOne({
      where: { id: savedTask.id },
      relations: ['product', 'createdBy'],
    });

    const product = await this.productsRepository.findOne({
      where: { id: createTaskDto.productId },
    });

    if (product) {
      // Map AssignedRole → UserRole para buscar destinatarios
      const recipientRole: UserRole =
        assignedRole === AssignedRole.DIGITADOR ? UserRole.DIGITADOR : UserRole.SUPERVISOR;

      const recipients = await this.usersRepository.find({
        where: { role: recipientRole, isActive: true },
      });

      console.log(`📬 Found ${recipients.length} ${recipientRole}(s) to notify for task ${savedTask.id}`);

      // Construir título y mensaje específicos según rol y tipo de cambio.
      // El supervisor ve precios y llegadas; el digitador ve cambios de info.
      // Para edición múltiple del digitador (changeType=INFO con descripción que
      // lista varios campos) marcamos el título como "Edición múltiple".
      const isMultipleChanges =
        assignedRole === AssignedRole.DIGITADOR &&
        createTaskDto.changeType === ChangeType.INFO &&
        (createTaskDto.description?.includes(',') ?? false);

      const titlePrefix = this.titlePrefixFor(
        createTaskDto.changeType,
        assignedRole,
        isMultipleChanges,
      );
      const title = `${titlePrefix} — ${product.description}`;

      // Mensaje claro: detalla qué se cambió, sin redundar el nombre del producto.
      const detail = (createTaskDto.description || '').trim();
      const message = detail
        ? `${titlePrefix}: ${detail}`
        : titlePrefix;

      for (const recipient of recipients) {
        try {
          await this.notificationsService.createNotification(
            recipient.id,
            title,
            message,
            NotificationType.PRODUCT_UPDATE,
            product.id,
            savedTask.id,
          );

          await this.firebaseNotificationService.sendToUser(
            recipient.id,
            title,
            message,
            {
              type: NotificationTypeEnum.PRODUCT_UPDATE,
              productId: product.id,
              taskId: savedTask.id,
            }
          );

          console.log(`✅ Notification sent to ${recipientRole}: ${recipient.username}`);
        } catch (error) {
          console.error(`⚠️ Failed to send notification to ${recipientRole} ${recipient.username}:`, error);
        }
      }
    }

    return taskWithRelations;
  }

  /// Etiqueta legible para el tipo de cambio (usado en mensajes de notificación)
  private changeTypeLabel(changeType: ChangeType): string {
    switch (changeType) {
      case ChangeType.PRICE: return 'precios';
      case ChangeType.NAME: return 'nombre';
      case ChangeType.IVA: return 'IVA';
      case ChangeType.BARCODE: return 'código de barras';
      case ChangeType.DESCRIPTION: return 'descripción';
      case ChangeType.ARRIVAL: return 'llegada';
      case ChangeType.INVENTORY: return 'inventario';
      case ChangeType.INFO:
      default:
        return 'información';
    }
  }

  /**
   * Prefijo del título de notificación. Identifica claramente el tipo de cambio
   * para que el usuario diferencie las tareas de un vistazo (no aparece como
   * "Producto actualizado" genérico).
   */
  private titlePrefixFor(
    changeType: ChangeType,
    assignedRole: AssignedRole,
    isMultipleChanges: boolean,
  ): string {
    if (isMultipleChanges) {
      return 'Edición múltiple';
    }
    switch (changeType) {
      case ChangeType.PRICE:
        return 'Cambio de precio';
      case ChangeType.NAME:
        return 'Cambio de nombre';
      case ChangeType.IVA:
        return 'Cambio de IVA';
      case ChangeType.BARCODE:
        return 'Cambio de código de barras';
      case ChangeType.DESCRIPTION:
        return 'Cambio de descripción';
      case ChangeType.ARRIVAL:
        return 'Llegada de producto';
      case ChangeType.INVENTORY:
        return 'Cambio de inventario';
      case ChangeType.INFO:
      default:
        // INFO con un solo cambio cae acá (no debería pasar con la nueva lógica
        // pero lo cubrimos por compatibilidad con tareas legadas).
        return assignedRole === AssignedRole.DIGITADOR
          ? 'Cambio de información'
          : 'Cambio en producto';
    }
  }

  /// Pending tasks visibles para un rol (supervisor/digitador). Si es null, devuelve todas (admin).
  async getPendingTasks(
    page: number = 1,
    limit: number = 20,
    assignedRole?: AssignedRole,
  ): Promise<ProductUpdateTask[]> {
    console.log('📋 Getting pending tasks:', { page, limit, assignedRole });

    const where: any = { status: TaskStatus.PENDING };
    if (assignedRole) where.assignedRole = assignedRole;

    return await this.tasksRepository.find({
      where,
      order: { createdAt: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
      relations: ['product', 'createdBy'],
    });
  }

  /// Completed tasks visibles para un rol. Si es null, devuelve todas (admin).
  async getCompletedTasks(
    page: number = 1,
    limit: number = 20,
    assignedRole?: AssignedRole,
  ): Promise<ProductUpdateTask[]> {
    console.log('✅ Getting completed tasks:', { page, limit, assignedRole });

    const where: any = { status: TaskStatus.COMPLETED };
    if (assignedRole) where.assignedRole = assignedRole;

    return await this.tasksRepository.find({
      where,
      order: { completedAt: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
      relations: ['product', 'createdBy', 'completedBy'],
    });
  }

  /// All tasks visibles para un rol. Si es null, devuelve todas (admin).
  async getAllTasks(
    page: number = 1,
    limit: number = 20,
    assignedRole?: AssignedRole,
  ): Promise<ProductUpdateTask[]> {
    console.log('📊 Getting all tasks:', { page, limit, assignedRole });

    return await this.tasksRepository.find({
      where: assignedRole ? { assignedRole } : {},
      order: { createdAt: 'ASC' },
      skip: (page - 1) * limit,
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

    await this.tasksRepository.save(task);
    console.log('✅ Task completed:', task.id);

    // Reload task with all relations to return complete data
    const updatedTask = await this.tasksRepository.findOne({
      where: { id: task.id },
      relations: ['product', 'createdBy', 'completedBy'],
    });

    // Create notification for admin if there's a note
    if (completeTaskDto.notes && completeTaskDto.notes.trim().length > 0) {
      try {
        // Get product details
        const product = await this.productsRepository.findOne({
          where: { id: task.productId },
        });

        if (product) {
          const changeTypeText = this.changeTypeLabel(task.changeType);
          const roleLabel = task.assignedRole === AssignedRole.DIGITADOR ? 'digitador' : 'supervisor';
          const roleLabelCap = roleLabel.charAt(0).toUpperCase() + roleLabel.slice(1);

          const title = `${roleLabelCap} completó tarea — ${product.description}`;
          const message = `El ${roleLabel} completó la tarea de ${changeTypeText}.\n\nNota: ${completeTaskDto.notes}`;

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

  /// Tasks count por rol. Si assignedRole es null, cuenta todas (admin).
  async getTasksCount(
    assignedRole?: AssignedRole,
  ): Promise<{ pending: number; completed: number; total: number }> {
    const baseWhere: any = assignedRole ? { assignedRole } : {};
    const [pending, completed, total] = await Promise.all([
      this.tasksRepository.count({ where: { ...baseWhere, status: TaskStatus.PENDING } }),
      this.tasksRepository.count({ where: { ...baseWhere, status: TaskStatus.COMPLETED } }),
      this.tasksRepository.count({ where: baseWhere }),
    ]);

    return { pending, completed, total };
  }

  /// Get pending tasks for a specific product
  async getPendingTasksByProductId(productId: string): Promise<ProductUpdateTask[]> {
    console.log('🔍 Getting pending tasks for product:', productId);

    return await this.tasksRepository.find({
      where: {
        productId,
        status: TaskStatus.PENDING
      },
      relations: ['product', 'createdBy'],
    });
  }

  /// Create task automatically when product is updated
  async createTaskForProductUpdate(
    productId: string,
    changeType: ChangeType,
    oldValue: any,
    newValue: any,
    createdById: string,
    description?: string,
    adminNotes?: string,
    assignedRole: AssignedRole = AssignedRole.SUPERVISOR,
  ): Promise<ProductUpdateTask> {
    console.log('🔄 Auto-creating task for product update:', {
      productId,
      changeType,
      assignedRole,
      createdById,
      hasAdminNotes: !!adminNotes
    });

    const createTaskDto: CreateTaskDto = {
      productId,
      changeType,
      oldValue,
      newValue,
      description: description || `${changeType} update for product`,
      adminNotes,
      assignedRole,
    };

    return await this.create(createTaskDto, createdById);
  }
}