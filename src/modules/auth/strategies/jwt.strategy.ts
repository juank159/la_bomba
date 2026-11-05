import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('jwt.secret'),
    });
  }

  async validate(payload: any) {
    // El token de renovación (30 días) solo sirve en POST /auth/refresh,
    // nunca como token de acceso.
    if (payload?.type === 'refresh') {
      throw new UnauthorizedException('Token inválido');
    }
    return { userId: payload.sub, username: payload.username, role: payload.role };
  }
}