import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';
import { LoggerService } from '../logger/logger.service';

export interface SendRecoveryCodeEmailOptions {
  to: string;
  code: string;
  username: string;
}

@Injectable()
export class EmailService {
  private transporter: nodemailer.Transporter | null = null;
  private fromEmail: string;
  private readonly logger = new LoggerService('EmailService');

  constructor(private configService: ConfigService) {
    this.initializeBrevo();
  }

  /**
   * Initialize Brevo (Sendinblue) SMTP service
   */
  private initializeBrevo() {
    const brevoApiKey = this.configService.get<string>('BREVO_API_KEY');
    this.fromEmail = this.configService.get<string>('EMAIL_FROM') || 'La Bomba <noreply@labomba.com>';

    if (!brevoApiKey) {
      this.logger.warn(
        '⚠️ BREVO_API_KEY not configured. Password recovery emails will be logged to console only.'
      );
      return;
    }

    // Brevo SMTP configuration - NO domain required!
    this.transporter = nodemailer.createTransport({
      host: 'smtp-relay.brevo.com',
      port: 587,
      secure: false, // true for 465, false for other ports
      auth: {
        user: this.configService.get<string>('EMAIL_FROM') || 'noreply@labomba.com',
        pass: brevoApiKey, // Brevo SMTP key
      },
    });

    this.logger.log(`📧 Brevo SMTP service initialized`);
  }

  /**
   * Send password recovery code email
   */
  async sendRecoveryCode(options: SendRecoveryCodeEmailOptions): Promise<void> {
    const { to, code, username } = options;

    // If Brevo is not configured, log code and skip sending
    if (!this.transporter) {
      this.logger.warn(`⚠️ Brevo not configured. Recovery code for ${to}: ${code}`);
      throw new Error('Email service not configured');
    }

    try {
      const info = await this.transporter.sendMail({
        from: this.fromEmail,
        to,
        subject: 'Recuperación de Contraseña - La Bomba',
        html: this.getRecoveryEmailTemplate(code, username),
      });

      this.logger.log(`✅ Recovery email sent to ${to} (ID: ${info.messageId})`);
    } catch (error) {
      this.logger.error(`❌ Failed to send email to ${to}`, error instanceof Error ? error.stack : String(error));
      throw new Error('Failed to send recovery email');
    }
  }

  /**
   * HTML template for recovery email
   */
  private getRecoveryEmailTemplate(code: string, username: string): string {
    return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .container {
      background-color: #f9f9f9;
      border-radius: 10px;
      padding: 30px;
      border: 1px solid #ddd;
    }
    .header {
      text-align: center;
      margin-bottom: 30px;
    }
    .header h1 {
      color: #d32f2f;
      margin: 0;
    }
    .code-container {
      background-color: #fff;
      border: 2px dashed #d32f2f;
      border-radius: 8px;
      padding: 20px;
      text-align: center;
      margin: 30px 0;
    }
    .code {
      font-size: 32px;
      font-weight: bold;
      color: #d32f2f;
      letter-spacing: 8px;
      font-family: 'Courier New', monospace;
    }
    .message {
      margin: 20px 0;
    }
    .warning {
      background-color: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 15px;
      margin: 20px 0;
    }
    .footer {
      margin-top: 30px;
      text-align: center;
      font-size: 12px;
      color: #777;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔒 Recuperación de Contraseña</h1>
    </div>

    <div class="message">
      <p>Hola <strong>${username}</strong>,</p>
      <p>Recibimos una solicitud para restablecer la contraseña de tu cuenta en <strong>La Bomba</strong>.</p>
      <p>Tu código de verificación es:</p>
    </div>

    <div class="code-container">
      <div class="code">${code}</div>
    </div>

    <div class="message">
      <p>Ingresa este código en la aplicación para continuar con el proceso de recuperación.</p>
      <p><strong>Este código expira en 15 minutos.</strong></p>
    </div>

    <div class="warning">
      <p><strong>⚠️ Importante:</strong></p>
      <ul style="margin: 5px 0;">
        <li>Si no solicitaste este cambio, ignora este correo.</li>
        <li>Nunca compartas este código con nadie.</li>
        <li>Nuestro equipo nunca te pedirá este código por teléfono o email.</li>
      </ul>
    </div>

    <div class="footer">
      <p>Este es un correo automático, por favor no respondas.</p>
      <p>&copy; ${new Date().getFullYear()} La Bomba. Todos los derechos reservados.</p>
    </div>
  </div>
</body>
</html>
    `.trim();
  }

  /**
   * Verify email service is working
   */
  async verifyConnection(): Promise<boolean> {
    if (!this.transporter) {
      this.logger.warn('⚠️ Brevo not configured');
      return false;
    }

    try {
      await this.transporter.verify();
      this.logger.log('✅ Brevo SMTP connection verified');
      return true;
    } catch (error) {
      this.logger.error('❌ Email service check failed', error instanceof Error ? error.stack : String(error));
      return false;
    }
  }
}
