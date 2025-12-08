import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
@UseGuards(JwtAuthGuard)
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get('homes/:homeId/devices')
  list(@Param('homeId') homeId: string, @Req() req: any) {
    return this.devicesService.listForHome(Number(homeId), req.user.sub);
  }

  @Patch('devices/:id')
  update(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.devicesService.update(Number(id), req.user.sub, body);
  }

  @Post('devices/:id/toggle')
  command(@Param('id') id: string, @Body() body: { state: boolean }, @Req() req: any) {
    return this.devicesService.sendCommand(Number(id), req.user.sub, body.state ? 1 : 0);
  }

  @Post('commands/batch')
  batch(@Body() body: { device_id: number; state: number }[], @Req() req: any) {
    return this.devicesService.batchCommand(body, req.user.sub);
  }
}
