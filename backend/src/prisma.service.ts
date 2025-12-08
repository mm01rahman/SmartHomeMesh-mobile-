import { INestApplication, Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    const databaseUrl = process.env.DATABASE_URL;
    if (!databaseUrl) {
      throw new Error('DATABASE_URL environment variable is not set.');
    }

    // Neon + pg pool
    const pool = new Pool({
      connectionString: databaseUrl,
      // If you hit SSL errors with Neon, uncomment this:
      // ssl: { rejectUnauthorized: false },
    });

    const adapter = new PrismaPg(pool);

    super({
      adapter,
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async enableShutdownHooks(app: INestApplication) {
    this.$on('beforeExit' as never, async () => {
      await app.close();
    });
  }
}
