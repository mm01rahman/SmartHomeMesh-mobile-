import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { AutomationsService } from './automations.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
@UseGuards(JwtAuthGuard)
export class AutomationsController {
  constructor(private readonly automationsService: AutomationsService) {}

  @Get('homes/:homeId/automations')
  list(@Param('homeId') homeId: string, @Req() req: any) {
    return this.automationsService.list(Number(homeId), req.user.sub);
  }

  @Post('homes/:homeId/automations')
  create(@Param('homeId') homeId: string, @Body() body: any, @Req() req: any) {
    return this.automationsService.create(Number(homeId), req.user.sub, body);
  }

  @Patch('automations/:id')
  update(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.automationsService.update(Number(id), req.user.sub, body);
  }
}
