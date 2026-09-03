import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CorresponsalService } from './corresponsal.service';
import { CorresponsalController } from './corresponsal.controller';
import { CorresponsalEntry } from './entities/corresponsal-entry.entity';

@Module({
  imports: [TypeOrmModule.forFeature([CorresponsalEntry])],
  controllers: [CorresponsalController],
  providers: [CorresponsalService],
})
export class CorresponsalModule {}
