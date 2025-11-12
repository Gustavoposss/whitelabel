import { DataSource } from 'typeorm';
import { Client } from '../clients/entities/client.entity';
import { User } from '../users/entities/user.entity';
import { seedDatabase } from './seed';

const dataSource = new DataSource({
  type: 'sqlite',
  database: 'whitelabel.db',
  entities: [Client, User],
  synchronize: true,
  logging: false,
});

async function runSeed() {
  try {
    await dataSource.initialize();
    await seedDatabase(dataSource);
    await dataSource.destroy();
  } catch (error) {
    console.error('Error running seed:', error);
    await dataSource.destroy();
    process.exit(1);
  }
}

runSeed();

