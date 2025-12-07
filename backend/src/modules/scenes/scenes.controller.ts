import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
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
  create(@Param('homeId') homeId: string, @Body() body: any, @Req() req: any) {
    return this.scenesService.create(Number(homeId), req.user.sub, body);
  }

  @Patch('scenes/:id')
  update(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.scenesService.update(Number(id), req.user.sub, body);
  }

  @Post('scenes/:id/run')
  run(@Param('id') id: string, @Req() req: any) {
    return this.scenesService.run(Number(id), req.user.sub);
  }
}
