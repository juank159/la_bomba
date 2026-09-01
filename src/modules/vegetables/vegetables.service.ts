import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { VegetableItem, PricingType } from './entities/vegetable-item.entity';
import { VegetableSale } from './entities/vegetable-sale.entity';
import { VegetableSaleItem } from './entities/vegetable-sale-item.entity';
import { CreateVegetableItemDto } from './dto/create-vegetable-item.dto';
import { UpdateVegetableItemDto } from './dto/update-vegetable-item.dto';
import { CreateVegetableSaleDto } from './dto/create-vegetable-sale.dto';

@Injectable()
export class VegetablesService {
  constructor(
    @InjectRepository(VegetableItem)
    private itemsRepository: Repository<VegetableItem>,
    @InjectRepository(VegetableSale)
    private salesRepository: Repository<VegetableSale>,
    @InjectRepository(VegetableSaleItem)
    private saleItemsRepository: Repository<VegetableSaleItem>,
  ) {}

  // ==========================================================================
  // Catálogo de verduras
  // ==========================================================================

  async createItem(dto: CreateVegetableItemDto): Promise<VegetableItem> {
    if (dto.pricingType === PricingType.WEIGHT && !dto.pricePerKg) {
      throw new BadRequestException('Los productos que se venden por peso requieren precio por kilo');
    }
    if (dto.pricingType === PricingType.FIXED && !dto.fixedPrice) {
      throw new BadRequestException('Los productos de precio fijo requieren un precio');
    }

    const item = this.itemsRepository.create(dto);
    return this.itemsRepository.save(item);
  }

  async findAllItems(includeInactive = false): Promise<VegetableItem[]> {
    return this.itemsRepository.find({
      where: includeInactive ? {} : { isActive: true },
      order: { name: 'ASC' },
    });
  }

  async findOneItem(id: string): Promise<VegetableItem> {
    const item = await this.itemsRepository.findOne({ where: { id } });
    if (!item) {
      throw new NotFoundException(`Producto de verduras con ID ${id} no encontrado`);
    }
    return item;
  }

  async updateItem(id: string, dto: UpdateVegetableItemDto): Promise<VegetableItem> {
    const item = await this.findOneItem(id);
    const merged = this.itemsRepository.merge(item, dto);

    if (merged.pricingType === PricingType.WEIGHT && !merged.pricePerKg) {
      throw new BadRequestException('Los productos que se venden por peso requieren precio por kilo');
    }
    if (merged.pricingType === PricingType.FIXED && !merged.fixedPrice) {
      throw new BadRequestException('Los productos de precio fijo requieren un precio');
    }

    return this.itemsRepository.save(merged);
  }

  async removeItem(id: string): Promise<void> {
    const item = await this.findOneItem(id);
    // Baja lógica: no se borra para no perder el histórico de ventas que
    // referencian este producto (igual que isActive en products).
    item.isActive = false;
    await this.itemsRepository.save(item);
  }

  // ==========================================================================
  // Ventas
  // ==========================================================================

  async createSale(dto: CreateVegetableSaleDto, username: string): Promise<VegetableSale> {
    const itemIds = dto.items.map((i) => i.vegetableItemId);
    const items = await this.itemsRepository.find({ where: { id: In(itemIds) } });
    const itemsById = new Map(items.map((i) => [i.id, i]));

    const missingId = itemIds.find((id) => !itemsById.has(id));
    if (missingId) {
      throw new BadRequestException(`Producto no encontrado: ${missingId}`);
    }

    let total = 0;

    const itemsData = dto.items.map((line) => {
      const item = itemsById.get(line.vegetableItemId)!;

      if (item.pricingType === PricingType.WEIGHT) {
        if (!line.weightKg || line.weightKg <= 0) {
          throw new BadRequestException(
            `${item.name} se vende por peso: debes indicar el peso en kg`,
          );
        }
        const unitPrice = Number(item.pricePerKg);
        const lineTotal = unitPrice * line.weightKg;
        total += lineTotal;

        return {
          vegetableItemId: item.id,
          description: item.name,
          pricingType: item.pricingType,
          weightKg: line.weightKg,
          quantity: null,
          unitPrice,
          total: lineTotal,
        };
      }

      // FIXED
      const quantity = line.quantity && line.quantity > 0 ? line.quantity : 1;
      const unitPrice = Number(item.fixedPrice);
      const lineTotal = unitPrice * quantity;
      total += lineTotal;

      return {
        vegetableItemId: item.id,
        description: item.name,
        pricingType: item.pricingType,
        weightKg: null,
        quantity,
        unitPrice,
        total: lineTotal,
      };
    });

    const sale = this.salesRepository.create({
      total,
      soldBy: username,
    });
    const savedSale = await this.salesRepository.save(sale);

    const saleItems = itemsData.map((item) =>
      this.saleItemsRepository.create({
        saleId: savedSale.id,
        ...item,
      }),
    );
    await this.saleItemsRepository.save(saleItems);

    return this.findOneSale(savedSale.id);
  }

  async findAllSales(): Promise<VegetableSale[]> {
    return this.salesRepository.find({
      relations: ['items'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOneSale(id: string): Promise<VegetableSale> {
    const sale = await this.salesRepository.findOne({
      where: { id },
      relations: ['items'],
    });

    if (!sale) {
      throw new NotFoundException(`Venta con ID ${id} no encontrada`);
    }

    return sale;
  }
}
