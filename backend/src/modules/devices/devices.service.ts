import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { NodesService } from '../nodes/nodes.service';
import { MqttService } from '../mqtt/mqtt.service';

@Injectable()
export class DevicesService {
  constructor(
    private prisma: PrismaService,
    private homesService: HomesService,
    private nodesService: NodesService,
    private mqttService: MqttService,
  ) {}

  async listForHome(homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.device.findMany({ where: { homeId }, include: { node: true, room: true } });
  }

  async update(deviceId: number, userId: number, data: { label?: string; roomId?: number | null }) {
    const device = await this.prisma.device.findUnique({ where: { id: deviceId } });
    if (!device) throw new ForbiddenException('Device not found');
    if (device.homeId) await this.homesService.assertUserInHome(device.homeId, userId);
    return this.prisma.device.update({ where: { id: deviceId }, data });
  }

  async sendCommand(deviceId: number, userId: number, state: number) {
    const device = await this.prisma.device.findUnique({ where: { id: deviceId } });
    if (!device) throw new ForbiddenException('Device not found');
    if (!device.homeId) throw new ForbiddenException('Device is not assigned to a home');
    await this.homesService.assertUserInHome(device.homeId, userId);
    const cmdPayload = { t: 'cmd', dev: `${device.nodeId}:${device.localId}`, st: state };
    const topic = `${process.env.MQTT_BASE_TOPIC || 'smarthome'}/${device.nodeId}/cmd`;
    await this.mqttService.publish(topic, JSON.stringify(cmdPayload));
    await this.prisma.device.update({ where: { id: deviceId }, data: { currentState: state } });
    return { success: true, sent: cmdPayload };
  }

  async toggleByFullId(fullId: string, state: number) {
    const [nodeId, localId] = fullId.split(':');
    const device = await this.prisma.device.findUnique({ where: { nodeId_localId: { nodeId, localId } } });
    if (!device) throw new ForbiddenException('Device not found');
    return this.sendCommand(device.id, device.homeId!, state);
  }

  async batchCommand(commands: { device_id: number; state: number }[], userId: number) {
    const results = [] as any[];
    for (const cmd of commands) {
      results.push(await this.sendCommand(cmd.device_id, userId, cmd.state));
    }
    return { success: true, results };
  }
}
