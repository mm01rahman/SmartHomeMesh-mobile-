import { Body, Controller, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { NodesService } from './nodes.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller('homes/:homeId/nodes')
@UseGuards(JwtAuthGuard)
export class NodesController {
  constructor(private readonly nodesService: NodesService) {}

  @Get()
  list(@Param('homeId') homeId: string, @Req() req: any) {
    return this.nodesService.listForHome(Number(homeId), req.user.sub);
  }

  @Get(':nodeId')
  get(@Param('homeId') homeId: string, @Param('nodeId') nodeId: string, @Req() req: any) {
    return this.nodesService.getByHomeAndNode(Number(homeId), nodeId, req.user.sub);
  }

  @Patch(':nodeId/claim')
  claim(@Param('homeId') homeId: string, @Param('nodeId') nodeId: string, @Req() req: any) {
    return this.nodesService.claim(nodeId, Number(homeId), req.user.sub);
  }
}
