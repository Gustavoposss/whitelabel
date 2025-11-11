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

  @Get('current')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get current client information (based on URL/header)' })
  @ApiResponse({ status: 200, description: 'Current client information', type: Client })
  @ApiResponse({ status: 404, description: 'Client not found' })
  @ApiBearerAuth()
  async getCurrent(@Req() req: any): Promise<Client> {
    // Check if client is attached by middleware (as plain object to avoid circular references)
    if (req.client && req.client.id) {
      // Return the plain object from middleware (already without circular references)
      return req.client as Client;
    }
    
    // Try to get from header (Express converts headers to lowercase)
    const clientUrlHeader = req.headers?.['x-client-url'];
    if (clientUrlHeader) {
      const client = await this.clientsService.findByUrl(clientUrlHeader);
      if (client) {
        // Return only necessary fields to avoid circular references
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
    }
    
    // If still not found, throw error
    throw new NotFoundException(
      'Client not found for current request. Please provide X-Client-URL header or access via client URL.',
    );
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


