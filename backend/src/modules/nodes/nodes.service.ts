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
    const node = await this.prisma.node.update({ where: { nodeId }, data: { homeId } });
    await this.prisma.device.updateMany({ where: { nodeId }, data: { homeId } });
    return node;
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
        update: { type: dev.type as any, label: dev.label, homeId: node.homeId ?? undefined },
        create: {
          nodeId: payload.node,
          homeId: node.homeId ?? undefined,
          localId: dev.id,
          type: dev.type as any,
          label: dev.label,
        },
      });
    }
    return node;
  }

  async updateStatus(payload: { node: string; devs: { id: string; st: number }[] }) {
    const node = await this.prisma.node.upsert({
      where: { nodeId: payload.node },
      update: { lastSeenAt: new Date(), onlineStatus: OnlineStatus.ONLINE },
      create: { nodeId: payload.node, name: payload.node, lastSeenAt: new Date(), onlineStatus: OnlineStatus.ONLINE },
    });
    for (const dev of payload.devs) {
      await this.prisma.device.upsert({
        where: { nodeId_localId: { nodeId: payload.node, localId: dev.id } },
        update: { currentState: dev.st },
        create: {
          nodeId: payload.node,
          homeId: node.homeId ?? undefined,
          localId: dev.id,
          type: 'custom',
          label: dev.id,
          currentState: dev.st,
        },
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
