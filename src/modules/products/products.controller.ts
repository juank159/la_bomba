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
  findAll(
    @Query("search") search?: string,
    @Query("page") page?: string,
    @Query("limit") limit?: string
  ) {
    try {
      // Convert string query params to numbers
      const pageNum = page ? parseInt(page, 10) : undefined;
      const limitNum = limit ? parseInt(limit, 10) : undefined;

      console.log("FindAll called with:", { search, page: pageNum, limit: limitNum });
      console.log("Original types:", { pageType: typeof page, limitType: typeof limit });

      return this.productsService.findAll(search, pageNum, limitNum);
    } catch (error) {
      console.error("Error in findAll controller:", error);
      console.error("Full error:", error);
      throw error;
    }
  }

  @Get("by-id/:id")
  // Los empleados, supervisores y administradores pueden ver detalles de productos
  findOne(@Param("id") id: string, @Request() req: any) {
    console.log("🔍 GET /products/by-id/" + id + " called by:", req.user?.role);
    // Los administradores y supervisores pueden ver todos los productos (incluso inactivos)
    if (
      req.user?.role === UserRole.ADMIN ||
      req.user?.role === UserRole.SUPERVISOR
    ) {
      console.log("👑 Admin/Supervisor access - using findOneForAdmin");
      return this.productsService.findOneForAdmin(id);
    }
    // Los empleados solo ven productos activos
    console.log("👤 Employee access - using findOne (active only)");
    return this.productsService.findOne(id);
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

    return this.productsService.update(id, updateProductDto, req.user?.userId);
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
  @Roles(UserRole.ADMIN, UserRole.SUPERVISOR)
  findAllTemporaryProducts(@Request() req: any) {
    console.log('🔍 GET /products/temporary called by:', {
      userId: req.user?.userId,
      username: req.user?.username,
      role: req.user?.role,
      roleType: typeof req.user?.role,
    });
    return this.productsService.findAllTemporaryProducts();
  }

  @Get("temporary/:id")
  @Roles(UserRole.ADMIN)
  findTemporaryProduct(@Param("id") id: string) {
    return this.productsService.findTemporaryProduct(id);
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
  completeTemporaryProductBySupervisor(
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
    return this.productsService.completeTemporaryProductBySupervisor(
      id,
      supervisorId,
      body.notes,
      body.barcode,
    );
  }

  @Delete("temporary/:id")
  @Roles(UserRole.ADMIN)
  deleteTemporaryProduct(@Param("id") id: string) {
    return this.productsService.deleteTemporaryProduct(id);
  }
}
