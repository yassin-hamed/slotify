import { Module } from '@nestjs/common';
import { PrismaService } from './modules/prisma/prisma.service.js';
import { PrismaModule } from './modules/prisma/prisma.module.js';
import { HealthController } from './modules/health/health.controller.js';
import { HealthModule } from './modules/health/health.module.js';

@Module({
  imports: [PrismaModule, HealthModule],
  providers: [PrismaService],
})
export class AppModule {}
