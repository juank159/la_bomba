import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
export declare class AuthController {
    private authService;
    constructor(authService: AuthService);
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
        role: import("../users/entities/user.entity").UserRole;
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
    getProfile(req: any): Promise<{
        id: any;
        username: any;
        role: any;
    }>;
}
