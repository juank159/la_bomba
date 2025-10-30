import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { FirebaseNotificationService } from './firebase-notification.service';
import { Notification } from './entities/notification.entity';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Notification]),
    ConfigModule,
    UsersModule,
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, FirebaseNotificationService],
  exports: [NotificationsService, FirebaseNotificationService],
})
export class NotificationsModule {}
