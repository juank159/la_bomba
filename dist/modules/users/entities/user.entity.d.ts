export declare enum UserRole {
    ADMIN = "admin",
    SUPERVISOR = "supervisor",
    EMPLOYEE = "employee"
}
export declare class User {
    id: string;
    username: string;
    email: string;
    password: string;
    role: UserRole;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
