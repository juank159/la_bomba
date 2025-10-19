import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User, UserRole } from '../users/entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
    private jwtService: JwtService,
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
}