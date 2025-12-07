import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { OnlineStatus } from '@prisma/client';

@Injectable()
export class NodesService {
  constructor(private prisma: PrismaService, private homesService: HomesService) {}

  async listForHome(homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.node.findMany({ where: { homeId }, include: { devices: true } });
  }

  async getById(id: number, userId: number) {
    const node = await this.prisma.node.findUnique({ where: { id } });
    if (!node) return null;
    if (node.homeId) await this.homesService.assertUserInHome(node.homeId, userId);
    return node;
  }

  async claim(nodeId: string, homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.node.update({ where: { nodeId }, data: { homeId } });
  }

  async upsertJoinPayload(payload: { node: string; devs: { id: string; type: string; label: string }[] }) {
    const node = await this.prisma.node.upsert({
      where: { nodeId: payload.node },
      update: { name: payload.node },
      create: { nodeId: payload.node, name: payload.node },
    });
    for (const dev of payload.devs) {
      await this.prisma.device.upsert({
        where: { nodeId_localId: { nodeId: payload.node, localId: dev.id } },
        update: { type: dev.type as any, label: dev.label, homeId: node.homeId ?? 0 || node.homeId },
        create: {
          nodeId: payload.node,
          homeId: node.homeId ?? (await this.ensureUnclaimedHome()),
          localId: dev.id,
          type: dev.type as any,
          label: dev.label,
        },
      });
    }
    return node;
  }

  private async ensureUnclaimedHome() {
    // For devices arriving before claim, place under placeholder home 0? Instead create dummy shared home? keep null by linking to node home once claimed
    const placeholderHome = await this.prisma.home.upsert({
      where: { id: 1 },
      update: {},
      create: { name: 'Unclaimed', timezone: 'UTC' },
    });
    return placeholderHome.id;
  }

  async updateStatus(payload: { node: string; devs: { id: string; st: number }[] }) {
    const node = await this.prisma.node.update({
      where: { nodeId: payload.node },
      data: { lastSeenAt: new Date(), onlineStatus: OnlineStatus.ONLINE },
    });
    for (const dev of payload.devs) {
      await this.prisma.device.updateMany({
        where: { nodeId: payload.node, localId: dev.id },
        data: { currentState: dev.st },
      });
    }
    return node;
  }

  async updateLwt(nodeId: string, status: 'ONLINE' | 'OFFLINE') {
    return this.prisma.node.updateMany({
      where: { nodeId },
      data: { onlineStatus: status as OnlineStatus },
    });
  }
}
