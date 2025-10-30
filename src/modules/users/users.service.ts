import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
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
      select: ['id', 'username', 'email', 'role', 'isActive', 'createdAt', 'fcmToken'],
    });
  }

  async findByUsername(username: string): Promise<User> {
    return this.usersRepository.findOne({ where: { username } });
  }

  async updateFcmToken(userId: string, fcmToken: string): Promise<User> {
    await this.usersRepository.update(userId, { fcmToken });
    return this.findOne(userId);
  }

  async clearFcmToken(userId: string): Promise<void> {
    await this.usersRepository.update(userId, { fcmToken: null });
  }

  async findByFcmToken(fcmToken: string): Promise<User> {
    return this.usersRepository.findOne({ where: { fcmToken } });
  }

  async findUsersByRole(role: string): Promise<User[]> {
    return this.usersRepository.find({
      where: { role: role as any, isActive: true },
      select: ['id', 'username', 'email', 'role', 'fcmToken'],
    });
  }
}