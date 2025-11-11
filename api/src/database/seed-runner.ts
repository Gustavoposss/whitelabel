import { DataSource } from 'typeorm';
import { Client } from '../clients/entities/client.entity';
import { User } from '../users/entities/user.entity';
import { seedDatabase } from './seed';

const dataSource = new DataSource({
  type: 'sqlite',
  database: 'whitelabel.db',
  entities: [Client, User],
  synchronize: true, // Create tables if they don't exist
  logging: true,
});

async function runSeed() {
  try {
    await dataSource.initialize();
    console.log('📦 Database connected');

    await seedDatabase(dataSource);

    console.log('✅ Seed completed successfully');
    await dataSource.destroy();
  } catch (error) {
    console.error('❌ Error running seed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

runSeed();

