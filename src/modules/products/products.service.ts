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
        isActive: product.isActive 
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
    Object.assign(product, updateProductDto);
    
    console.log('💾 Saving updated product...');
    const savedProduct = await this.productsRepository.save(product);
    console.log('✅ Product saved successfully:', savedProduct.id);

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
    const infoFields = ['description', 'iva'];
    
    let hasChanges = false;
    let changeType = ChangeType.INFO;
    let description = '';

    // Check for price changes
    const priceChanges = priceFields.filter(field => 
      updateData[field] !== undefined && updateData[field] !== oldValues[field]
    );

    // Check for info changes
    const infoChanges = infoFields.filter(field => 
      updateData[field] !== undefined && updateData[field] !== oldValues[field]
    );

    if (priceChanges.length > 0) {
      hasChanges = true;
      changeType = ChangeType.PRICE;
      description = `Precio actualizado: ${priceChanges.join(', ')}`;
    } else if (infoChanges.length > 0) {
      hasChanges = true;
      changeType = ChangeType.INFO;
      description = `Información actualizada: ${infoChanges.join(', ')}`;
    }

    if (hasChanges) {
      console.log('📝 Creating update task for product:', {
        productId: product.id,
        changeType,
        description,
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