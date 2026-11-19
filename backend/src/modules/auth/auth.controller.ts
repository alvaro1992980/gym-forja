import { Body, Controller, Get, HttpCode, HttpStatus, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import type { AuthUser } from '../../common/auth/auth-user';
import { AllowWhenPasswordChangeRequired, CurrentUser, Public } from '../../common/auth/decorators';
import { AuthService } from './auth.service';
import {
  AuthResponseDto,
  ChangePasswordDto,
  LoginDto,
  LogoutDto,
  MeResponseDto,
  RefreshDto,
} from './dto';

/** Login rate limit: 5 attempts per minute per IP + phone (section 8). */
export const LOGIN_RATE_LIMIT = { limit: 5, ttl: 60_000 };

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Public()
  @Throttle({ default: LOGIN_RATE_LIMIT })
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: AuthResponseDto })
  login(@Body() dto: LoginDto): Promise<AuthResponseDto> {
    return this.auth.login(dto);
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOkResponse({ type: AuthResponseDto })
  refresh(@Body() dto: RefreshDto): Promise<AuthResponseDto> {
    return this.auth.refresh(dto.refreshToken);
  }

  @ApiBearerAuth()
  @AllowWhenPasswordChangeRequired()
  @Post('logout')
  @HttpCode(HttpStatus.NO_CONTENT)
  logout(@CurrentUser() user: AuthUser, @Body() dto: LogoutDto): Promise<void> {
    return this.auth.logout(user.id, dto);
  }

  @ApiBearerAuth()
  @AllowWhenPasswordChangeRequired()
  @Post('change-password')
  @HttpCode(HttpStatus.NO_CONTENT)
  changePassword(@CurrentUser() user: AuthUser, @Body() dto: ChangePasswordDto): Promise<void> {
    return this.auth.changePassword(user.id, dto);
  }
}

@ApiTags('me')
@ApiBearerAuth()
@Controller('me')
export class MeController {
  constructor(private readonly auth: AuthService) {}

  @AllowWhenPasswordChangeRequired()
  @Get()
  @ApiOkResponse({ type: MeResponseDto })
  me(@CurrentUser() user: AuthUser): Promise<MeResponseDto> {
    return this.auth.me(user.id);
  }
}
