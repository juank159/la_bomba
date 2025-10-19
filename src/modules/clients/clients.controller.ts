import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
} from '@nestjs/common';
import { ClientsService } from './clients.service';
import { CreateClientDto } from './dto/create-client.dto';
import { UpdateClientDto } from './dto/update-client.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '../users/entities/user.entity';

@Controller('clients')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ClientsController {
  constructor(private readonly clientsService: ClientsService) {}

  @Post()
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR)
  create(@Body() createClientDto: CreateClientDto) {
    return this.clientsService.create(createClientDto);
  }

  @Get()
  // Todos los roles pueden ver clientes
  findAll(
    @Query('search') search?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.clientsService.findAll(search, page, limit);
  }

  @Get('count')
  // Todos los roles pueden ver el conteo de clientes
  count() {
    return this.clientsService.count();
  }

  @Get('by-id/:id')
  // Todos los roles pueden ver detalles de un cliente
  findOne(@Param('id') id: string) {
    return this.clientsService.findOne(id);
  }

  @Patch('by-id/:id')
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR)
  update(@Param('id') id: string, @Body() updateClientDto: UpdateClientDto) {
    return this.clientsService.update(id, updateClientDto);
  }

  @Delete('by-id/:id')
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.clientsService.remove(id);
  }
}
