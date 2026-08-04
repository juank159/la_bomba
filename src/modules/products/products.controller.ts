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
  Request,
} from "@nestjs/common";
import { ProductsService } from "./products.service";
import { CreateProductDto } from "./dto/create-product.dto";
import { UpdateProductDto } from "./dto/update-product.dto";
import { CreateTemporaryProductDto } from "./dto/create-temporary-product.dto";
import { UpdateTemporaryProductDto } from "./dto/update-temporary-product.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { RolesGuard } from "../../common/guards/roles.guard";
import { Roles } from "../../common/decorators/roles.decorator";
import { UserRole } from "../users/entities/user.entity";

@Controller("products")
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  /**
   * Quita el campo "costo" de la respuesta cuando quien la pide no es admin.
   * El costo es información financiera sensible (margen real del negocio):
   * ocultarlo solo en el frontend no alcanza, porque cualquiera puede seguir
   * viéndolo inspeccionando la respuesta de red. Esta es la protección real.
   * Acepta tanto un solo objeto (Product/TemporaryProduct) como un arreglo.
   */
  private stripCostoForRole<T>(data: T, role: UserRole): T {
    if (role === UserRole.ADMIN) return data;

    const omitCosto = (item: any) => {
      if (!item || typeof item !== "object") return item;
      const { costo, ...rest } = item;
      return rest;
    };

    if (Array.isArray(data)) {
      return (data as any[]).map(omitCosto) as unknown as T;
    }
    return omitCosto(data);
  }

  @Post()
  @Roles(UserRole.ADMIN)
  create(@Body() createProductDto: CreateProductDto) {
    return this.productsService.create(createProductDto);
  }

  @Post('with-supervisor-task')
  @Roles(UserRole.ADMIN)
  createWithSupervisorTask(
    @Body() createProductDto: CreateProductDto,
    @Request() req: any,
  ) {
    const adminId = req.user.userId;
    console.log('🎯 POST /products/with-supervisor-task called by admin:', adminId);
    return this.productsService.createProductWithSupervisorTask(
      createProductDto,
      adminId,
    );
  }

  @Get()
  // Los empleados, supervisores y administradores pueden ver productos
  async findAll(
    @Query("search") search?: string,
    @Query("page") page?: string,
    @Query("limit") limit?: string,
    @Request() req?: any
  ) {
    try {
      // Convert string query params to numbers
      const pageNum = page ? parseInt(page, 10) : undefined;
      const limitNum = limit ? parseInt(limit, 10) : undefined;

      console.log("FindAll called with:", { search, page: pageNum, limit: limitNum });
      console.log("Original types:", { pageType: typeof page, limitType: typeof limit });

      const results = await this.productsService.findAll(search, pageNum, limitNum);
      return this.stripCostoForRole(results, req?.user?.role);
    } catch (error) {
      console.error("Error in findAll controller:", error);
      console.error("Full error:", error);
      throw error;
    }
  }

  @Get("by-id/:id")
  // Los empleados, supervisores y administradores pueden ver detalles de productos
  async findOne(@Param("id") id: string, @Request() req: any) {
    console.log("🔍 GET /products/by-id/" + id + " called by:", req.user?.role);
    // Los administradores y supervisores pueden ver todos los productos (incluso inactivos)
    let product: any;
    if (
      req.user?.role === UserRole.ADMIN ||
      req.user?.role === UserRole.SUPERVISOR
    ) {
      console.log("👑 Admin/Supervisor access - using findOneForAdmin");
      product = await this.productsService.findOneForAdmin(id);
    } else {
      // Los empleados solo ven productos activos
      console.log("👤 Employee access - using findOne (active only)");
      product = await this.productsService.findOne(id);
    }
    return this.stripCostoForRole(product, req.user?.role);
  }

  @Patch("by-id/:id")
  @Roles(UserRole.ADMIN)
  update(
    @Param("id") id: string,
    @Body() updateProductDto: UpdateProductDto,
    @Request() req: any
  ) {
    console.log("🔄 PATCH /products/by-id/" + id + " called");
    console.log("👤 Full req.user object:", JSON.stringify(req.user, null, 2));
    console.log("🆔 req.user.userId:", req.user?.userId);
    console.log("🆔 req.user.id:", req.user?.id);

    // Log the RAW body BEFORE DTO transformation
    console.log("🔍 RAW BODY (req.body):", JSON.stringify(req.body, null, 2));
    console.log("📊 Update data:", updateProductDto);
    console.log(
      "🔍 DTO after transformation:",
      JSON.stringify(updateProductDto, null, 2)
    );
    console.log("🔍 DTO constructor:", updateProductDto.constructor.name);
    console.log("🔍 DTO keys:", Object.keys(updateProductDto));
    console.log(
      "🔍 DTO has own property iva?:",
      updateProductDto.hasOwnProperty("iva")
    );
    console.log("🔍 IVA value:", updateProductDto.iva);
    console.log("🔍 IVA is undefined?:", updateProductDto.iva === undefined);

    // Extract adminNotes from body if present
    const adminNotes = req.body?.adminNotes;
    console.log("📝 Admin notes:", adminNotes);

    return this.productsService.update(id, updateProductDto, req.user?.userId, adminNotes);
  }

  @Patch("by-id/:id/barcode")
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  async updateProductBarcode(
    @Param("id") productId: string,
    @Body("barcode") barcode: string,
    @Request() req: any,
  ) {
    const supervisorId = req.user.userId;
    console.log('🔄 PATCH /products/by-id/' + productId + '/barcode called');
    console.log('📦 Barcode to update:', barcode);
    console.log('👤 Supervisor ID:', supervisorId);
    const updated = await this.productsService.updateProductBarcode(productId, barcode, supervisorId);
    return this.stripCostoForRole(updated, req.user?.role);
  }

  @Delete("by-id/:id")
  @Roles(UserRole.ADMIN)
  remove(@Param("id") id: string) {
    return this.productsService.remove(id);
  }

  // Temporary Products Endpoints

  @Post("temporary")
  @Roles(UserRole.ADMIN)
  createTemporaryProduct(@Body() dto: CreateTemporaryProductDto) {
    return this.productsService.createTemporaryProduct(dto);
  }

  @Patch("temporary/:id")
  @Roles(UserRole.ADMIN)
  updateTemporaryProduct(
    @Param("id") id: string,
    @Body() dto: UpdateTemporaryProductDto,
    @Request() req: any,
  ) {
    const adminId = req.user.userId;
    return this.productsService.updateTemporaryProduct(id, dto, adminId);
  }

  @Get("temporary")
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.DIGITADOR)
  async findAllTemporaryProducts(@Request() req: any) {
    console.log('🔍 GET /products/temporary called by:', {
      userId: req.user?.userId,
      username: req.user?.username,
      role: req.user?.role,
    });
    const results = await this.productsService.findAllTemporaryProducts();
    return this.stripCostoForRole(results, req.user?.role);
  }

  @Get("temporary/:id")
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR, UserRole.DIGITADOR)
  async findTemporaryProduct(@Param("id") id: string, @Request() req: any) {
    const result = await this.productsService.findTemporaryProduct(id);
    return this.stripCostoForRole(result, req.user?.role);
  }

  @Post("temporary/:id/cancel")
  @Roles(UserRole.ADMIN)
  cancelTemporaryProduct(
    @Param("id") id: string,
    @Body() body: { reason?: string },
    @Request() req: any,
  ) {
    const adminId = req.user.userId;
    return this.productsService.cancelTemporaryProduct(id, adminId, body.reason);
  }

  @Post("temporary/:id/complete-supervisor")
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  async completeTemporaryProductBySupervisor(
    @Param("id") id: string,
    @Body() body: { notes?: string; barcode?: string },
    @Request() req: any,
  ) {
    const supervisorId = req.user.userId;
    console.log('🔍 Complete temporary product by supervisor:', {
      id,
      supervisorId,
      notes: body.notes,
      barcode: body.barcode,
    });
    const result = await this.productsService.completeTemporaryProductBySupervisor(
      id,
      supervisorId,
      body.notes,
      body.barcode,
    );
    return this.stripCostoForRole(result, req.user?.role);
  }

  @Post("temporary/:id/update-barcode")
  @Roles(UserRole.SUPERVISOR, UserRole.ADMIN)
  async updateProductBarcodeFromTemporary(
    @Param("id") temporaryProductId: string,
    @Body() body: { barcode: string; notes?: string },
    @Request() req: any,
  ) {
    const supervisorId = req.user.userId;
    console.log('🔍 Update product barcode from temporary:', {
      temporaryProductId,
      supervisorId,
      barcode: body.barcode,
      notes: body.notes,
    });
    const result = await this.productsService.updateProductBarcodeFromTemporary(
      temporaryProductId,
      supervisorId,
      body.barcode,
      body.notes,
    );
    return {
      product: this.stripCostoForRole(result.product, req.user?.role),
      temporaryProduct: this.stripCostoForRole(result.temporaryProduct, req.user?.role),
    };
  }

  @Delete("temporary/:id")
  @Roles(UserRole.ADMIN)
  deleteTemporaryProduct(@Param("id") id: string) {
    return this.productsService.deleteTemporaryProduct(id);
  }
}
