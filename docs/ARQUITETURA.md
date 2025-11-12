# Arquitetura do Projeto - E-commerce Whitelabel

## 📋 Visão Geral

Este documento descreve a arquitetura do sistema de e-commerce whitelabel, incluindo a API NestJS e o frontend Flutter.

---

## 🏗️ Arquitetura da API (NestJS)

### Estrutura Modular

A API segue a arquitetura modular do NestJS, organizada em módulos independentes:

```
api/src/
├── app.module.ts              # Módulo raiz
├── auth/                      # Autenticação
│   ├── auth.module.ts
│   ├── auth.service.ts
│   ├── auth.controller.ts
│   ├── guards/                # Guards de autenticação
│   └── strategies/            # JWT Strategy
├── clients/                   # Clientes (Whitelabel)
│   ├── clients.module.ts
│   ├── clients.service.ts
│   ├── clients.controller.ts
│   ├── entities/              # Entidade Client
│   └── dto/                   # Data Transfer Objects
├── users/                     # Usuários
│   ├── users.module.ts
│   ├── users.service.ts
│   ├── entities/              # Entidade User
│   └── dto/
├── products/                  # Produtos
│   ├── products.module.ts
│   ├── products.service.ts
│   ├── products.controller.ts
│   ├── interfaces/            # Interfaces de produto
│   └── dto/
├── common/                    # Recursos compartilhados
│   └── middleware/            # Middleware de identificação de cliente
└── database/                  # Seed do banco de dados
    ├── seed.ts
    └── seed-runner.ts
```

### Padrões Arquiteturais

#### 1. **Módulos**
Cada funcionalidade é organizada em um módulo próprio, seguindo o princípio de responsabilidade única.

#### 2. **Controllers**
Responsáveis por receber requisições HTTP e retornar respostas.

#### 3. **Services**
Contêm a lógica de negócio e interação com o banco de dados.

#### 4. **Entities**
Definem a estrutura das tabelas do banco de dados usando TypeORM.

#### 5. **DTOs (Data Transfer Objects)**
Validam e transformam dados de entrada e saída.

#### 6. **Middleware**
Middleware global para identificar o cliente baseado na URL ou header.

### Fluxo de Autenticação

1. **Login**: `POST /auth/login`
   - Valida credenciais
   - Gera JWT token
   - Retorna token e informações do usuário

2. **Proteção de Rotas**: `JwtAuthGuard`
   - Valida JWT token
   - Extrai informações do usuário
   - Disponibiliza `req.user` nas rotas protegidas

### Whitelabel (Identificação de Cliente)

A identificação do cliente segue esta ordem de prioridade:

1. **Cliente do usuário autenticado** (`req.user.clientId`)
2. **Cliente identificado pelo middleware** (URL/header)
3. **Cliente do header X-Client-URL**

### Integração com Fornecedores

A API consome dados de dois fornecedores externos:

1. **Brazilian Provider**: Campos em português
2. **European Provider**: Campos em inglês

Os dados são normalizados para um formato único (`Product` interface).

---

## 📱 Arquitetura do Frontend (Flutter)

### Padrão Provider

O frontend utiliza o padrão **Provider** para gerenciamento de estado:

```
app/lib/
├── main.dart                  # Ponto de entrada
├── models/                    # Modelos de dados
│   ├── product.dart
│   ├── client.dart
│   └── auth.dart
├── services/                  # Serviços
│   ├── api_service.dart       # Comunicação com API
│   └── storage_service.dart   # Armazenamento local
├── providers/                 # Gerenciamento de estado
│   ├── auth_provider.dart     # Estado de autenticação
│   ├── theme_provider.dart    # Estado do tema (whitelabel)
│   └── products_provider.dart # Estado dos produtos
├── screens/                   # Telas
│   ├── login_screen.dart
│   ├── products_screen.dart
│   ├── product_detail_screen.dart
│   └── widgets/               # Widgets específicos de tela
│       └── filters_sidebar.dart
└── widgets/                   # Widgets reutilizáveis
    └── product_image.dart
```

### Gerenciamento de Estado

#### 1. **AuthProvider**
- Gerencia autenticação do usuário
- Armazena token JWT
- Controla estado de login/logout

#### 2. **ThemeProvider**
- Carrega informações do cliente atual
- Aplica tema dinâmico (cor primária)
- Atualiza tema quando cliente muda

#### 3. **ProductsProvider**
- Gerencia lista de produtos
- Aplica filtros (frontend e backend)
- Controla estado de carregamento

### Fluxo de Dados

```
User Action
    ↓
Provider (Business Logic)
    ↓
Service (API Call)
    ↓
API (NestJS)
    ↓
External Provider
    ↓
API Response
    ↓
Service (Data Transformation)
    ↓
Provider (State Update)
    ↓
UI (Rebuild)
```

### Whitelabel (Tema Dinâmico)

1. **Login**: Usuário faz login
2. **Identificação**: API identifica cliente pelo `clientId` do usuário
3. **Carregamento**: `ThemeProvider` carrega informações do cliente
4. **Aplicação**: Tema é aplicado dinamicamente (cor primária)
5. **Atualização**: UI é atualizada com o tema do cliente

---

## 🔄 Fluxo de Autenticação

### 1. Login
```
Flutter (LoginScreen)
    ↓
AuthProvider.login()
    ↓
ApiService.login()
    ↓
API (POST /auth/login)
    ↓
AuthService.validateUser()
    ↓
JWT Token Generation
    ↓
Response (token + user)
    ↓
StorageService.saveToken()
    ↓
ThemeProvider.refreshTheme()
    ↓
Navigation to ProductsScreen
```

### 2. Requisições Autenticadas
```
Flutter Request
    ↓
ApiService (with token)
    ↓
API (JwtAuthGuard)
    ↓
JWT Validation
    ↓
req.user (available)
    ↓
Controller/Service
    ↓
Response
```

---

## 🎨 Whitelabel (Tema Dinâmico)

### Como Funciona

1. **Banco de Dados**: Cada cliente tem uma `primaryColor` associada
2. **API**: Endpoint `/clients/current` retorna informações do cliente atual
3. **Flutter**: `ThemeProvider` carrega e aplica a cor primária
4. **UI**: Todos os elementos visuais usam a cor do cliente

### Cores dos Clientes

- **Cliente 1**: Verde (#10B981)
- **Cliente 2**: Laranja (#F59E0B)

---

## 📦 Integração com Fornecedores

### Normalização de Dados

A API normaliza dados de dois fornecedores com estruturas diferentes:

#### Brazilian Provider
- Campos em português: `nome`, `descricao`, `preco`, `categoria`, `imagem`
- Formato de preço: String ou número
- Estrutura: Array ou objeto com chaves numéricas

#### European Provider
- Campos em inglês: `name`, `description`, `price`, `category`, `image`, `gallery`
- Formato de preço: Número
- Estrutura: Array de objetos

#### Transformação
A função `transformToProduct()` normaliza ambos os formatos para a interface `Product`:

```typescript
interface Product {
  id: string;
  name: string;
  description?: string;
  price: number;
  category?: string;
  image?: string;
  provider: 'brazilian' | 'european';
  // ... outros campos opcionais
}
```

---

## 🔐 Segurança

### Autenticação
- **JWT**: Tokens JWT para autenticação
- **Guards**: Proteção de rotas com `JwtAuthGuard`
- **Validation**: Validação de dados com `class-validator`

### Armazenamento
- **Token**: Armazenado localmente (SharedPreferences)
- **Senha**: Hash com bcrypt no backend
- **CORS**: Configurado para permitir requisições do frontend

---

## 📊 Banco de Dados

### Entidades

#### Client
- `id`: ID único
- `name`: Nome do cliente
- `url`: URL única do cliente
- `description`: Descrição
- `primaryColor`: Cor primária do tema
- `isActive`: Status ativo/inativo

#### User
- `id`: ID único
- `email`: Email do usuário
- `password`: Senha (hash)
- `name`: Nome do usuário
- `clientId`: ID do cliente associado
- `isActive`: Status ativo/inativo

### Relacionamentos
- `User` → `Client` (Many-to-One)
- Um usuário pertence a um cliente (opcional)

---

## 🚀 Decisões de Design

### API
1. **SQLite**: Banco de dados simples para desenvolvimento
2. **TypeORM**: ORM para facilitar operações no banco
3. **Swagger**: Documentação automática da API
4. **Middleware Global**: Identificação de cliente em todas as rotas

### Frontend
1. **Provider Pattern**: Gerenciamento de estado simples e eficiente
2. **Separation of Concerns**: Separação clara entre models, services, providers e screens
3. **Responsive Design**: Layout adaptável para diferentes tamanhos de tela
4. **Cached Network Image**: Cache de imagens para melhor performance

### Filtros
1. **Backend Filters**: Nome, categoria, fornecedor (filtrados na API)
2. **Frontend Filters**: Preço, departamento (filtrados localmente)
3. **Dinâmico**: Opções de filtro baseadas nos dados reais dos produtos

---

## 📝 Boas Práticas Implementadas

### API
- ✅ Modularização clara
- ✅ Validação de dados
- ✅ Tratamento de erros
- ✅ Documentação Swagger
- ✅ Código limpo e organizado

### Frontend
- ✅ Separação de responsabilidades
- ✅ Reutilização de componentes
- ✅ Tratamento de erros
- ✅ Loading states
- ✅ Empty states
- ✅ Responsive design

---

## 🔗 Diagrama de Fluxo

```
┌─────────────┐
│   Flutter   │
│   (Frontend)│
└──────┬──────┘
       │
       │ HTTP Request (JWT)
       ↓
┌─────────────┐
│  NestJS API │
│  (Backend)  │
└──────┬──────┘
       │
       ├──→ SQLite Database
       │
       └──→ External Providers
            ├──→ Brazilian Provider
            └──→ European Provider
```

---

## 📚 Referências

- [NestJS Documentation](https://docs.nestjs.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [TypeORM Documentation](https://typeorm.io/)

