import { Credit } from '../../credits/entities/credit.entity';
export declare class Client {
    id: string;
    nombre: string;
    celular: string;
    email: string;
    direccion: string;
    isActive: boolean;
    credits: Credit[];
    createdAt: Date;
    updatedAt: Date;
}
