import { Injectable, UnauthorizedException, BadRequestException, NotFoundException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User, UserRole } from '../users/entities/user.entity';
import { PasswordRecoveryToken } from './entities/password-recovery-token.entity';
import { EmailService } from '../../common/email/email.service';
import { LoggerService } from '../../common/logger/logger.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { RequestPasswordResetDto } from './dto/request-password-reset.dto';
import { VerifyResetCodeDto } from './dto/verify-reset-code.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  private readonly logger = new LoggerService('AuthService');

  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    @InjectRepository(PasswordRecoveryToken)
    private recoveryTokensRepository: Repository<PasswordRecoveryToken>,
    private jwtService: JwtService,
    private emailService: EmailService,
  ) {}

  async validateUser(usernameOrEmail: string, password: string): Promise<any> {
    const user = await this.usersRepository.findOne({
      where: [
        { username: usernameOrEmail },
        { email: usernameOrEmail },
      ],
    });

    if (user && await bcrypt.compare(password, user.password)) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(loginDto: LoginDto) {
    const usernameOrEmail = loginDto.username || loginDto.email;
    if (!usernameOrEmail) {
      throw new UnauthorizedException('Username or email is required');
    }
    
    const user = await this.validateUser(usernameOrEmail, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { username: user.username, sub: user.id, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
      },
    };
  }

  async register(registerDto: RegisterDto) {
    const existingUser = await this.usersRepository.findOne({
      where: [
        { username: registerDto.username },
        { email: registerDto.email },
      ],
    });

    if (existingUser) {
      throw new UnauthorizedException('Username or email already exists');
    }

    const hashedPassword = await bcrypt.hash(registerDto.password, 10);
    
    const user = this.usersRepository.create({
      ...registerDto,
      password: hashedPassword,
    });

    await this.usersRepository.save(user);

    const { password, ...result } = user;
    return result;
  }

  async createAdmin() {
    // Check if admin already exists
    const existingAdmin = await this.usersRepository.findOne({
      where: { username: 'admin' },
    });

    if (existingAdmin) {
      return { message: 'Admin user already exists' };
    }

    const hashedPassword = await bcrypt.hash('admin123', 10);

    const adminUser = this.usersRepository.create({
      username: 'admin',
      email: 'admin@ejemplo.com',
      password: hashedPassword,
      role: UserRole.ADMIN,
    });

    await this.usersRepository.save(adminUser);

    return {
      message: 'Admin user created successfully',
      username: 'admin',
      email: 'admin@ejemplo.com',
      password: 'admin123'
    };
  }

  /**
   * Request password reset - sends recovery code to user's email
   */
  async requestPasswordReset(dto: RequestPasswordResetDto): Promise<{ message: string }> {
    const { email } = dto;

    // Find user by email
    const user = await this.usersRepository.findOne({ where: { email } });

    // Security: Don't reveal if email exists or not
    if (!user) {
      this.logger.warn(`Password reset requested for non-existent email: ${email}`);
      // Return success message anyway to prevent email enumeration
      return {
        message: 'Si el email existe, recibirás un código de recuperación'
      };
    }

    // Invalidate previous unused tokens for this user
    await this.recoveryTokensRepository.update(
      { userId: user.id, used: false },
      { used: true, usedAt: new Date() }
    );

    // Generate 6-digit code
    const code = this.generateRecoveryCode();

    // Token expires in 15 minutes
    const expiresAt = new Date();
    expiresAt.setMinutes(expiresAt.getMinutes() + 15);

    // Save recovery token
    const recoveryToken = this.recoveryTokensRepository.create({
      userId: user.id,
      token: code,
      expiresAt,
    });

    await this.recoveryTokensRepository.save(recoveryToken);

    // Send email with recovery code
    // In development mode, skip email sending to avoid timeouts
    const isDevelopment = process.env.NODE_ENV !== 'production';

    if (isDevelopment || !process.env.EMAIL_USER) {
      // Development mode or no email configured: return code in response
      this.logger.warn(`🔑 Recovery code for ${user.email}: ${code}`);
      return {
        message: 'Código de recuperación generado',
        code, // Return code directly in development
      };
    }

    // Production mode: send email
    try {
      await this.emailService.sendRecoveryCode({
        to: user.email,
        code,
        username: user.username,
      });

      this.logger.log(`Recovery code sent to ${user.email}`);
    } catch (error) {
      this.logger.error(`Failed to send recovery email to ${user.email}`, error.stack);
      // If email fails, log the code
      this.logger.warn(`🔑 Recovery code for ${user.email}: ${code}`);
    }

    return {
      message: 'Si el email existe, recibirás un código de recuperación'
    };
  }

  /**
   * Verify reset code - check if code is valid
   */
  async verifyResetCode(dto: VerifyResetCodeDto): Promise<{ valid: boolean; message: string }> {
    const { email, code } = dto;

    const user = await this.usersRepository.findOne({ where: { email } });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const recoveryToken = await this.recoveryTokensRepository.findOne({
      where: {
        userId: user.id,
        token: code,
      },
    });

    if (!recoveryToken) {
      throw new BadRequestException('Código inválido');
    }

    if (!recoveryToken.isValid()) {
      if (recoveryToken.used) {
        throw new BadRequestException('Este código ya fue utilizado');
      }
      if (new Date() > recoveryToken.expiresAt) {
        throw new BadRequestException('El código ha expirado');
      }
      throw new BadRequestException('Código inválido');
    }

    return {
      valid: true,
      message: 'Código verificado correctamente'
    };
  }

  /**
   * Reset password with valid code
   */
  async resetPassword(dto: ResetPasswordDto): Promise<{ message: string }> {
    const { email, code, newPassword } = dto;

    const user = await this.usersRepository.findOne({ where: { email } });

    if (!user) {
      throw new NotFoundException('Usuario no encontrado');
    }

    const recoveryToken = await this.recoveryTokensRepository.findOne({
      where: {
        userId: user.id,
        token: code,
      },
    });

    if (!recoveryToken || !recoveryToken.isValid()) {
      throw new BadRequestException('Código inválido o expirado');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update user password
    user.password = hashedPassword;
    await this.usersRepository.save(user);

    // Mark token as used
    recoveryToken.markAsUsed();
    await this.recoveryTokensRepository.save(recoveryToken);

    this.logger.log(`Password reset successful for user: ${user.username}`);

    return {
      message: 'Contraseña actualizada exitosamente'
    };
  }

  /**
   * Clean up expired tokens (can be run as a cron job)
   */
  async cleanupExpiredTokens(): Promise<number> {
    const result = await this.recoveryTokensRepository.delete({
      expiresAt: LessThan(new Date()),
    });

    this.logger.log(`Cleaned up ${result.affected} expired recovery tokens`);
    return result.affected || 0;
  }

  /**
   * Generate random 6-digit code
   */
  private generateRecoveryCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }
}