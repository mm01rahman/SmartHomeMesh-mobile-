import { Module } from '@nestjs/common';
import { RoomsController } from './rooms.controller';
import { RoomsService } from './rooms.service';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';

@Module({
  controllers: [RoomsController],
  providers: [RoomsService, PrismaService, HomesService],
})
export class RoomsModule {}
