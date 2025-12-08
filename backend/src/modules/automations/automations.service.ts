import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma.service';
import { HomesService } from '../homes/homes.service';
import { DevicesService } from '../devices/devices.service';
import * as cronParser from 'cron-parser';

@Injectable()
export class AutomationsService {
  private readonly logger = new Logger(AutomationsService.name);

  constructor(
    private prisma: PrismaService,
    private homesService: HomesService,
    private devicesService: DevicesService,
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

  @Cron(CronExpression.EVERY_MINUTE)
  async handleCron() {
    const now = new Date();
    const automations = await this.prisma.automation.findMany({ where: { isEnabled: true, triggerType: 'cron' } });
    for (const automation of automations) {
      try {
        if (!automation.cron) continue;
        const interval = cronParser.parseExpression(automation.cron, { currentDate: now });
        const prev = interval.prev();
        if (Math.abs(now.getTime() - prev.getTime()) <= 60000) {
          const actions: any[] = automation.actionsConfig as any;
          for (const action of actions) {
            if (!automation.ownerId) continue;
            await this.homesService.assertUserInHome(automation.homeId, automation.ownerId);
            await this.devicesService.sendCommand(action.deviceId, automation.ownerId, action.state);
          }
        }
      } catch (err) {
        this.logger.warn(`Automation ${automation.id} failed cron parse: ${err}`);
      }
    }
  }
}
