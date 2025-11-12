import { Module, NestModule, MiddlewareConsumer } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { ClientsModule } from './clients/clients.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { ProductsModule } from './products/products.module';
import { Client } from './clients/entities/client.entity';
import { User } from './users/entities/user.entity';
import { ClientIdentifierMiddleware } from './common/middleware/client-identifier.middleware';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        type: 'sqlite',
        database: configService.get<string>('DB_DATABASE') || 'whitelabel.db',
        entities: [Client, User],
        synchronize: true,
        logging: false,
      }),
      inject: [ConfigService],
    }),
    TypeOrmModule.forFeature([Client]),
    ClientsModule,
    UsersModule,
    AuthModule,
    ProductsModule,
  ],
  controllers: [AppController],
  providers: [ClientIdentifierMiddleware],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(ClientIdentifierMiddleware).forRoutes('*');
  }
}
