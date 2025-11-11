import { DataSource } from 'typeorm';
import { Client } from '../clients/entities/client.entity';
import { User } from '../users/entities/user.entity';
import * as bcrypt from 'bcrypt';

export async function seedDatabase(dataSource: DataSource) {
  const clientRepository = dataSource.getRepository(Client);
  const userRepository = dataSource.getRepository(User);

  // Create clients
  const client1 = clientRepository.create({
    name: 'Cliente 1',
    url: 'cliente1.local',
    description: 'Primeiro cliente do sistema',
    primaryColor: '#10B981', // Verde (como exemplo do devnology.com)
    isActive: true,
  });

  const client2 = clientRepository.create({
    name: 'Cliente 2',
    url: 'cliente2.local',
    description: 'Segundo cliente do sistema',
    primaryColor: '#8B5CF6', // Roxo (como exemplo do in8.com)
    isActive: true,
  });

  const savedClient1 = await clientRepository.save(client1);
  const savedClient2 = await clientRepository.save(client2);

  console.log('✅ Clients created:', savedClient1.name, savedClient2.name);

  // Create users
  const hashedPassword = await bcrypt.hash('password123', 10);

  const user1 = userRepository.create({
    email: 'user1@cliente1.com',
    password: hashedPassword,
    name: 'Usuário Cliente 1',
    clientId: savedClient1.id,
    isActive: true,
  });

  const user2 = userRepository.create({
    email: 'user2@cliente2.com',
    password: hashedPassword,
    name: 'Usuário Cliente 2',
    clientId: savedClient2.id,
    isActive: true,
  });

  const adminUser = userRepository.create({
    email: 'admin@example.com',
    password: hashedPassword,
    name: 'Administrador',
    isActive: true,
  });

  await userRepository.save([user1, user2, adminUser]);

  console.log('✅ Users created');
  console.log('📧 Login credentials:');
  console.log('   - user1@cliente1.com / password123');
  console.log('   - user2@cliente2.com / password123');
  console.log('   - admin@example.com / password123');
}

