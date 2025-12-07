import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { HomesService } from './homes.service';
import { JwtAuthGuard } from '../auth/jwt.guard';

@Controller('homes')
@UseGuards(JwtAuthGuard)
export class HomesController {
  constructor(private readonly homesService: HomesService) {}

  @Post()
  create(@Body() body: { name: string; timezone: string }, @Req() req: any) {
    return this.homesService.create(body, req.user.sub);
  }

  @Get()
  list(@Req() req: any) {
    return this.homesService.listForUser(req.user.sub);
  }

  @Get(':id')
  get(@Param('id') id: string, @Req() req: any) {
    return this.homesService.get(Number(id), req.user.sub);
  }
}
