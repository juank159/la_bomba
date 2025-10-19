import { JwtService } from '@nestjs/jwt';
import { Repository } from 'typeorm';
import { User, UserRole } from '../users/entities/user.entity';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
export declare class AuthService {
    private usersRepository;
    private jwtService;
    constructor(usersRepository: Repository<User>, jwtService: JwtService);
    validateUser(usernameOrEmail: string, password: string): Promise<any>;
    login(loginDto: LoginDto): Promise<{
        access_token: string;
        user: {
            id: any;
            username: any;
            email: any;
            role: any;
        };
    }>;
    register(registerDto: RegisterDto): Promise<{
        id: string;
        username: string;
        email: string;
        role: UserRole;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
    }>;
    createAdmin(): Promise<{
        message: string;
        username?: undefined;
        email?: undefined;
        password?: undefined;
    } | {
        message: string;
        username: string;
        email: string;
        password: string;
    }>;
}
