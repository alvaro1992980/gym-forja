import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AppConfigService } from '../../config/app-config.service';
import { AuthController, MeController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { TokensService } from './tokens.service';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      inject: [AppConfigService],
      useFactory: (config: AppConfigService) => ({
        secret: config.get('JWT_ACCESS_SECRET'),
        signOptions: {
          algorithm: 'HS256',
          // Validated format like "15m" (see env.validation.ts).
          expiresIn: config.get('JWT_ACCESS_TTL') as `${number}${'s' | 'm' | 'h' | 'd'}`,
        },
      }),
    }),
  ],
  controllers: [AuthController, MeController],
  providers: [AuthService, TokensService, JwtStrategy],
  exports: [TokensService],
})
export class AuthModule {}
