import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('register')
  async signup(@Body() body: { email: string; password: string; name: string }) {
    return this.authService.signup(body.email, body.password, body.name);
  }

  @Post('login')
  async signin(@Body() body: { email: string; password: string }) {
    return this.authService.signin(body.email, body.password);
  }

  @UseGuards(JwtAuthGuard)
  @Post('refresh')
  async refresh(@Req() req: any) {
    return this.authService.refresh(req.user.sub, req.user.email);
  }

  @Post('logout')
  async logout() {
    return { success: true };
  }
}
