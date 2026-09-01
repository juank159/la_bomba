import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Invoice, InvoiceStatus } from './entities/invoice.entity';
import { InvoiceItem } from './entities/invoice-item.entity';
import { Product } from '../products/entities/product.entity';
import { PaymentMethod } from '../credits/entities/payment-method.entity';
import { CreateInvoiceDto } from './dto/create-invoice.dto';

@Injectable()
export class InvoicesService {
  constructor(
    @InjectRepository(Invoice)
    private invoicesRepository: Repository<Invoice>,
    @InjectRepository(InvoiceItem)
    private invoiceItemsRepository: Repository<InvoiceItem>,
    @InjectRepository(Product)
    private productsRepository: Repository<Product>,
    @InjectRepository(PaymentMethod)
    private paymentMethodsRepository: Repository<PaymentMethod>,
  ) {}

  async create(dto: CreateInvoiceDto, username: string): Promise<Invoice> {
    const paymentMethod = await this.paymentMethodsRepository.findOne({
      where: { id: dto.paymentMethodId },
    });
    if (!paymentMethod) {
      throw new BadRequestException('Método de pago no encontrado');
    }

    // Cargar todos los productos de una vez y validar que existan
    const productIds = dto.items.map(item => item.productId);
    const products = await this.productsRepository.find({
      where: { id: In(productIds) },
    });
    const productsById = new Map(products.map(p => [p.id, p]));

    const missingId = productIds.find(id => !productsById.has(id));
    if (missingId) {
      throw new BadRequestException(`Producto no encontrado: ${missingId}`);
    }

    let subtotal = 0;
    let tax = 0;

    // precioA ya incluye el IVA, así que el IVA se EXTRAE del precio de venta
    // (no se suma encima). El total de la línea es siempre unitPrice * quantity.
    const itemsData = dto.items.map(item => {
      const product = productsById.get(item.productId)!;
      const unitPrice = Number(product.precioA);
      const ivaPercent = Number(product.iva) || 0;
      const lineTotal = unitPrice * item.quantity;
      const lineTax = lineTotal - lineTotal / (1 + ivaPercent / 100);
      const lineSubtotal = lineTotal - lineTax;

      subtotal += lineSubtotal;
      tax += lineTax;

      return {
        productId: product.id,
        description: product.description,
        quantity: item.quantity,
        unitPrice,
        ivaPercent,
        subtotal: lineSubtotal,
        taxAmount: lineTax,
      };
    });

    const invoice = this.invoicesRepository.create({
      clientId: dto.clientId || null,
      paymentMethodId: dto.paymentMethodId,
      subtotal,
      tax,
      total: subtotal + tax, // = suma de unitPrice*quantity (el IVA ya estaba incluido ahí)
      status: InvoiceStatus.COMPLETED,
      createdBy: username,
    });

    const savedInvoice = await this.invoicesRepository.save(invoice);

    const invoiceItems = itemsData.map(item =>
      this.invoiceItemsRepository.create({
        invoiceId: savedInvoice.id,
        ...item,
      }),
    );
    await this.invoiceItemsRepository.save(invoiceItems);

    return this.findOne(savedInvoice.id);
  }

  async findAll(): Promise<Invoice[]> {
    return this.invoicesRepository.find({
      relations: ['items', 'client', 'paymentMethod'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Invoice> {
    const invoice = await this.invoicesRepository.findOne({
      where: { id },
      relations: ['items', 'client', 'paymentMethod'],
    });

    if (!invoice) {
      throw new NotFoundException(`Factura con ID ${id} no encontrada`);
    }

    return invoice;
  }

  async cancel(id: string, username: string): Promise<Invoice> {
    const invoice = await this.findOne(id);

    if (invoice.status === InvoiceStatus.CANCELLED) {
      throw new BadRequestException('Esta factura ya está anulada');
    }

    await this.invoicesRepository.update(id, {
      status: InvoiceStatus.CANCELLED,
      cancelledBy: username,
      cancelledAt: new Date(),
    });

    return this.findOne(id);
  }
}
