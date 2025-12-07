import { Module } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { DevicesController } from './devices.controller';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { NodesService } from '../nodes/nodes.service';
import { MqttService } from '../mqtt/mqtt.service';

@Module({
  controllers: [DevicesController],
  providers: [DevicesService, PrismaService, HomesService, NodesService, MqttService],
  exports: [DevicesService],
})
export class DevicesModule {}
