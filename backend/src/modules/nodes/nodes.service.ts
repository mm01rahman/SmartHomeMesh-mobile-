import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { OnlineStatus, DeviceType } from '@prisma/client';

interface JoinPayload {
  node: string;
  devs: { id: string; type: string; label: string }[];
}

interface StatusPayload {
  node: string;
  devs: { id: string; st: number }[];
}

@Injectable()
export class NodesService {
  constructor(private prisma: PrismaService, private homesService: HomesService) {}

  async listForHome(homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.node.findMany({
      where: { homeId },
      include: { devices: true },
      orderBy: { nodeId: 'asc' },
    });
  }

  async getByHomeAndNode(homeId: number, nodeId: string, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.node.findFirst({ where: { homeId, nodeId }, include: { devices: true } });
  }

  async claim(nodeId: string, homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    const node = await this.prisma.node.update({ where: { nodeId }, data: { homeId } });
    await this.prisma.device.updateMany({ where: { nodeId }, data: { homeId } });
    return node;
  }

  async upsertJoinPayload(payload: JoinPayload) {
    const node = await this.prisma.node.upsert({
      where: { nodeId: payload.node },
      update: { name: payload.node, onlineStatus: OnlineStatus.ONLINE, lastSeenAt: new Date() },
      create: { nodeId: payload.node, name: payload.node, onlineStatus: OnlineStatus.ONLINE, lastSeenAt: new Date() },
    });
    for (const dev of payload.devs) {
      await this.prisma.device.upsert({
        where: { nodeId_localId: { nodeId: payload.node, localId: dev.id } },
        update: {
          type: (dev.type as DeviceType) ?? DeviceType.custom,
          firmwareLabel: dev.label,
          homeId: node.homeId ?? undefined,
        },
        create: {
          nodeId: payload.node,
          homeId: node.homeId ?? undefined,
          localId: dev.id,
          type: (dev.type as DeviceType) ?? DeviceType.custom,
          label: dev.label,
          firmwareLabel: dev.label,
        },
      });
    }
    return node;
  }

  async updateStatus(payload: StatusPayload) {
    const node = await this.prisma.node.upsert({
      where: { nodeId: payload.node },
      update: { lastSeenAt: new Date(), onlineStatus: OnlineStatus.ONLINE },
      create: { nodeId: payload.node, name: payload.node, lastSeenAt: new Date(), onlineStatus: OnlineStatus.ONLINE },
    });
    for (const dev of payload.devs) {
      await this.prisma.device.upsert({
        where: { nodeId_localId: { nodeId: payload.node, localId: dev.id } },
        update: { currentState: dev.st, homeId: node.homeId ?? undefined },
        create: {
          nodeId: payload.node,
          homeId: node.homeId ?? undefined,
          localId: dev.id,
          type: DeviceType.custom,
          label: dev.id,
          firmwareLabel: dev.id,
          currentState: dev.st,
        },
      });
    }
    return node;
  }

  async updateLwt(nodeId: string, status: 'ONLINE' | 'OFFLINE') {
    return this.prisma.node.updateMany({
      where: { nodeId },
      data: { onlineStatus: status === 'ONLINE' ? OnlineStatus.ONLINE : OnlineStatus.OFFLINE },
    });
  }
}
