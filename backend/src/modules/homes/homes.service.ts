import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma.service';
import { HomeRole } from '@prisma/client';

@Injectable()
export class HomesService {
  constructor(private prisma: PrismaService) {}

  async create(homeDto: { name: string; timezone: string }, userId: number) {
    return this.prisma.home.create({
      data: {
        name: homeDto.name,
        timezone: homeDto.timezone,
        users: {
          create: {
            userId,
            role: HomeRole.owner,
          },
        },
      },
    });
  }

  async listForUser(userId: number) {
    return this.prisma.home.findMany({
      where: { users: { some: { userId } } },
      include: { users: true },
    });
  }

  async get(homeId: number, userId: number) {
    const allowed = await this.prisma.homeUser.findFirst({ where: { homeId, userId } });
    if (!allowed) throw new ForbiddenException('Not part of this home');
    return this.prisma.home.findUnique({ where: { id: homeId } });
  }

  async assertUserInHome(homeId: number, userId: number) {
    const membership = await this.prisma.homeUser.findFirst({ where: { homeId, userId } });
    if (!membership) throw new ForbiddenException('Not allowed');
    return membership;
  }
}
