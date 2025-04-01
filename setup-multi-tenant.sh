#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configurando ambiente multi-tenant para Dental CRM ===${NC}"

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

# Criar script SQL para configurar múltiplas clínicas
cat > /tmp/multi-tenant-setup.sql << EOL
-- Inserir clínicas adicionais
INSERT INTO clinicas (id, nome, endereco, telefone, email, site, plano, status, criado_por)
VALUES 
  ('22222222-2222-2222-2222-222222222222', 'Clínica Odontológica Sorrisos', 'Av. Principal, 456', '(11) 88888-8888', 'contato@sorrisos.com', 'www.sorrisos.com', 'professional', 'ativo', '00000000-0000-0000-0000-000000000000'),
  ('33333333-3333-3333-3333-333333333333', 'Centro Odontológico Saúde Bucal', 'Rua das Flores, 789', '(11) 77777-7777', 'contato@saudebucal.com', 'www.saudebucal.com', 'basic', 'ativo', '00000000-0000-0000-0000-000000000000')
ON CONFLICT (id) DO NOTHING;

-- Inserir usuários administradores para cada clínica
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES 
  ('33333333-3333-3333-3333-333333333333', 'admin@sorrisos.com', '\$2a\$10\$abcdefghijklmnopqrstuvwxyz012345', now(), now(), now()),
  ('44444444-4444-4444-4444-444444444444', 'admin@saudebucal.com', '\$2a\$10\$abcdefghijklmnopqrstuvwxyz012345', now(), now(), now())
ON CONFLICT (id) DO NOTHING;

-- Inserir perfis de usuário
INSERT INTO perfis_usuario (id, email, nome, clinica_id, funcao, status, onboarding_completo)
VALUES 
  ('33333333-3333-3333-3333-333333333333', 'admin@sorrisos.com', 'Administrador Sorrisos', '22222222-2222-2222-2222-222222222222', 'admin', 'ativo', true),
  ('44444444-4444-4444-4444-444444444444', 'admin@saudebucal.com', 'Administrador Saúde Bucal', '33333333-3333-3333-3333-333333333333', 'admin', 'ativo', true)
ON CONFLICT (id) DO NOTHING;

-- Inserir pacientes para cada clínica
INSERT INTO pacientes (nome, email, telefone, endereco, data_nascimento, clinica_id)
VALUES 
  -- Clínica Sorrisos
  ('Ana Pereira', 'ana@exemplo.com', '(11) 97777-8888', 'Rua D, 123', '1985-07-22', '22222222-2222-2222-2222-222222222222'),
  ('Carlos Mendes', 'carlos@exemplo.com', '(11) 96666-5555', 'Rua E, 456', '1990-12-10', '22222222-2222-2222-2222-222222222222'),
  
  -- Clínica Saúde Bucal
  ('Fernanda Lima', 'fernanda@exemplo.com', '(11) 95555-4444', 'Rua F, 789', '1978-03-15', '33333333-3333-3333-3333-333333333333'),
  ('Roberto Alves', 'roberto@exemplo.com', '(11) 94444-3333', 'Rua G, 012', '1982-09-30', '33333333-3333-3333-3333-333333333333')
ON CONFLICT DO NOTHING;

-- Inserir configurações de notificações para cada clínica
INSERT INTO configuracoes_notificacoes (clinica_id, notificacoes_email_ativo, notificacoes_sms_ativo, notificacoes_whatsapp_ativo)
VALUES 
  ('22222222-2222-2222-2222-222222222222', true, true, false),
  ('33333333-3333-3333-3333-333333333333', true, false, true)
ON CONFLICT DO NOTHING;
EOL

# Executar o script SQL
echo -e "${YELLOW}Configurando múltiplas clínicas...${NC}"
docker exec -i $SUPABASE_CONTAINER psql -U postgres -d postgres -f /tmp/multi-tenant-setup.sql

echo -e "${GREEN}Ambiente multi-tenant configurado com sucesso!${NC}"
echo -e "${YELLOW}Clínicas configuradas:${NC}"
echo -e "  1. Clínica Odontológica Exemplo"
echo -e "     - Admin: ${GREEN}admin@exemplo.com${NC}"
echo -e "  2. Clínica Odontológica Sorrisos"
echo -e "     - Admin: ${GREEN}admin@sorrisos.com${NC}"
echo -e "  3. Centro Odontológico Saúde Bucal"
echo -e "     - Admin: ${GREEN}admin@saudebucal.com${NC}"
echo ""
echo -e "${YELLOW}Você pode acessar o sistema com qualquer um desses usuários para testar o ambiente multi-tenant.${NC}"

