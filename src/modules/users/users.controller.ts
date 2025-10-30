import { Controller, Get, Param, Put, Body, UseGuards, Request } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from './entities/user.entity';

@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(UserRole.ADMIN)
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  @Roles(UserRole.ADMIN)
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Put('fcm-token')
  async updateFcmToken(@Request() req, @Body('fcmToken') fcmToken: string) {
    const userId = req.user.userId;
    return this.usersService.updateFcmToken(userId, fcmToken);
  }

  @Put('fcm-token/clear')
  async clearFcmToken(@Request() req) {
    const userId = req.user.userId;
    await this.usersService.clearFcmToken(userId);
    return { message: 'FCM token cleared successfully' };
  }
}