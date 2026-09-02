import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { VegetableCategory } from './vegetable-category.entity';

export enum PricingType {
  // Se vende por peso: el total sale de multiplicar pricePerKg x el peso que
  // envía la báscula (ej. la papa: se pesan 350g y se cobra proporcional al kilo).
  WEIGHT = 'weight',
  // Precio fijo por unidad, no se pesa (ej. una manzana empacada, una bolsa cerrada).
  FIXED = 'fixed',
}

@Entity('vegetable_items')
export class VegetableItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @ManyToOne(() => VegetableCategory, { nullable: true })
  @JoinColumn({ name: 'category_id' })
  category: VegetableCategory;

  @Column({ name: 'category_id', nullable: true })
  categoryId: string;

  @Column({
    type: 'enum',
    enum: PricingType,
    name: 'pricing_type',
  })
  pricingType: PricingType;

  // Precio por kilo, solo aplica cuando pricingType = WEIGHT
  @Column('decimal', { name: 'price_per_kg', precision: 10, scale: 2, nullable: true })
  pricePerKg: number;

  // Precio fijo por unidad, solo aplica cuando pricingType = FIXED
  @Column('decimal', { name: 'fixed_price', precision: 10, scale: 2, nullable: true })
  fixedPrice: number;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  // Foto del producto en base64 (sin el prefijo "data:image/...;base64,"),
  // comprimida en el cliente antes de subir. Se guarda directo en la fila
  // porque el backend en Render no tiene almacenamiento de archivos
  // persistente entre despliegues - no hay dónde guardar un archivo subido.
  @Column({ type: 'text', nullable: true })
  image: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
