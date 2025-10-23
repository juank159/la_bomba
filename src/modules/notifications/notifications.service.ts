import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification, NotificationType } from './entities/notification.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private notificationsRepository: Repository<Notification>,
  ) {}

  async createNotification(
    userId: string,
    title: string,
    message: string,
    type: NotificationType = NotificationType.TASK_COMPLETED,
    productId?: string,
    relatedTaskId?: string,
    temporaryProductId?: string,
  ): Promise<Notification> {
    const notification = this.notificationsRepository.create({
      userId,
      title,
      message,
      productId,
      relatedTaskId,
      temporaryProductId,
      type,
      isRead: false,
    });

    return await this.notificationsRepository.save(notification);
  }

  async getNotificationsByUser(userId: string, limit: number = 50): Promise<Notification[]> {
    // Retornar solo las últimas 50 notificaciones para optimizar
    return await this.notificationsRepository.find({
      where: { userId },
      relations: ['product'],
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  async getUnreadCount(userId: string): Promise<number> {
    return await this.notificationsRepository.count({
      where: { userId, isRead: false },
    });
  }

  async markAsRead(id: string, userId: string): Promise<boolean> {
    const result = await this.notificationsRepository.update(
      { id, userId },
      { isRead: true },
    );
    return result.affected > 0;
  }

  async markAllAsRead(userId: string): Promise<boolean> {
    const result = await this.notificationsRepository.update(
      { userId, isRead: false },
      { isRead: true },
    );
    return result.affected > 0;
  }

  async deleteNotification(id: string, userId: string): Promise<boolean> {
    const result = await this.notificationsRepository.delete({ id, userId });
    return result.affected > 0;
  }

  /**
   * Elimina notificaciones antiguas (más de 30 días)
   * Este método se puede llamar desde un cron job
   */
  async cleanupOldNotifications(daysOld: number = 30): Promise<number> {
    const date = new Date();
    date.setDate(date.getDate() - daysOld);

    const result = await this.notificationsRepository
      .createQueryBuilder()
      .delete()
      .where('createdAt < :date', { date })
      .execute();

    return result.affected || 0;
  }

  /**
   * Elimina todas las notificaciones leídas de un usuario
   */
  async deleteReadNotifications(userId: string): Promise<number> {
    const result = await this.notificationsRepository.delete({
      userId,
      isRead: true,
    });
    return result.affected || 0;
  }
}
