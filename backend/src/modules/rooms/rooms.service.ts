import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';

@Injectable()
export class RoomsService {
  constructor(private prisma: PrismaService, private homesService: HomesService) {}

  async create(homeId: number, userId: number, data: { name: string; icon?: string; order?: number }) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.room.create({ data: { ...data, homeId } });
  }

  async list(homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.room.findMany({ where: { homeId } });
  }

  async update(roomId: number, userId: number, data: any) {
    const room = await this.prisma.room.findUnique({ where: { id: roomId } });
    if (!room) return null;
    await this.homesService.assertUserInHome(room.homeId, userId);
    return this.prisma.room.update({ where: { id: roomId }, data });
  }

  async delete(roomId: number, userId: number) {
    const room = await this.prisma.room.findUnique({ where: { id: roomId } });
    if (!room) return null;
    await this.homesService.assertUserInHome(room.homeId, userId);
    return this.prisma.room.delete({ where: { id: roomId } });
  }
}
