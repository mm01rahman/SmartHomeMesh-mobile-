import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { AuthModule } from './modules/auth/auth.module';
import { HomesModule } from './modules/homes/homes.module';
import { NodesModule } from './modules/nodes/nodes.module';
import { DevicesModule } from './modules/devices/devices.module';
import { RoomsModule } from './modules/rooms/rooms.module';
import { ScenesModule } from './modules/scenes/scenes.module';
import { AutomationsModule } from './modules/automations/automations.module';
import { MqttModule } from './modules/mqtt/mqtt.module';
import { PrismaService } from './prisma.service';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    AuthModule,
    HomesModule,
    NodesModule,
    DevicesModule,
    RoomsModule,
    ScenesModule,
    AutomationsModule,
    MqttModule,
  ],
  providers: [PrismaService],
})
export class AppModule {}
