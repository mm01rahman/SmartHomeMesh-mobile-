// backend/prisma.config.ts
import { defineConfig, env } from 'prisma/config';
import 'dotenv/config';

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
  },
  datasource: {
    // Prisma 7: url comes from here, not schema.prisma
    url: env('DATABASE_URL'),
  },
});
