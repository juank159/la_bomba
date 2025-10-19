import { ProductsService } from './products.service';
export declare class ProductsSearchController {
    private readonly productsService;
    constructor(productsService: ProductsService);
    search(query?: string, page?: number, limit?: number): Promise<import("./entities/product.entity").Product[]>;
}
