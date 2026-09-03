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

  // Saldo actual de inventario (kg para productos que se venden por peso,
  // unidades para los de precio fijo - según pricingType). Se mantiene en
  // sincronía con vegetable_stock_movements: nunca se edita directo desde
  // afuera del service, siempre a través de un movimiento registrado.
  @Column('decimal', { precision: 10, scale: 3, default: 0 })
  stock: number;

  // Foto del producto: se sube a Cloudinary (el cliente manda el JPEG ya
  // comprimido en base64, el backend lo sube con sus credenciales y guarda
  // acá la URL pública). imagePublicId se usa solo para poder borrarla de
  // Cloudinary al reemplazarla o quitarla.
  @Column({ name: 'image_url', nullable: true })
  imageUrl: string;

  @Column({ name: 'image_public_id', nullable: true })
  imagePublicId: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
