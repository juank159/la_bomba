import { Controller, Get, Patch, Delete, Param, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('notifications')
@UseGuards(JwtAuthGuard, RolesGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @Roles(UserRole.ADMIN)
  async getNotifications(@Request() req: any) {
    return this.notificationsService.getNotificationsByUser(req.user.userId);
  }

  @Get('unread-count')
  @Roles(UserRole.ADMIN)
  async getUnreadCount(@Request() req: any) {
    const count = await this.notificationsService.getUnreadCount(req.user.userId);
    return { count };
  }

  @Patch(':id/mark-as-read')
  @Roles(UserRole.ADMIN)
  async markAsRead(@Param('id') id: string, @Request() req: any) {
    const success = await this.notificationsService.markAsRead(id, req.user.userId);
    return { success };
  }

  @Patch('mark-all-as-read')
  @Roles(UserRole.ADMIN)
  async markAllAsRead(@Request() req: any) {
    const success = await this.notificationsService.markAllAsRead(req.user.userId);
    return { success };
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  async deleteNotification(@Param('id') id: string, @Request() req: any) {
    const success = await this.notificationsService.deleteNotification(id, req.user.userId);
    return { success };
  }

  @Delete('read/all')
  @Roles(UserRole.ADMIN)
  async deleteReadNotifications(@Request() req: any) {
    const deletedCount = await this.notificationsService.deleteReadNotifications(req.user.userId);
    return {
      success: true,
      deletedCount,
      message: `${deletedCount} notificaciones leídas eliminadas`
    };
  }
}
