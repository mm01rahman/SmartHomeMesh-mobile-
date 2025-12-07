import { Body, Controller, Delete, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { RoomsService } from './rooms.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
@UseGuards(JwtAuthGuard)
export class RoomsController {
  constructor(private readonly roomsService: RoomsService) {}

  @Post('homes/:homeId/rooms')
  create(@Param('homeId') homeId: string, @Body() body: any, @Req() req: any) {
    return this.roomsService.create(Number(homeId), req.user.sub, body);
  }

  @Get('homes/:homeId/rooms')
  list(@Param('homeId') homeId: string, @Req() req: any) {
    return this.roomsService.list(Number(homeId), req.user.sub);
  }

  @Patch('rooms/:id')
  update(@Param('id') id: string, @Body() body: any, @Req() req: any) {
    return this.roomsService.update(Number(id), req.user.sub, body);
  }

  @Delete('rooms/:id')
  delete(@Param('id') id: string, @Req() req: any) {
    return this.roomsService.delete(Number(id), req.user.sub);
  }
}
