import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const configService = app.get(ConfigService);

  // Enable CORS
  app.enableCors({
    origin: configService.get<string>('CORS_ORIGIN') || '*',
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Swagger documentation
  if (configService.get<string>('SWAGGER_ENABLED') === 'true') {
    const config = new DocumentBuilder()
      .setTitle('E-commerce Whitelabel API')
      .setDescription('API para sistema de e-commerce whitelabel')
      .setVersion('1.0')
      .addBearerAuth()
      .addTag('auth', 'Autenticação')
      .addTag('clients', 'Clientes (Whitelabel)')
      .addTag('products', 'Produtos')
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  const port = configService.get<number>('PORT') || 3000;
  await app.listen(port);
}
bootstrap();
