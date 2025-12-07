import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { NodesService } from './nodes.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller()
@UseGuards(JwtAuthGuard)
export class NodesController {
  constructor(private readonly nodesService: NodesService) {}

  @Get('homes/:homeId/nodes')
  list(@Param('homeId') homeId: string, @Req() req: any) {
    return this.nodesService.listForHome(Number(homeId), req.user.sub);
  }

  @Get('nodes/:id')
  get(@Param('id') id: string, @Req() req: any) {
    return this.nodesService.getById(Number(id), req.user.sub);
  }

  @Post('nodes/claim')
  claim(@Body() body: { node_id: string; home_id: number }, @Req() req: any) {
    return this.nodesService.claim(body.node_id, Number(body.home_id), req.user.sub);
  }
}
