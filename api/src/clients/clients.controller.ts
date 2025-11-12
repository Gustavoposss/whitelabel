import { Controller, Get, Post, Body, Patch, Param, Delete, Req, UseGuards, NotFoundException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { ClientsService } from './clients.service';
import { CreateClientDto } from './dto/create-client.dto';
import { Client } from './entities/client.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('clients')
@Controller('clients')
export class ClientsController {
  constructor(private readonly clientsService: ClientsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new client' })
  @ApiResponse({ status: 201, description: 'Client created successfully', type: Client })
  create(@Body() createClientDto: CreateClientDto) {
    return this.clientsService.create(createClientDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all clients' })
  @ApiResponse({ status: 200, description: 'List of clients', type: [Client] })
  findAll() {
    return this.clientsService.findAll();
  }

  private toPlainClient(client: Client): Client {
    return {
      id: client.id,
      name: client.name,
      url: client.url,
      description: client.description,
      primaryColor: client.primaryColor,
      isActive: client.isActive,
      createdAt: client.createdAt,
      updatedAt: client.updatedAt,
    } as Client;
  }

  @Get('current')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get current client information' })
  @ApiResponse({ status: 200, description: 'Current client information', type: Client })
  @ApiResponse({ status: 404, description: 'Client not found' })
  @ApiBearerAuth()
  async getCurrent(@Req() req: any): Promise<Client> {
    if (req.user?.clientId) {
      try {
        const client = await this.clientsService.findOne(req.user.clientId);
        return this.toPlainClient(client);
      } catch (error) {
        // Continue to next method
      }
    }

    if (req.client?.id) {
      return req.client as Client;
    }

    const clientUrlHeader = req.headers?.['x-client-url'];
    if (clientUrlHeader) {
      const client = await this.clientsService.findByUrl(clientUrlHeader);
      if (client) {
        return this.toPlainClient(client);
      }
    }

    throw new NotFoundException('Client not found for current request');
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a client by ID' })
  @ApiResponse({ status: 200, description: 'Client found', type: Client })
  @ApiResponse({ status: 404, description: 'Client not found' })
  findOne(@Param('id') id: string) {
    return this.clientsService.findOne(+id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a client' })
  @ApiResponse({ status: 200, description: 'Client updated successfully', type: Client })
  update(@Param('id') id: string, @Body() updateClientDto: Partial<CreateClientDto>) {
    return this.clientsService.update(+id, updateClientDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a client' })
  @ApiResponse({ status: 200, description: 'Client deleted successfully' })
  remove(@Param('id') id: string) {
    return this.clientsService.remove(+id);
  }
}


