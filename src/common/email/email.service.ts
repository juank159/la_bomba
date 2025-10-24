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
  private transporter: nodemailer.Transporter;
  private readonly logger = new LoggerService('EmailService');

  constructor(private configService: ConfigService) {
    this.createTransporter();
  }

  /**
   * Create email transporter
   */
  private createTransporter() {
    // Configuración para Gmail (puedes cambiar por otro proveedor)
    const emailUser = this.configService.get<string>('EMAIL_USER');
    const emailPass = this.configService.get<string>('EMAIL_PASSWORD');

    if (!emailUser || !emailPass) {
      this.logger.warn(
        '⚠️ Email credentials not configured. Password recovery emails will be logged to console.'
      );
      // Usar transporter de prueba que solo logea
      this.transporter = nodemailer.createTransport({
        streamTransport: true,
        newline: 'unix',
        buffer: true,
      });
      return;
    }

    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: emailUser,
        pass: emailPass, // App password, not regular password
      },
    });

    this.logger.log(`📧 Email service initialized with ${emailUser}`);
  }

  /**
   * Send password recovery code email
   */
  async sendRecoveryCode(options: SendRecoveryCodeEmailOptions): Promise<void> {
    const { to, code, username } = options;

    const mailOptions = {
      from: `"La Bomba" <${this.configService.get<string>('EMAIL_USER')}>`,
      to,
      subject: 'Recuperación de Contraseña - La Bomba',
      html: this.getRecoveryEmailTemplate(code, username),
    };

    try {
      const info = await this.transporter.sendMail(mailOptions);

      // Si estamos en modo de prueba, loguear el código
      if (info.response && info.response.toString().includes('stream')) {
        this.logger.warn(
          `⚠️ EMAIL NOT SENT (test mode). Recovery code for ${to}: ${code}`
        );
      } else {
        this.logger.log(`✅ Recovery email sent to ${to}`);
      }
    } catch (error) {
      this.logger.error(`❌ Failed to send email to ${to}`, error.stack);

      // En desarrollo, loguear el código aunque falle el envío
      if (this.configService.get('environment') === 'development') {
        this.logger.warn(`🔑 Recovery code for ${to}: ${code}`);
      }

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
    try {
      await this.transporter.verify();
      this.logger.log('✅ Email service connection verified');
      return true;
    } catch (error) {
      this.logger.error('❌ Email service connection failed', error.stack);
      return false;
    }
  }
}
