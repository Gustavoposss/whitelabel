#!/bin/bash

echo "========================================"
echo "🧪 Testando API - E-commerce Whitelabel"
echo "========================================"
echo ""

BASE_URL="http://localhost:3000"

# Test 1: Login
echo "1. 🔐 Testando Login..."
echo ""
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user1@cliente1.com",
    "password": "password123"
  }')

echo "$LOGIN_RESPONSE" | python -m json.tool 2>/dev/null || echo "$LOGIN_RESPONSE"
echo ""

# Extrair token
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Não foi possível obter o token. Verifique se a API está rodando."
    exit 1
fi

echo "✅ Token obtido: ${TOKEN:0:50}..."
echo ""

# Test 2: Listar Clientes
echo "2. 📋 Listando Clientes..."
echo ""
curl -s "$BASE_URL/clients" | python -m json.tool 2>/dev/null || curl -s "$BASE_URL/clients"
echo ""
echo ""

# Test 2.5: Obter Cliente Atual
echo "2.5. 🎨 Obtendo informações do cliente atual (whitelabel)..."
echo ""
CURRENT_CLIENT=$(curl -s "$BASE_URL/clients/current" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Client-URL: cliente1.local")

if [ -z "$CURRENT_CLIENT" ]; then
    echo "❌ Nenhuma resposta recebida"
elif echo "$CURRENT_CLIENT" | grep -q "primaryColor"; then
    echo "✅ Cliente atual obtido com sucesso:"
    if command -v jq > /dev/null 2>&1; then
        echo "$CURRENT_CLIENT" | jq '.'
    elif command -v python > /dev/null 2>&1; then
        echo "$CURRENT_CLIENT" | python -m json.tool 2>/dev/null
    else
        echo "$CURRENT_CLIENT" | head -c 500
    fi
    echo ""
    PRIMARY_COLOR=$(echo "$CURRENT_CLIENT" | grep -o '"primaryColor":"[^"]*' | cut -d'"' -f4)
    echo "🎨 Cor primária do cliente: $PRIMARY_COLOR"
else
    echo "⚠️  Resposta inesperada:"
    echo "$CURRENT_CLIENT" | head -c 200
fi
echo ""
echo ""

# Test 3: Listar Produtos
echo "3. 📦 Listando Produtos (primeiros 5)..."
echo ""
PRODUCTS_RESPONSE=$(curl -s "$BASE_URL/products" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Client-URL: cliente1.local")

if [ -z "$PRODUCTS_RESPONSE" ]; then
    echo "❌ Nenhuma resposta recebida"
    echo "   Testando sem header X-Client-URL..."
    PRODUCTS_RESPONSE=$(curl -s "$BASE_URL/products" \
      -H "Authorization: Bearer $TOKEN")
fi

if [ -z "$PRODUCTS_RESPONSE" ]; then
    echo "❌ Resposta vazia"
elif echo "$PRODUCTS_RESPONSE" | grep -q "error\|Error\|ERROR"; then
    echo "❌ Erro na resposta:"
    echo "$PRODUCTS_RESPONSE" | head -20
elif echo "$PRODUCTS_RESPONSE" | grep -q "\["; then
    # Count products by counting "provider" field (more reliable than counting id)
    PRODUCT_COUNT=$(echo "$PRODUCTS_RESPONSE" | grep -o '"provider"' | wc -l)
    if [ "$PRODUCT_COUNT" -eq 0 ]; then
        # Try counting by "id" field as fallback
        PRODUCT_COUNT=$(echo "$PRODUCTS_RESPONSE" | grep -o '"id"' | wc -l)
    fi
    echo "✅ Produtos encontrados: $PRODUCT_COUNT"
    echo ""
    echo "📦 Primeiro produto (amostra):"
    # Use jq if available, otherwise use head
    if command -v jq > /dev/null 2>&1; then
        echo "$PRODUCTS_RESPONSE" | jq '.[0]' 2>/dev/null | head -30
    elif command -v python > /dev/null 2>&1; then
        echo "$PRODUCTS_RESPONSE" | python -m json.tool 2>/dev/null | head -40
    else
        echo "$PRODUCTS_RESPONSE" | head -c 500
    fi
else
    echo "⚠️  Resposta inesperada (tamanho: ${#PRODUCTS_RESPONSE} chars):"
    echo "$PRODUCTS_RESPONSE" | head -c 200
fi
echo ""

# Test 4: Filtrar Produtos
echo "4. 🔍 Filtrando Produtos (provider=brazilian)..."
echo ""
FILTERED_RESPONSE=$(curl -s "$BASE_URL/products?provider=brazilian" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-Client-URL: cliente1.local")

if [ -z "$FILTERED_RESPONSE" ]; then
    echo "❌ Nenhuma resposta recebida"
elif echo "$FILTERED_RESPONSE" | grep -q "brazilian\|european"; then
    FILTERED_COUNT=$(echo "$FILTERED_RESPONSE" | grep -o '"provider":"brazilian"' | wc -l)
    if [ "$FILTERED_COUNT" -eq 0 ]; then
        FILTERED_COUNT=$(echo "$FILTERED_RESPONSE" | grep -o '"provider"' | wc -l)
    fi
    echo "✅ Produtos filtrados encontrados: $FILTERED_COUNT"
    echo ""
    echo "📦 Primeiro produto filtrado:"
    if command -v jq > /dev/null 2>&1; then
        echo "$FILTERED_RESPONSE" | jq '.[0]' 2>/dev/null | head -30
    elif command -v python > /dev/null 2>&1; then
        echo "$FILTERED_RESPONSE" | python -m json.tool 2>/dev/null | head -40
    else
        echo "$FILTERED_RESPONSE" | head -c 500
    fi
else
    echo "⚠️  Resposta inesperada (tamanho: ${#FILTERED_RESPONSE} chars):"
    echo "$FILTERED_RESPONSE" | head -c 200
fi
echo ""

echo "========================================"
echo "✅ Testes concluídos!"
echo "========================================"
echo ""
echo "📚 Swagger: $BASE_URL/api/docs"
echo "🔑 Token: ${TOKEN:0:50}..."
echo ""

