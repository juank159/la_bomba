import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Resend } from 'resend';
import { LoggerService } from '../logger/logger.service';

export interface SendRecoveryCodeEmailOptions {
  to: string;
  code: string;
  username: string;
}

@Injectable()
export class EmailService {
  private resend: Resend | null = null;
  private fromEmail: string;
  private readonly logger = new LoggerService('EmailService');

  constructor(private configService: ConfigService) {
    this.initializeResend();
  }

  /**
   * Initialize Resend email service
   */
  private initializeResend() {
    const resendApiKey = this.configService.get<string>('RESEND_API_KEY');
    // Use Resend's free shared domain - NO custom domain needed
    this.fromEmail = 'onboarding@resend.dev';

    if (!resendApiKey) {
      this.logger.warn(
        '⚠️ RESEND_API_KEY not configured. Password recovery emails will be logged to console only.'
      );
      return;
    }

    this.resend = new Resend(resendApiKey);
    this.logger.log(`📧 Resend email service initialized with onboarding@resend.dev`);
  }

  /**
   * Send password recovery code email
   */
  async sendRecoveryCode(options: SendRecoveryCodeEmailOptions): Promise<void> {
    const { to, code, username } = options;

    // If Resend is not configured, log code and skip sending
    if (!this.resend) {
      this.logger.warn(`⚠️ Resend not configured. Recovery code for ${to}: ${code}`);
      throw new Error('Email service not configured');
    }

    try {
      const { data, error } = await this.resend.emails.send({
        from: this.fromEmail,
        to: [to],
        subject: 'Recuperación de Contraseña - La Bomba',
        html: this.getRecoveryEmailTemplate(code, username),
      });

      if (error) {
        this.logger.error(`❌ Resend API error for ${to}:`, JSON.stringify(error));
        throw new Error(`Resend error: ${JSON.stringify(error)}`);
      }

      this.logger.log(`✅ Recovery email sent to ${to} (ID: ${data?.id})`);
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
    if (!this.resend) {
      this.logger.warn('⚠️ Resend not configured');
      return false;
    }

    try {
      // Resend doesn't have a verify method, so we just check if it's initialized
      this.logger.log('✅ Resend email service is configured');
      return true;
    } catch (error) {
      this.logger.error('❌ Email service check failed', error.stack);
      return false;
    }
  }
}
