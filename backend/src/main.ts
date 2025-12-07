import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { bufferLogs: true });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidUnknownValues: true }));
  const port = process.env.PORT || 8080;
  await app.listen(port);
  console.log(`SmartHomeMesh backend listening on ${port}`);
}

bootstrap();
