import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { UsersService } from '../users/users.service';

export enum NotificationTypeEnum {
  SUPERVISOR_TASK = 'SUPERVISOR_TASK',
  ADMIN_TASK = 'ADMIN_TASK',
  PRODUCT_UPDATE = 'PRODUCT_UPDATE',
  PRODUCT_APPROVED = 'PRODUCT_APPROVED',
  CREDIT_REMINDER = 'CREDIT_REMINDER',
  ORDER_UPDATE = 'ORDER_UPDATE',
}

export interface PushNotificationData {
  type: NotificationTypeEnum;
  taskId?: string;
  productId?: string;
  creditId?: string;
  orderId?: string;
}

@Injectable()
export class FirebaseNotificationService implements OnModuleInit {
  private firebaseApp: admin.app.App;

  constructor(
    private configService: ConfigService,
    private usersService: UsersService,
  ) {}

  onModuleInit() {
    try {
      // Check if Firebase is already initialized
      if (!admin.apps.length) {
        const serviceAccount = this.configService.get<string>('FIREBASE_SERVICE_ACCOUNT');

        if (!serviceAccount) {
          console.warn('⚠️ FIREBASE_SERVICE_ACCOUNT not configured. Push notifications will not work.');
          return;
        }

        // Parse service account JSON
        const serviceAccountJson = JSON.parse(serviceAccount);

        // Fix: Replace escaped newlines with actual newlines in private_key
        // This is needed because environment variables escape the newlines
        if (serviceAccountJson.private_key) {
          serviceAccountJson.private_key = serviceAccountJson.private_key.replace(/\\n/g, '\n');
        }

        // Initialize Firebase Admin
        this.firebaseApp = admin.initializeApp({
          credential: admin.credential.cert(serviceAccountJson),
        });

        console.log('✅ Firebase Admin initialized successfully');
      } else {
        this.firebaseApp = admin.app();
        console.log('✅ Firebase Admin already initialized');
      }
    } catch (error) {
      console.error('❌ Error initializing Firebase Admin:', error);
      console.error('Push notifications will not work without Firebase configuration');
    }
  }

  /**
   * Send push notification to a specific user
   */
  async sendToUser(
    userId: string,
    title: string,
    body: string,
    data: PushNotificationData,
  ): Promise<boolean> {
    try {
      if (!this.firebaseApp) {
        console.warn('⚠️ Firebase not initialized, skipping notification');
        return false;
      }

      // Get user's FCM token
      const user = await this.usersService.findOne(userId);

      if (!user || !user.fcmToken) {
        console.log(`⚠️ User ${userId} does not have FCM token`);
        return false;
      }

      console.log(`📤 Preparing to send notification to user ${userId} with token: ${user.fcmToken.substring(0, 20)}...`);

      // Send notification
      const message: admin.messaging.Message = {
        token: user.fcmToken,
        notification: {
          title,
          body,
        },
        data: {
          type: data.type,
          ...(data.taskId && { taskId: data.taskId }),
          ...(data.productId && { productId: data.productId }),
          ...(data.creditId && { creditId: data.creditId }),
          ...(data.orderId && { orderId: data.orderId }),
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: this.getChannelId(data.type),
            icon: 'ic_notification',  // Small icon monocromo
            color: '#FF5722',  // Color naranja como la bomba
          },
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };

      console.log(`🔔 Sending Firebase message with channel: ${this.getChannelId(data.type)}`);
      const response = await admin.messaging().send(message);
      console.log(`✅ Successfully sent notification to user ${userId}, FCM response: ${response}`);
      return true;
    } catch (error) {
      console.error(`❌ Error sending notification to user ${userId}:`);
      console.error(`   Error code: ${error?.code || 'unknown'}`);
      console.error(`   Error message: ${error?.message || 'unknown'}`);
      console.error(`   Full error:`, JSON.stringify(error, null, 2));

      // If token is invalid, clear it from database
      if (error.code === 'messaging/invalid-registration-token' ||
          error.code === 'messaging/registration-token-not-registered') {
        console.log(`🗑️ Clearing invalid FCM token for user ${userId}`);
        await this.usersService.clearFcmToken(userId);
      }

      return false;
    }
  }

  /**
   * Push al cajero que inició un cobro Bre-B apenas el banco lo confirma.
   * El diálogo de cobro abierto lo usa para pasar a "¡Pago confirmado!" al
   * instante (además del polling cada 3 s como red de seguridad), y la app
   * lo anuncia por voz. Nunca lanza: si falla, el polling igual confirma.
   */
  async sendBrebPaymentConfirmed(
    userId: string,
    chargeId: string,
    amount: number,
    payerName: string,
    bankLabel: string,
  ): Promise<boolean> {
    try {
      if (!this.firebaseApp) return false;
      const user = await this.usersService.findOne(userId);
      if (!user?.fcmToken) return false;
      const amountStr = Math.round(amount).toString();
      await admin.messaging().send({
        token: user.fcmToken,
        notification: {
          title: `💰 Pago recibido${bankLabel ? ' — ' + bankLabel : ''}`,
          body: `$${amountStr}${payerName ? ' · ' + payerName : ''}`,
        },
        data: {
          type: 'breb_payment_confirmed',
          charge_id: chargeId,
          amount: amountStr,
          payer_name: payerName ?? '',
          bank: bankLabel ?? '',
        },
        android: {
          priority: 'high',
          notification: {
            sound: 'default',
            channelId: 'default_channel',
            icon: 'ic_notification',
            color: '#4CAF50',
          },
        },
        apns: {
          payload: { aps: { sound: 'default', badge: 1 } },
          headers: { 'apns-priority': '10' },
        },
      });
      return true;
    } catch (error) {
      console.error(`❌ Error enviando push Bre-B a ${userId}: ${error?.message ?? error}`);
      return false;
    }
  }

  /**
   * Send push notification to multiple users
   */
  async sendToMultipleUsers(
    userIds: string[],
    title: string,
    body: string,
    data: PushNotificationData,
  ): Promise<{ success: number; failed: number }> {
    const results = await Promise.allSettled(
      userIds.map(userId => this.sendToUser(userId, title, body, data)),
    );

    const success = results.filter(r => r.status === 'fulfilled' && r.value === true).length;
    const failed = results.length - success;

    console.log(`📊 Sent notifications: ${success} succeeded, ${failed} failed`);

    return { success, failed };
  }

  /**
   * Send push notification to all users with a specific role
   */
  async sendToRole(
    role: string,
    title: string,
    body: string,
    data: PushNotificationData,
  ): Promise<{ success: number; failed: number }> {
    try {
      // Get all users with this role that have FCM tokens
      const users = await this.usersService.findUsersByRole(role);
      const usersWithTokens = users.filter(u => u.fcmToken);

      console.log(`📤 Sending notification to ${usersWithTokens.length} ${role}s`);

      if (usersWithTokens.length === 0) {
        return { success: 0, failed: 0 };
      }

      const userIds = usersWithTokens.map(u => u.id);
      return await this.sendToMultipleUsers(userIds, title, body, data);
    } catch (error) {
      console.error(`❌ Error sending notification to role ${role}:`, error);
      return { success: 0, failed: 0 };
    }
  }

  /**
   * Send supervisor task notification
   */
  async sendSupervisorTaskNotification(
    supervisorId: string,
    taskId: string,
    taskDescription: string,
  ): Promise<boolean> {
    return this.sendToUser(
      supervisorId,
      'Nueva tarea asignada',
      taskDescription,
      {
        type: NotificationTypeEnum.SUPERVISOR_TASK,
        taskId,
      },
    );
  }

  /**
   * Send admin task notification
   */
  async sendAdminTaskNotification(
    adminId: string,
    taskId: string,
    taskDescription: string,
  ): Promise<boolean> {
    return this.sendToUser(
      adminId,
      'Nueva tarea pendiente',
      taskDescription,
      {
        type: NotificationTypeEnum.ADMIN_TASK,
        taskId,
      },
    );
  }

  /**
   * Send product approved notification
   */
  async sendProductApprovedNotification(
    userId: string,
    productId: string,
    productName: string,
  ): Promise<boolean> {
    return this.sendToUser(
      userId,
      'Producto aprobado',
      `El producto "${productName}" ha sido aprobado`,
      {
        type: NotificationTypeEnum.PRODUCT_APPROVED,
        productId,
      },
    );
  }

  /**
   * Send credit reminder notification
   */
  async sendCreditReminderNotification(
    userId: string,
    creditId: string,
    amount: number,
  ): Promise<boolean> {
    return this.sendToUser(
      userId,
      'Recordatorio de crédito',
      `Tienes un crédito pendiente de $${amount}`,
      {
        type: NotificationTypeEnum.CREDIT_REMINDER,
        creditId,
      },
    );
  }

  /**
   * Send order update notification
   */
  async sendOrderUpdateNotification(
    userId: string,
    orderId: string,
    status: string,
  ): Promise<boolean> {
    return this.sendToUser(
      userId,
      'Actualización de pedido',
      `Tu pedido ha sido ${status}`,
      {
        type: NotificationTypeEnum.ORDER_UPDATE,
        orderId,
      },
    );
  }

  /**
   * Send notification to all admins
   */
  async sendToAllAdmins(
    title: string,
    body: string,
    data: PushNotificationData,
  ): Promise<{ success: number; failed: number }> {
    return this.sendToRole('admin', title, body, data);
  }

  /**
   * Send notification to all supervisors
   */
  async sendToAllSupervisors(
    title: string,
    body: string,
    data: PushNotificationData,
  ): Promise<{ success: number; failed: number }> {
    return this.sendToRole('supervisor', title, body, data);
  }

  /**
   * Get notification channel ID based on type
   */
  private getChannelId(type: NotificationTypeEnum): string {
    switch (type) {
      case NotificationTypeEnum.SUPERVISOR_TASK:
        return 'supervisor_tasks';
      case NotificationTypeEnum.ADMIN_TASK:
        return 'admin_tasks';
      case NotificationTypeEnum.PRODUCT_UPDATE:
        return 'supervisor_tasks';  // Use same channel as supervisor tasks
      case NotificationTypeEnum.PRODUCT_APPROVED:
        return 'products';
      case NotificationTypeEnum.CREDIT_REMINDER:
        return 'credits';
      case NotificationTypeEnum.ORDER_UPDATE:
        return 'orders';
      default:
        return 'default_channel';
    }
  }
}
