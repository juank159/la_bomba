import { Controller, Get, Query } from '@nestjs/common';
import { ProductsService } from './products.service';

@Controller('products-search')
export class ProductsSearchController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  async search(
    @Query('q') query?: string,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    try {
      console.log('Search called with:', { query, page, limit });
      return this.productsService.searchProducts(query || '', page || 0, limit || 20);
    } catch (error) {
      console.error('Error in search controller:', error);
      throw error;
    }
  }
}