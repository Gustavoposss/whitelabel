# E-commerce Whitelabel - Processo Seletivo IN8Devnology 2025

Sistema de e-commerce whitelabel desenvolvido com NestJS (API) e Flutter (Frontend).

## 🚀 Tecnologias

### API
- **NestJS** - Framework Node.js
- **TypeORM** - ORM para banco de dados
- **SQLite** - Banco de dados
- **JWT** - Autenticação
- **Swagger** - Documentação da API

### Frontend
- **Flutter** - Framework multiplataforma
- **Dart** - Linguagem de programação
- **Provider** - Gerenciamento de estado

## 📋 Funcionalidades

### API (✅ Completa)
- ✅ Autenticação JWT
- ✅ Sistema whitelabel (diferenciação de clientes por URL)
- ✅ Integração com 2 fornecedores (Brazilian e European)
- ✅ Listagem e filtro de produtos
- ✅ Suporte a tema por cliente (cor primária)
- ✅ Documentação Swagger
- ✅ Collection Postman

### Frontend (✅ Completo)
- ✅ Login
- ✅ Listagem de produtos
- ✅ Filtros de produtos
- ✅ Whitelabel (tema dinâmico)
- ✅ Detalhes do produto
- ✅ Busca e ordenação

## 🛠️ Instalação e Execução

### Pré-requisitos
- Node.js (v18+)
- npm ou yarn
- Flutter (v3.0+)
- Dart (v3.0+)

### 🔧 API (NestJS)

#### 1. Instalar dependências (primeira vez)
```bash
cd api
npm install
```

#### 2. Popular banco de dados (primeira vez)
```bash
npm run seed
```

#### 3. Iniciar API em modo desenvolvimento
```bash
npm run start:dev
```

A API estará disponível em: `http://localhost:3000`  
Swagger: `http://localhost:3000/api/docs`

#### 📋 Comandos Úteis da API
- `npm run start:dev` - Inicia em modo desenvolvimento (watch mode)
- `npm run start` - Inicia em modo produção
- `npm run build` - Compila o projeto
- `npm run seed` - Popular banco de dados

### 📱 Frontend (Flutter)

#### 1. Instalar dependências (primeira vez)
```bash
cd app
flutter pub get
```

#### 2. Executar aplicação

**Web (Chrome):**
```bash
flutter run -d chrome
```

**Web (Edge):**
```bash
flutter run -d edge
```

**Windows:**
```bash
flutter run -d windows
```

**Android (com emulador/dispositivo conectado):**
```bash
flutter run
```

**iOS (apenas macOS):**
```bash
flutter run -d ios
```

#### 📋 Comandos Úteis do Flutter
- `flutter pub get` - Instala/atualiza dependências
- `flutter run` - Executa a aplicação
- `flutter run -d chrome` - Executa no Chrome
- `flutter analyze` - Analisa o código
- `flutter clean` - Limpa o projeto
- `flutter doctor` - Verifica o ambiente

## 📚 Documentação

- **Swagger**: http://localhost:3000/api/docs
- **Collection Postman**: `docs/postman-collection.json`
- **Arquitetura**: `docs/ARQUITETURA.md`
- **Status do Projeto**: `STATUS.md`
- **Comandos**: `COMANDOS.md`

## 🧪 Testes

```bash
cd api
bash testar-api.sh
```

## 📝 Credenciais de Teste

- **Cliente 1** (Verde #10B981): `user1@cliente1.com` / `password123`
- **Cliente 2** (Laranja #F59E0B): `user2@cliente2.com` / `password123`
- **Admin**: `admin@example.com` / `password123`

## 🎯 Critérios de Aceite

### API
- [x] Feito usando NestJS
- [x] Funcionalidade de Login
- [x] Funcionalidade para diferenciar os clientes
- [x] Collection e Documentação dos endpoints
- [x] DER do Banco de Dados

### Frontend
- [x] Feito usando Flutter
- [x] Funcionalidade de Login
- [x] Listar e filtrar os produtos
- [x] Consulta de produtos deve bater na API
- [x] Funcionalidade de Whitelabel
- [x] Documentação da arquitetura

## 📦 Estrutura do Projeto

```
Processo-Seletivo-da-IN8Devnology/
├── api/                 # API NestJS
├── app/                 # App Flutter
├── docs/                # Documentação
├── README.md            # README principal
├── STATUS.md            # Status do projeto
└── COMANDOS.md          # Guia de comandos
```

## 🔗 Links

- **Repositório**: https://github.com/Gustavoposss/whitelabel.git
- **API Base**: http://localhost:3000

## 📄 Licença

Este projeto foi desenvolvido para o processo seletivo da IN8Devnology 2025.

