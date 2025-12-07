import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { DevicesService } from '../devices/devices.service';

@Injectable()
export class ScenesService {
  constructor(
    private prisma: PrismaService,
    private homesService: HomesService,
    private devicesService: DevicesService,
  ) {}

  async list(homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.scene.findMany({ where: { homeId }, include: { actions: true } });
  }

  async create(homeId: number, userId: number, data: { name: string; icon?: string; actions?: { deviceId: number; desiredState: number }[] }) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.scene.create({
      data: {
        name: data.name,
        icon: data.icon,
        homeId,
        actions: { create: data.actions?.map((a) => ({ deviceId: a.deviceId, desiredState: a.desiredState })) || [] },
      },
    });
  }

  async update(sceneId: number, userId: number, data: any) {
    const scene = await this.prisma.scene.findUnique({ where: { id: sceneId } });
    if (!scene) return null;
    await this.homesService.assertUserInHome(scene.homeId, userId);
    return this.prisma.scene.update({ where: { id: sceneId }, data });
  }

  async run(sceneId: number, userId: number) {
    const scene = await this.prisma.scene.findUnique({ where: { id: sceneId }, include: { actions: true, home: true } });
    if (!scene) return null;
    await this.homesService.assertUserInHome(scene.homeId, userId);
    const commands = scene.actions.map((a) => ({ device_id: a.deviceId, state: a.desiredState }));
    return this.devicesService.batchCommand(commands, userId);
  }
}
