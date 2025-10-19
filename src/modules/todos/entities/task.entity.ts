import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { Todo } from './todo.entity';

@Entity('tasks')
export class Task {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  description: string;

  @Column({ default: false })
  isCompleted: boolean;

  @ManyToOne(() => Todo, todo => todo.tasks, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'todo_id' })
  todo: Todo;

  @Column({ name: 'todo_id' })
  todoId: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}