import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findAll(): Promise<User[]> {
    return this.usersRepository.find({
      select: ['id', 'username', 'email', 'role', 'isActive', 'createdAt'],
    });
  }

  async findOne(id: string): Promise<User> {
    return this.usersRepository.findOne({
      where: { id },
      select: ['id', 'username', 'email', 'role', 'isActive', 'createdAt', 'fcmToken', 'webFcmToken'],
    });
  }

  async findByUsername(username: string): Promise<User> {
    return this.usersRepository.findOne({ where: { username } });
  }

  async updateFcmToken(userId: string, fcmToken: string, platform?: string): Promise<User> {
    const field = platform === 'web' ? 'webFcmToken' : 'fcmToken';
    // Un dispositivo = un usuario: si este token estaba guardado en otro
    // usuario (celular/computador compartido, sesión que venció sin cerrar),
    // se le quita. Si no, el que entró ahora recibiría las notificaciones
    // del anterior (ej. un supervisor viendo los pagos Bre-B del admin).
    if (fcmToken) {
      await this.usersRepository.update({ fcmToken, id: Not(userId) }, { fcmToken: null });
      await this.usersRepository.update({ webFcmToken: fcmToken, id: Not(userId) }, { webFcmToken: null });
    }
    await this.usersRepository.update(userId, { [field]: fcmToken });
    return this.findOne(userId);
  }

  /** platform: 'web' = solo el navegador, 'mobile' = solo el celular, sin dato = los dos. */
  async clearFcmToken(userId: string, platform?: string): Promise<void> {
    if (platform === 'web') {
      await this.usersRepository.update(userId, { webFcmToken: null });
    } else if (platform === 'mobile') {
      await this.usersRepository.update(userId, { fcmToken: null });
    } else {
      await this.usersRepository.update(userId, { fcmToken: null, webFcmToken: null });
    }
  }

  async findByFcmToken(fcmToken: string): Promise<User> {
    return this.usersRepository.findOne({ where: { fcmToken } });
  }

  async findUsersByRole(role: string): Promise<User[]> {
    return this.usersRepository.find({
      where: { role: role as any, isActive: true },
      select: ['id', 'username', 'email', 'role', 'fcmToken', 'webFcmToken'],
    });
  }
}