import { Injectable } from '@nestjs/common';
import { Cron, CronExpression, SchedulerRegistry } from '@nestjs/schedule';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { DevicesService } from '../devices/devices.service';

@Injectable()
export class AutomationsService {
  constructor(
    private prisma: PrismaService,
    private homesService: HomesService,
    private devicesService: DevicesService,
    private scheduler: SchedulerRegistry,
  ) {}

  async list(homeId: number, userId: number) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.automation.findMany({ where: { homeId } });
  }

  async create(homeId: number, userId: number, data: any) {
    await this.homesService.assertUserInHome(homeId, userId);
    return this.prisma.automation.create({ data: { ...data, homeId, ownerId: userId } });
  }

  async update(id: number, userId: number, data: any) {
    const automation = await this.prisma.automation.findUnique({ where: { id } });
    if (!automation) return null;
    await this.homesService.assertUserInHome(automation.homeId, userId);
    return this.prisma.automation.update({ where: { id }, data });
  }

  // Simple time-based cron to check enabled automations hourly
  @Cron(CronExpression.EVERY_MINUTE)
  async handleCron() {
    const automations = await this.prisma.automation.findMany({ where: { isEnabled: true, triggerType: 'time' } });
    const now = new Date();
    for (const automation of automations) {
      const config: any = automation.triggerConfig;
      if (config?.minute === now.getMinutes()) {
        const actions: any[] = automation.actionsConfig as any;
        for (const action of actions) {
          if (!automation.ownerId) continue;
          await this.homesService.assertUserInHome(automation.homeId, automation.ownerId);
          await this.devicesService.sendCommand(action.deviceId, automation.ownerId, action.state);
        }
      }
    }
  }
}
