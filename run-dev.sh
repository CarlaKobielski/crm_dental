#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Executando Dental CRM em modo de desenvolvimento ===${NC}"

# Verificar se o ambiente está rodando
if ! docker-compose -f docker-compose.dev.yml ps | grep -q "supabase"; then
  echo -e "${YELLOW}O ambiente de desenvolvimento não está rodando. Iniciando...${NC}"
  docker-compose -f docker-compose.dev.yml up -d
  
  echo -e "${YELLOW}Aguardando o Supabase iniciar (isso pode levar alguns minutos)...${NC}"
  sleep 30
else
  echo -e "${GREEN}Ambiente de desenvolvimento já está rodando.${NC}"
fi

# Executar a aplicação em modo de desenvolvimento
echo -e "${GREEN}Iniciando a aplicação em modo de desenvolvimento...${NC}"
echo -e "${YELLOW}Pressione Ctrl+C para parar.${NC}"
echo ""

npm run dev

