import { DataSource } from 'typeorm';
import { Client } from '../clients/entities/client.entity';
import { User } from '../users/entities/user.entity';
import * as bcrypt from 'bcrypt';

export async function seedDatabase(dataSource: DataSource) {
  const clientRepository = dataSource.getRepository(Client);
  const userRepository = dataSource.getRepository(User);

  const hashedPassword = await bcrypt.hash('password123', 10);

  let client1 = await clientRepository.findOne({ where: { url: 'cliente1.local' } });
  if (!client1) {
    client1 = clientRepository.create({
      name: 'Cliente 1',
      url: 'cliente1.local',
      description: 'Primeiro cliente do sistema',
      primaryColor: '#10B981',
      isActive: true,
    });
  } else {
    client1.primaryColor = '#10B981';
  }
  const savedClient1 = await clientRepository.save(client1);

  let client2 = await clientRepository.findOne({ where: { url: 'cliente2.local' } });
  if (!client2) {
    client2 = clientRepository.create({
      name: 'Cliente 2',
      url: 'cliente2.local',
      description: 'Segundo cliente do sistema',
      primaryColor: '#F59E0B',
      isActive: true,
    });
  } else {
    client2.primaryColor = '#F59E0B';
  }
  const savedClient2 = await clientRepository.save(client2);

  let user1 = await userRepository.findOne({ where: { email: 'user1@cliente1.com' } });
  if (!user1) {
    user1 = userRepository.create({
      email: 'user1@cliente1.com',
      password: hashedPassword,
      name: 'Usuário Cliente 1',
      clientId: savedClient1.id,
      isActive: true,
    });
  } else {
    user1.clientId = savedClient1.id;
  }
  await userRepository.save(user1);

  let user2 = await userRepository.findOne({ where: { email: 'user2@cliente2.com' } });
  if (!user2) {
    user2 = userRepository.create({
      email: 'user2@cliente2.com',
      password: hashedPassword,
      name: 'Usuário Cliente 2',
      clientId: savedClient2.id,
      isActive: true,
    });
  } else {
    user2.clientId = savedClient2.id;
  }
  await userRepository.save(user2);

  let adminUser = await userRepository.findOne({ where: { email: 'admin@example.com' } });
  if (!adminUser) {
    adminUser = userRepository.create({
      email: 'admin@example.com',
      password: hashedPassword,
      name: 'Administrador',
      isActive: true,
    });
    await userRepository.save(adminUser);
  }
}

