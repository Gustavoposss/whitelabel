# E-commerce Whitelabel - Processo Seletivo IN8Devnology 2025

Sistema de e-commerce whitelabel desenvolvido com NestJS (API) e Flutter (Frontend).

## 🚀 Tecnologias

### API
- **NestJS** - Framework Node.js
- **TypeORM** - ORM para banco de dados
- **SQLite** - Banco de dados
- **JWT** - Autenticação
- **Swagger** - Documentação da API

### Frontend (Em desenvolvimento)
- **Flutter** - Framework multiplataforma
- **Dart** - Linguagem de programação

## 📋 Funcionalidades

### API (✅ Completa)
- ✅ Autenticação JWT
- ✅ Sistema whitelabel (diferenciação de clientes por URL)
- ✅ Integração com 2 fornecedores (Brazilian e European)
- ✅ Listagem e filtro de produtos
- ✅ Suporte a tema por cliente (cor primária)
- ✅ Documentação Swagger
- ✅ Collection Postman

### Frontend (⏳ Em desenvolvimento)
- ⏳ Login
- ⏳ Listagem de produtos
- ⏳ Filtros de produtos
- ⏳ Whitelabel (tema dinâmico)

## 🛠️ Instalação

### Pré-requisitos
- Node.js (v18+)
- npm ou yarn
- Flutter (v3.0+)
- Dart (v3.0+)

### API

```bash
cd api
npm install
npm run seed  # Popular banco de dados
npm run start:dev
```

A API estará disponível em: `http://localhost:3000`
Swagger: `http://localhost:3000/api/docs`

### Frontend

```bash
# Em desenvolvimento
```

## 📚 Documentação

- **Swagger**: http://localhost:3000/api/docs
- **Collection Postman**: `docs/postman-collection.json`
- **Status do Projeto**: `STATUS.md`

## 🧪 Testes

```bash
cd api
bash testar-api.sh
```

## 📝 Credenciais de Teste

- **Cliente 1**: `user1@cliente1.com` / `password123`
- **Cliente 2**: `user2@cliente2.com` / `password123`
- **Admin**: `admin@example.com` / `password123`

## 🎯 Critérios de Aceite

### API
- [x] Feito usando NestJS
- [x] Funcionalidade de Login
- [x] Funcionalidade para diferenciar os clientes
- [x] Collection e Documentação dos endpoints
- [x] DER do Banco de Dados

### Frontend
- [ ] Feito usando Flutter
- [ ] Funcionalidade de Login
- [ ] Listar e filtrar os produtos
- [ ] Consulta de produtos deve bater na API
- [ ] Funcionalidade de Whitelabel
- [ ] Documentação da arquitetura

## 📦 Estrutura do Projeto

```
Processo-Seletivo-da-IN8Devnology/
├── api/                 # API NestJS
├── app/                 # App Flutter (em desenvolvimento)
├── docs/                # Documentação
└── STATUS.md            # Status do projeto
```

## 🔗 Links

- **Repositório**: https://github.com/Gustavoposss/whitelabel.git
- **API Base**: http://localhost:3000

## 📄 Licença

Este projeto foi desenvolvido para o processo seletivo da IN8Devnology 2025.

