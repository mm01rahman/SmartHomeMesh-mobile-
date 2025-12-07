import { Module } from '@nestjs/common';
import { NodesService } from './nodes.service';
import { NodesController } from './nodes.controller';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';

@Module({
  controllers: [NodesController],
  providers: [NodesService, PrismaService, HomesService],
  exports: [NodesService],
})
export class NodesModule {}
