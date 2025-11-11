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

  async use(req: Request, res: Response, next: NextFunction) {
    const host = req.get('host');
    const origin = req.get('origin');

    // Extract domain from host (e.g., cliente1.local:3000 -> cliente1.local)
    let domain = host?.split(':')[0] || '';

    // If origin is present, extract domain from it
    if (origin) {
      try {
        const url = new URL(origin);
        domain = url.hostname;
      } catch (e) {
        // Ignore invalid URLs
      }
    }

    // Try to find client by URL/domain
    if (domain) {
      try {
        const client = await this.clientRepository.findOne({
          where: { url: domain, isActive: true },
          // Don't load relations to avoid circular references
          relations: [],
        });
        if (client) {
          // Attach only client ID to avoid circular references
          (req as any).clientId = client.id;
          // Attach a plain object with only necessary fields
          (req as any).client = {
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
      } catch (error) {
        // Client not found, but continue (optional middleware)
        console.warn(`Client not found for domain: ${domain}`);
      }
    }

    // Also check for X-Client-URL header (useful for testing)
    const clientUrlHeader = req.get('X-Client-URL');
    if (clientUrlHeader && !(req as any).client) {
      try {
        const client = await this.clientRepository.findOne({
          where: { url: clientUrlHeader, isActive: true },
          // Don't load relations to avoid circular references
          relations: [],
        });
        if (client) {
          (req as any).clientId = client.id;
          // Attach a plain object with only necessary fields
          (req as any).client = {
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
      } catch (error) {
        console.warn(`Client not found for header X-Client-URL: ${clientUrlHeader}`);
      }
    }

    next();
  }
}

