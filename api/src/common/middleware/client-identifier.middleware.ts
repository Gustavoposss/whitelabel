import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Client } from '../../clients/entities/client.entity';

@Injectable()
export class ClientIdentifierMiddleware implements NestMiddleware {
  constructor(
    @InjectRepository(Client)
    private clientRepository: Repository<Client>,
  ) {}

  private toPlainClient(client: Client) {
    return {
      id: client.id,
      name: client.name,
      url: client.url,
      description: client.description,
      primaryColor: client.primaryColor,
      isActive: client.isActive,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    };
  }

  async use(req: Request, res: Response, next: NextFunction) {
    const host = req.get('host');
    const origin = req.get('origin');
    let domain = host?.split(':')[0] || '';

    if (origin) {
      try {
        domain = new URL(origin).hostname;
      } catch (e) {
        // Invalid URL
      }
    }

    if (domain) {
      try {
        const client = await this.clientRepository.findOne({
          where: { url: domain, isActive: true },
          relations: [],
        });
        if (client) {
          (req as any).clientId = client.id;
          (req as any).client = this.toPlainClient(client);
        }
      } catch (error) {
        // Client not found, continue
      }
    }

    const clientUrlHeader = req.get('X-Client-URL');
    if (clientUrlHeader && !(req as any).client) {
      try {
        const client = await this.clientRepository.findOne({
          where: { url: clientUrlHeader, isActive: true },
          relations: [],
        });
        if (client) {
          (req as any).clientId = client.id;
          (req as any).client = this.toPlainClient(client);
        }
      } catch (error) {
        // Client not found, continue
      }
    }

    next();
  }
}

