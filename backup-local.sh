#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Criando backup do ambiente local do Dental CRM ===${NC}"

# Verificar se o ambiente está rodando
if ! docker-compose -f docker-compose.dev.yml ps | grep -q "supabase"; then
  echo -e "${RED}O ambiente de desenvolvimento não está rodando. Execute ./dev-setup.sh primeiro.${NC}"
  exit 1
fi

# Criar diretório para backups
mkdir -p ./backups

# Data atual para nome do arquivo
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="./backups/dental_crm_backup_$DATE.sql"

# Obter o ID do contêiner do Supabase
SUPABASE_CONTAINER=$(docker-compose -f docker-compose.dev.yml ps -q supabase)

if [ -z "$SUPABASE_CONTAINER" ]; then
  echo -e "${RED}Contêiner do Supabase não encontrado.${NC}"
  exit 1
fi

# Criar backup do banco de dados
echo -e "${YELLOW}Criando backup do banco de dados...${NC}"
docker exec -i $SUPABASE_CONTAINER pg_dump -U postgres -d postgres > $BACKUP_FILE

echo -e "${GREEN}Backup criado com sucesso: $BACKUP_FILE${NC}"
echo -e "${YELLOW}Para restaurar este backup, use:${NC} ./restore-local.sh $BACKUP_FILE"

