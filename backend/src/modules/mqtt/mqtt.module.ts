import { Module } from '@nestjs/common';
import { MqttService } from './mqtt.service';
import { PrismaService } from '../../prisma.service';
import { NodesService } from '../nodes/nodes.service';
import { HomesService } from '../homes/homes.service';

@Module({
  providers: [MqttService, PrismaService, NodesService, HomesService],
  exports: [MqttService],
})
export class MqttModule {}
