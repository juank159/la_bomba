import { Repository } from 'typeorm';
import { Product } from './entities/product.entity';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { ProductUpdateTasksService } from './product-update-tasks.service';
export declare class ProductsService {
    private productsRepository;
    private readonly tasksService;
    constructor(productsRepository: Repository<Product>, tasksService: ProductUpdateTasksService);
    create(createProductDto: CreateProductDto): Promise<Product>;
    findAll(search?: string, page?: number, limit?: number): Promise<Product[]>;
    findOne(id: string): Promise<Product>;
    findOneForAdmin(id: string): Promise<Product>;
    update(id: string, updateProductDto: UpdateProductDto, updatedById?: string): Promise<Product>;
    private createUpdateTask;
    remove(id: string): Promise<void>;
    searchProducts(query: string, page?: number, limit?: number): Promise<Product[]>;
}
