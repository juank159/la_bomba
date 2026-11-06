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

      // También al navegador, si el usuario tiene la app web abierta con
      // notificaciones activadas. Independiente del celular: si uno falla,
      // el otro igual llega.
      const webSent = user?.webFcmToken
        ? await this.sendWebPush(userId, user.webFcmToken, title, body, data)
        : false;

      if (!user || !user.fcmToken) {
        if (webSent) return true;
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
        await this.usersService.clearFcmToken(userId, 'mobile');
      }

      return false;
    }
  }

  /** Notificación al navegador (app web). Nunca lanza. */
  private async sendWebPush(
    userId: string,
    token: string,
    title: string,
    body: string,
    data: PushNotificationData,
  ): Promise<boolean> {
    try {
      await admin.messaging().send({
        token,
        notification: { title, body },
        data: Object.fromEntries(
          Object.entries(data).filter(([, v]) => typeof v === 'string' && v !== ''),
        ) as Record<string, string>,
        webpush: {
          notification: { icon: '/icons/Icon-192.png', badge: '/icons/Icon-192.png' },
          fcmOptions: { link: process.env.WEB_APP_URL || 'https://labombafrontend.vercel.app' },
        },
      });
      return true;
    } catch (error) {
      console.error(`❌ Error enviando push web a ${userId}: ${error?.message ?? error}`);
      if (error?.code === 'messaging/invalid-registration-token' ||
          error?.code === 'messaging/registration-token-not-registered') {
        await this.usersService.clearFcmToken(userId, 'web').catch(() => undefined);
      }
      return false;
    }
  }

  /**
   * Push "pago Bre-B recibido" apenas el banco lo confirma. Le llega SOLO a:
   *  - el cajero que hizo el cobro (verdulero o admin): su diálogo de cobro
   *    pasa a "¡Pago confirmado!" al instante y la app lo anuncia por voz;
   *  - todos los administradores activos, para que vean cada pago que entra.
   * Ningún otro rol (supervisor, digitador, empleado) recibe estos avisos,
   * aunque por algún error quedaran como "cajero" del cobro.
   * Nunca lanza: si falla, el polling del diálogo igual confirma.
   */
  async sendBrebPaymentConfirmed(
    initiatorUserId: string,
    chargeId: string,
    amount: number,
    payerName: string,
    bankLabel: string,
    context: { module?: string; cashier?: string; saleNumber?: number | null } = {},
  ): Promise<number> {
    if (!this.firebaseApp) return 0;
    const allowed = new Set(['admin', 'verdulero']);
    let users: Array<{ id: string; role: string; fcmToken?: string; webFcmToken?: string; isActive?: boolean }> = [];
    try {
      const initiator = await this.usersService.findOne(initiatorUserId);
      const admins = await this.usersService.findUsersByRole('admin');
      users = [initiator, ...admins].filter(
        (u): u is any => !!u && u.isActive !== false && allowed.has(String(u.role)),
      );
    } catch (error) {
      console.error(`❌ Error buscando destinatarios del push Bre-B: ${error?.message ?? error}`);
      return 0;
    }

    // Un envío por DISPOSITIVO (celular y/o navegador de cada usuario), sin
    // duplicados: el admin que cobró es a la vez cajero y admin, y un mismo
    // celular/navegador no debe sonar dos veces.
    const seenUsers = new Set<string>();
    const seenTokens = new Set<string>();
    const recipients: Array<{ id: string; token: string; kind: 'mobile' | 'web' }> = [];
    for (const u of users) {
      if (seenUsers.has(u.id)) continue;
      seenUsers.add(u.id);
      for (const [token, kind] of [[u.fcmToken, 'mobile'], [u.webFcmToken, 'web']] as const) {
        if (!token || seenTokens.has(token)) continue;
        seenTokens.add(token);
        recipients.push({ id: u.id, token, kind });
      }
    }

    const amountStr = Math.round(amount).toString();
    const amountFmt = '$' + Math.round(amount).toLocaleString('es-CO');
    const where = context.module === 'invoices' ? 'Facturación' : 'Verduras';
    const what = context.module === 'invoices' ? 'Factura' : 'Venta';
    const saleTxt = context.saleNumber ? ` · ${what} #${String(context.saleNumber).padStart(6, '0')}` : '';

    let sent = 0;
    for (const u of recipients) {
      const isInitiator = u.id === initiatorUserId;
      // Al cajero: lo justo para confirmar. Al admin: además de qué caja y
      // quién cobró, para que sepa de dónde viene la plata.
      const body = isInitiator
        ? `${amountFmt}${payerName ? ' · ' + payerName : ''}`
        : `${amountFmt}${payerName ? ' de ' + payerName : ''} · ${where}` +
          `${context.cashier ? ', cobró ' + context.cashier : ''}${saleTxt}`;
      const title = `💰 Pago Bre-B recibido${bankLabel ? ' — ' + bankLabel : ''}`;
      // Lo que se dice en voz alta (igual que Food App): al cajero de qué
      // banco llegó; al admin, de qué caja, para que no lo confunda.
      const voice = isInitiator
        ? (bankLabel ? `Recibiste en ${bankLabel}, ${amountStr} pesos` : `Pago recibido, ${amountStr} pesos`)
        : `Pago Bre-B en ${where.toLowerCase()}, ${amountStr} pesos`;
      const data = {
        type: 'breb_payment_confirmed',
        charge_id: chargeId,
        amount: amountStr,
        payer_name: payerName ?? '',
        bank: bankLabel ?? '',
        module: context.module ?? '',
        cashier: context.cashier ?? '',
        sale_number: context.saleNumber ? String(context.saleNumber) : '',
        for_initiator: isInitiator ? 'true' : 'false',
        voice,
      };
      try {
        if (u.kind === 'web') {
          await admin.messaging().send({
            token: u.token,
            notification: { title, body },
            data,
            webpush: {
              headers: { Urgency: 'high', TTL: '600' },
              notification: {
                icon: '/icons/Icon-192.png',
                badge: '/icons/Icon-192.png',
                tag: `breb-${chargeId}`,
                renotify: true,
              },
              fcmOptions: { link: process.env.WEB_APP_URL || 'https://labombafrontend.vercel.app' },
            },
          });
        } else {
          // 1) La notificación visible: confiable, llega siempre.
          await admin.messaging().send({
            token: u.token,
            notification: { title, body },
            data,
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
          // 2) Un mensaje SOLO de datos para la voz con la app en segundo
          // plano o el celular bloqueado: Android solo despierta a la app
          // para mensajes sin bloque `notification` (con uno, la bandeja del
          // sistema lo muestra sola y la app nunca se entera). Va aparte para
          // que, si este se pierde, la notificación de arriba igual llegue.
          // Mismo patrón que la alerta de pedidos QR de Food App.
          await admin.messaging().send({
            token: u.token,
            data: { type: 'breb_payment_voice', charge_id: chargeId, voice },
            android: { priority: 'high', ttl: 60_000 },
          }).catch((e) => console.warn(`⚠️ Push de voz Bre-B a ${u.id} no salió: ${e?.message ?? e}`));
        }
        sent++;
      } catch (error) {
        console.error(`❌ Error enviando push Bre-B (${u.kind}) a ${u.id}: ${error?.message ?? error}`);
        if (error?.code === 'messaging/invalid-registration-token' ||
            error?.code === 'messaging/registration-token-not-registered') {
          await this.usersService.clearFcmToken(u.id, u.kind).catch(() => undefined);
        }
      }
    }
    return sent;
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
