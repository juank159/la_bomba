import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { UserRole } from '../../modules/users/entities/user.entity';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!requiredRoles) {
      return true;
    }

    const { user } = context.switchToHttp().getRequest();

    // Debug logging
    console.log('🔐 RolesGuard Check:', {
      userRole: user?.role,
      userRoleType: typeof user?.role,
      requiredRoles,
      requiredRolesTypes: requiredRoles.map(r => typeof r),
      userId: user?.userId,
      username: user?.username,
    });

    const hasPermission = requiredRoles.some((role) => user.role === role);
    console.log('🔐 Permission result:', hasPermission);

    return hasPermission;
  }
}