import { Injectable, NotFoundException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like, ILike } from 'typeorm';
import { Product } from './entities/product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductUpdateTasksService } from './product-update-tasks.service';
import { ChangeType } from './entities/product-update-task.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    @Inject(forwardRef(() => ProductUpdateTasksService))
    private readonly tasksService: ProductUpdateTasksService,
  ) {}

  async create(createProductDto: CreateProductDto): Promise<Product> {
    const product = this.productsRepository.create(createProductDto);
    return this.productsRepository.save(product);
  }

  async findAll(search?: string, page?: number, limit?: number): Promise<Product[]> {
    if (search && search.trim().length > 0) {
      return this.searchProducts(search, page || 0, limit || 20);
    }
    
    return this.productsRepository.find({
      where: { isActive: true },
      order: { createdAt: 'DESC' },
      skip: page ? page * (limit || 20) : undefined,
      take: limit || undefined,
    });
  }

  async findOne(id: string): Promise<Product> {
    const product = await this.productsRepository.findOne({
      where: { id, isActive: true }
    });
    
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    
    return product;
  }

  /// Find product by ID for admin operations (includes inactive products)
  async findOneForAdmin(id: string): Promise<Product> {
    const product = await this.productsRepository.findOne({
      where: { id }
    });
    
    if (!product) {
      throw new NotFoundException(`Product with ID ${id} not found`);
    }
    
    return product;
  }

  async update(id: string, updateProductDto: UpdateProductDto, updatedById?: string): Promise<Product> {
    console.log('🔄 ProductsService.update called with:', { id, updateProductDto, updatedById });
    console.log('🔍 BACKEND: Received updateProductDto keys:', Object.keys(updateProductDto));
    console.log('🔍 BACKEND: Received updateProductDto values:', Object.values(updateProductDto));
    console.log('🔍 BACKEND: IVA in updateProductDto?', 'iva' in updateProductDto);
    console.log('🔍 BACKEND: IVA value:', updateProductDto.iva);

    // For updates, we should allow updating both active and inactive products
    console.log('🔍 Searching for product with ID:', id);
    const product = await this.productsRepository.findOne({
      where: { id }
    });

    console.log('🔍 Found product:', product ? 'YES' : 'NO');
    if (product) {
      console.log('📊 Product details:', {
        id: product.id,
        description: product.description,
        isActive: product.isActive,
        currentIva: product.iva
      });
    }

    if (!product) {
      console.log('❌ Product not found with ID:', id);
      throw new NotFoundException(`Product with ID ${id} not found`);
    }

    // Store old values for task creation
    const oldValues = {
      precioA: product.precioA,
      precioB: product.precioB,
      precioC: product.precioC,
      costo: product.costo,
      iva: product.iva,
      description: product.description,
    };

    console.log('✏️ Updating product with data:', updateProductDto);
    console.log('🔍 BEFORE update - product.iva:', product.iva);

    // CRITICAL FIX: Use TypeORM's update() method instead of save() to only update specified fields
    // This prevents any default values from being applied to fields that are not being updated
    await this.productsRepository.update(id, updateProductDto);

    console.log('💾 Product updated successfully');

    // Reload the product to get the updated values
    const savedProduct = await this.productsRepository.findOne({
      where: { id }
    });

    if (!savedProduct) {
      throw new NotFoundException(`Product with ID ${id} not found after update`);
    }

    console.log('✅ Product reloaded successfully:', savedProduct.id);
    console.log('✅ Saved product IVA:', savedProduct.iva);

    // Create task for supervisors if there are price or info changes and we have an updatedById
    if (updatedById) {
      try {
        await this.createUpdateTask(oldValues, updateProductDto, savedProduct, updatedById);
      } catch (error) {
        console.error('⚠️ Failed to create update task:', error);
        // Don't fail the product update if task creation fails
      }
    }

    return savedProduct;
  }

  /// Helper method to create update tasks
  private async createUpdateTask(
    oldValues: any,
    updateData: UpdateProductDto,
    product: Product,
    updatedById: string,
  ): Promise<void> {
    const priceFields = ['precioA', 'precioB', 'precioC', 'costo'];

    let hasChanges = false;
    let changeType = ChangeType.INFO;
    let description = '';
    const changeDetails: string[] = [];

    // Check for price changes
    const priceChanges = priceFields.filter(field =>
      updateData[field] !== undefined && updateData[field] !== oldValues[field]
    );

    // Check for description change
    const descriptionChanged = updateData['description'] !== undefined &&
                               updateData['description'] !== oldValues['description'];

    // Check for IVA change
    const ivaChanged = updateData['iva'] !== undefined &&
                       updateData['iva'] !== oldValues['iva'];

    // Build detailed change description
    if (priceChanges.length > 0) {
      hasChanges = true;
      changeType = ChangeType.PRICE;
      changeDetails.push(`Precios: ${priceChanges.join(', ')}`);
    }

    if (descriptionChanged) {
      hasChanges = true;
      if (changeType !== ChangeType.PRICE) {
        changeType = ChangeType.INFO;
      }
      changeDetails.push(`Nombre del producto`);
    }

    if (ivaChanged) {
      hasChanges = true;
      if (changeType !== ChangeType.PRICE) {
        changeType = ChangeType.INFO;
      }
      changeDetails.push(`IVA (${oldValues['iva']}% → ${updateData['iva']}%)`);
    }

    if (hasChanges) {
      description = changeDetails.join(', ');

      console.log('📝 Creating update task for product:', {
        productId: product.id,
        changeType,
        description,
        changes: {
          prices: priceChanges,
          descriptionChanged,
          ivaChanged,
        }
      });

      await this.tasksService.createTaskForProductUpdate(
        product.id,
        changeType,
        oldValues,
        updateData,
        updatedById,
        description,
      );
    }
  }

  async remove(id: string): Promise<void> {
    const product = await this.findOne(id);
    product.isActive = false;
    await this.productsRepository.save(product);
  }

  async searchProducts(query: string, page: number = 0, limit: number = 20): Promise<Product[]> {
    console.log('searchProducts called with:', { query, page, limit });
    
    if (!query || query.trim().length === 0) {
      console.log('No query provided, returning all products');
      return this.findAll();
    }

    const searchTerm = `%${query.trim()}%`;
    console.log('Searching with term:', searchTerm);
    
    try {
      const result = await this.productsRepository.find({
        where: [
          { description: ILike(searchTerm), isActive: true },
          { barcode: ILike(searchTerm), isActive: true },
        ],
        order: { createdAt: 'DESC' },
        skip: page * limit,
        take: limit,
      });
      console.log('Search result count:', result.length);
      return result;
    } catch (error) {
      console.error('Database search error:', error);
      throw error;
    }
  }
}