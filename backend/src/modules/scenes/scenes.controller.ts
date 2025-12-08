import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ScenesService } from './scenes.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
@UseGuards(JwtAuthGuard)
export class ScenesController {
  constructor(private readonly scenesService: ScenesService) {}

  @Get('homes/:homeId/scenes')
  list(@Param('homeId') homeId: string, @Req() req: any) {
    return this.scenesService.list(Number(homeId), req.user.sub);
  }

  @Post('homes/:homeId/scenes')
  create(
    @Param('homeId') homeId: string,
    @Body() body: { name: string; icon?: string; actions?: { deviceId: number; desiredState: number }[] },
    @Req() req: any,
  ) {
    return this.scenesService.create(Number(homeId), req.user.sub, body);
  }

  @Post('scenes/:sceneId/activate')
  run(@Param('sceneId') sceneId: string, @Req() req: any) {
    return this.scenesService.run(Number(sceneId), req.user.sub);
  }
}
