import { Module } from '@nestjs/common';
import { AutomationsController } from './automations.controller';
import { AutomationsService } from './automations.service';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { DevicesService } from '../devices/devices.service';
import { MqttService } from '../mqtt/mqtt.service';
import { NodesService } from '../nodes/nodes.service';

@Module({
  controllers: [AutomationsController],
  providers: [AutomationsService, PrismaService, HomesService, DevicesService, MqttService, NodesService],
})
export class AutomationsModule {}
