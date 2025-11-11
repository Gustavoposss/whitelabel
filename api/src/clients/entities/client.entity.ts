import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('clients')
export class Client {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  name: string;

  @Column({ unique: true })
  url: string;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true, default: '#3B82F6' })
  primaryColor: string; // Cor primária para tema whitelabel (ex: #3B82F6 para azul, #10B981 para verde, #8B5CF6 para roxo)

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

