#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configurando ambiente de desenvolvimento para Dental CRM ===${NC}"

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo -e "${RED}Docker não encontrado. Por favor, instale o Docker antes de continuar.${NC}"
  echo "Visite: https://docs.docker.com/get-docker/"
  exit 1
fi

# Verificar se o Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
  echo -e "${RED}Docker Compose não encontrado. Por favor, instale o Docker Compose antes de continuar.${NC}"
  echo "Visite: https://docs.docker.com/compose/install/"
  exit 1
fi

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
  echo -e "${YELLOW}Criando arquivo .env com valores padrão para desenvolvimento...${NC}"
  cat > .env << EOL
# Supabase
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# Criptografia
ENCRYPTION_KEY=81e8e5b5dace1bb4d8f140d76e610196

# Email (MailHog para desenvolvimento)
SMTP_HOST=mailhog
SMTP_PORT=1025
SMTP_SECURE=false
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM=noreply@dentalcrm.local

# Twilio (opcional para desenvolvimento)
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=

# WhatsApp (opcional para desenvolvimento)
WHATSAPP_API_KEY=
WHATSAPP_PHONE_NUMBER_ID=

# Stripe (opcional para desenvolvimento)
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
EOL
  echo -e "${GREEN}Arquivo .env criado com sucesso.${NC}"
else
  echo -e "${YELLOW}Arquivo .env já existe. Mantendo configurações atuais.${NC}"
fi

# Criar diretório para scripts SQL do Supabase se não existir
if [ ! -d "supabase/seed" ]; then
  echo -e "${YELLOW}Criando diretório para scripts de inicialização do Supabase...${NC}"
  mkdir -p supabase/seed
  
  # Criar script de inicialização combinado
  cat > supabase/seed/00-init.sql << EOL
-- Combinar todos os scripts SQL em um único arquivo de inicialização
$(cat supabase/schema.sql 2>/dev/null || echo "-- schema.sql não encontrado")

$(cat supabase/policies.sql 2>/dev/null || echo "-- policies.sql não encontrado")

$(cat supabase/create-tables.sql 2>/dev/null || echo "-- create-tables.sql não encontrado")

$(cat supabase/storage-policies.sql 2>/dev/null || echo "-- storage-policies.sql não encontrado")

$(cat supabase/configuracoes-tables.sql 2>/dev/null || echo "-- configuracoes-tables.sql não encontrado")

$(cat supabase/multi-tenant-schema.sql 2>/dev/null || echo "-- multi-tenant-schema.sql não encontrado")

$(cat supabase/auth-tables.sql 2>/dev/null || echo "-- auth-tables.sql não encontrado")

$(cat supabase/onboarding-schema.sql 2>/dev/null || echo "-- onboarding-schema.sql não encontrado")

$(cat supabase/storage-rls-policies.sql 2>/dev/null || echo "-- storage-rls-policies.sql não encontrado")

$(cat supabase/enable-storage.sql 2>/dev/null || echo "-- enable-storage.sql não encontrado")

$(cat supabase/notifications-schema.sql 2>/dev/null || echo "-- notifications-schema.sql não encontrado")

$(cat supabase/notification-config-schema.sql 2>/dev/null || echo "-- notification-config-schema.sql não encontrado")

$(cat supabase/financeiro-avancado-schema.sql 2>/dev/null || echo "-- financeiro-avancado-schema.sql não encontrado")

$(cat supabase/estoque-schema.sql 2>/dev/null || echo "-- estoque-schema.sql não encontrado")

$(cat supabase/prescricoes-schema.sql 2>/dev/null || echo "-- prescricoes-schema.sql não encontrado")

$(cat supabase/mensagens-automaticas-schema.sql 2>/dev/null || echo "-- mensagens-automaticas-schema.sql não encontrado")

-- Criar função execute_sql
CREATE OR REPLACE FUNCTION execute_sql(sql_query text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS \$\$
BEGIN
  EXECUTE sql_query;
  RETURN json_build_object('success', true);
EXCEPTION WHEN OTHERS THEN
  RETURN json_build_object('success', false, 'error', SQLERRM);
END;
\$\$;
EOL
  echo -e "${GREEN}Script de inicialização do Supabase criado com sucesso.${NC}"
else
  echo -e "${YELLOW}Diretório supabase/seed já existe. Mantendo scripts atuais.${NC}"
fi

# Iniciar os contêineres
echo -e "${GREEN}Iniciando os contêineres Docker...${NC}"
docker-compose -f docker-compose.dev.yml up -d

# Aguardar o Supabase iniciar
echo -e "${YELLOW}Aguardando o Supabase iniciar (isso pode levar alguns minutos)...${NC}"
sleep 30

echo -e "${GREEN}Ambiente de desenvolvimento configurado com sucesso!${NC}"
echo -e "${YELLOW}Acesse:${NC}"
echo -e "  - Aplicação: ${GREEN}http://localhost:3000${NC}"
echo -e "  - Supabase Studio: ${GREEN}http://localhost:54322${NC}"
echo -e "  - MailHog (para testar emails): ${GREEN}http://localhost:8025${NC}"
echo ""
echo -e "${YELLOW}Para parar o ambiente:${NC} docker-compose -f docker-compose.dev.yml down"
echo -e "${YELLOW}Para reiniciar o ambiente:${NC} docker-compose -f docker-compose.dev.yml restart"
echo -e "${YELLOW}Para visualizar logs:${NC} docker-compose -f docker-compose.dev.yml logs -f"

