#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Restaurando backup do ambiente local do Dental CRM ===${NC}"

# Verificar se o arquivo de backup foi fornecido
if [ -z "$1" ]; then
  echo -e "${RED}Nenhum arquivo de backup especificado.${NC}"
  echo -e "${YELLOW}Uso:${NC} ./restore-local.sh caminho/para/arquivo_backup.sql"
  exit 1
fi

# Verificar se o arquivo existe
if [ ! -f "$1" ]; then
  echo -e "${RED}Arquivo de backup não encontrado: $1${NC}"
  exit 1
fi

# Verificar se o ambiente está rodando
if ! docker-compose -f docker-compose.dev.yml ps | grep -q "supabase"; then
  echo -e "${RED}O ambiente de desenvolvimento não está rodando. Execute ./dev-setup.sh primeiro.${NC}"
  exit 1
fi

# Obter o ID do contêiner do Supabase
SUPABASE_CONTAINER=$(docker-compose -f docker-compose.dev.yml ps -q supabase)

if [ -z "$SUPABASE_CONTAINER" ]; then
  echo -e "${RED}Contêiner do Supabase não encontrado.${NC}"
  exit 1
fi

echo -e "${YELLOW}Atenção: Esta operação irá substituir todos os dados atuais do banco de dados.${NC}"
read -p "Deseja continuar? (s/n): " CONFIRM

if [ "$CONFIRM" != "s" ] && [ "$CONFIRM" != "S" ]; then
  echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
  exit 0
fi

# Restaurar o banco de dados
echo -e "${YELLOW}Restaurando banco de dados a partir do backup...${NC}"
cat "$1" | docker exec -i $SUPABASE_CONTAINER psql -U postgres -d postgres

echo -e "${GREEN}Backup restaurado com sucesso!${NC}"

