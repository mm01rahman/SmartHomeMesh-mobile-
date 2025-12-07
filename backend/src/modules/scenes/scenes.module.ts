import { Module } from '@nestjs/common';
import { ScenesController } from './scenes.controller';
import { ScenesService } from './scenes.service';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { DevicesService } from '../devices/devices.service';
import { MqttService } from '../mqtt/mqtt.service';
import { NodesService } from '../nodes/nodes.service';

@Module({
  controllers: [ScenesController],
  providers: [ScenesService, PrismaService, HomesService, DevicesService, MqttService, NodesService],
})
export class ScenesModule {}
