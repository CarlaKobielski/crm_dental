#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Inicializando banco de dados para Dental CRM ===${NC}"

# Verificar se o ambiente está rodando
if ! docker-compose -f docker-compose.dev.yml ps | grep -q "supabase"; then
  echo -e "${RED}O ambiente de desenvolvimento não está rodando. Execute ./dev-setup.sh primeiro.${NC}"
  exit 1
fi

# Executar scripts SQL no Supabase
echo -e "${YELLOW}Executando scripts SQL no Supabase...${NC}"

# Obter o ID do contêiner do Supabase
SUPABASE_CONTAINER=$(docker-compose -f docker-compose.dev.yml ps -q supabase)

if [ -z "$SUPABASE_CONTAINER" ]; then
  echo -e "${RED}Contêiner do Supabase não encontrado.${NC}"
  exit 1
fi

# Executar o script de inicialização
echo -e "${YELLOW}Executando script de inicialização...${NC}"
docker exec -i $SUPABASE_CONTAINER psql -U postgres -d postgres -f /supabase/seed/00-init.sql

# Criar dados de exemplo
echo -e "${YELLOW}Criando dados de exemplo...${NC}"
cat > /tmp/sample-data.sql << EOL
-- Inserir clínica de exemplo
INSERT INTO clinicas (id, nome, endereco, telefone, email, site, plano, status, criado_por)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Clínica Odontológica Exemplo', 'Rua Exemplo, 123', '(11) 99999-9999', 'contato@exemplo.com', 'www.exemplo.com', 'trial', 'ativo', '00000000-0000-0000-0000-000000000000')
ON CONFLICT (id) DO NOTHING;

-- Inserir usuário administrador
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES 
  ('22222222-2222-2222-2222-222222222222', 'admin@exemplo.com', '\$2a\$10\$abcdefghijklmnopqrstuvwxyz012345', now(), now(), now())
ON CONFLICT (id) DO NOTHING;

-- Inserir perfil de usuário
INSERT INTO perfis_usuario (id, email, nome, clinica_id, funcao, status, onboarding_completo)
VALUES 
  ('22222222-2222-2222-2222-222222222222', 'admin@exemplo.com', 'Administrador', '11111111-1111-1111-1111-111111111111', 'admin', 'ativo', true)
ON CONFLICT (id) DO NOTHING;

-- Inserir pacientes de exemplo
INSERT INTO pacientes (nome, email, telefone, endereco, data_nascimento, clinica_id)
VALUES 
  ('João Silva', 'joao@exemplo.com', '(11) 98765-4321', 'Rua A, 123', '1980-05-15', '11111111-1111-1111-1111-111111111111'),
  ('Maria Oliveira', 'maria@exemplo.com', '(11) 91234-5678', 'Rua B, 456', '1992-10-20', '11111111-1111-1111-1111-111111111111'),
  ('Pedro Santos', 'pedro@exemplo.com', '(11) 99876-5432', 'Rua C, 789', '1975-03-08', '11111111-1111-1111-1111-111111111111')
ON CONFLICT DO NOTHING;

-- Inserir consultas de exemplo
INSERT INTO consultas (paciente_id, data, hora, tipo, descricao, status, clinica_id)
VALUES 
  (1, CURRENT_DATE + INTERVAL '2 days', '10:00:00', 'avaliacao', 'Avaliação inicial', 'agendado', '11111111-1111-1111-1111-111111111111'),
  (2, CURRENT_DATE + INTERVAL '3 days', '14:30:00', 'limpeza', 'Limpeza semestral', 'agendado', '11111111-1111-1111-1111-111111111111'),
  (3, CURRENT_DATE + INTERVAL '1 day', '09:00:00', 'tratamento', 'Tratamento de canal', 'agendado', '11111111-1111-1111-1111-111111111111')
ON CONFLICT DO NOTHING;

-- Inserir tratamentos de exemplo
INSERT INTO tratamentos (paciente_id, nome, descricao, status, data_inicio, clinica_id)
VALUES 
  (1, 'Aparelho Ortodôntico', 'Instalação e manutenção de aparelho fixo', 'em andamento', CURRENT_DATE - INTERVAL '30 days', '11111111-1111-1111-1111-111111111111'),
  (2, 'Clareamento Dental', 'Clareamento a laser', 'concluido', CURRENT_DATE - INTERVAL '60 days', '11111111-1111-1111-1111-111111111111'),
  (3, 'Tratamento de Canal', 'Tratamento de canal no dente 26', 'em andamento', CURRENT_DATE - INTERVAL '15 days', '11111111-1111-1111-1111-111111111111')
ON CONFLICT DO NOTHING;

-- Inserir configurações de notificações
INSERT INTO configuracoes_notificacoes (clinica_id, notificacoes_email_ativo, notificacoes_sms_ativo, notificacoes_whatsapp_ativo)
VALUES 
  ('11111111-1111-1111-1111-111111111111', true, false, true)
ON CONFLICT DO NOTHING;

-- Inserir fornecedores de exemplo
INSERT INTO fornecedores (clinica_id, nome, tipo, cnpj, telefone, email)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Dental Suprimentos', 'materiais', '12.345.678/0001-90', '(11) 3333-4444', 'contato@dentalsuprimentos.com'),
  ('11111111-1111-1111-1111-111111111111', 'Laboratório Prótese', 'laboratorio', '98.765.432/0001-10', '(11) 5555-6666', 'lab@protese.com')
ON CONFLICT DO NOTHING;

-- Inserir categorias de produtos
INSERT INTO categorias_produtos (clinica_id, nome, descricao)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Materiais de Consumo', 'Materiais de uso diário'),
  ('11111111-1111-1111-1111-111111111111', 'Instrumentos', 'Instrumentos odontológicos'),
  ('11111111-1111-1111-1111-111111111111', 'Equipamentos', 'Equipamentos odontológicos')
ON CONFLICT DO NOTHING;

-- Inserir produtos de exemplo
INSERT INTO produtos (clinica_id, categoria_id, codigo, nome, descricao, unidade, quantidade_minima, quantidade_atual, valor_custo)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 1, 'MC001', 'Luvas de Procedimento', 'Caixa com 100 unidades', 'cx', 5, 10, 35.90),
  ('11111111-1111-1111-1111-111111111111', 1, 'MC002', 'Algodão', 'Pacote com 500g', 'pct', 3, 8, 15.50),
  ('11111111-1111-1111-1111-111111111111', 2, 'IN001', 'Kit Espelho Clínico', 'Kit com 5 espelhos', 'kit', 2, 4, 120.00)
ON CONFLICT DO NOTHING;

-- Inserir medicamentos de exemplo
INSERT INTO medicamentos (clinica_id, nome, principio_ativo, forma, concentracao)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Amoxicilina', 'Amoxicilina', 'Cápsula', '500mg'),
  ('11111111-1111-1111-1111-111111111111', 'Nimesulida', 'Nimesulida', 'Comprimido', '100mg'),
  ('11111111-1111-1111-1111-111111111111', 'Dipirona', 'Dipirona Sódica', 'Comprimido', '500mg')
ON CONFLICT DO NOTHING;

-- Inserir modelos de mensagens
INSERT INTO modelos_mensagens (clinica_id, nome, tipo, canal, assunto, conteudo, ativo)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Aniversário', 'aniversario', 'email', 'Feliz Aniversário!', '<div>Olá {paciente},<br><br>A equipe da {clinica} deseja a você um feliz aniversário! Que seu dia seja repleto de alegria e sorrisos.<br><br>Atenciosamente,<br>Equipe {clinica}</div>', true),
  ('11111111-1111-1111-1111-111111111111', 'Lembrete de Consulta', 'retorno', 'whatsapp', 'Lembrete de Consulta', 'Olá {paciente}, lembramos que você tem uma consulta agendada para {data} às {hora} na {clinica}. Confirme sua presença respondendo esta mensagem. Obrigado!', true)
ON CONFLICT DO NOTHING;

-- Inserir contas a receber
INSERT INTO contas_receber (clinica_id, paciente_id, tratamento_id, descricao, valor, data_vencimento, status)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 1, 1, 'Parcela 1/6 - Aparelho Ortodôntico', 250.00, CURRENT_DATE + INTERVAL '5 days', 'pendente'),
  ('11111111-1111-1111-1111-111111111111', 2, 2, 'Pagamento - Clareamento Dental', 500.00, CURRENT_DATE - INTERVAL '5 days', 'pago'),
  ('11111111-1111-1111-1111-111111111111', 3, 3, 'Parcela 1/3 - Tratamento de Canal', 300.00, CURRENT_DATE + INTERVAL '10 days', 'pendente')
ON CONFLICT DO NOTHING;
EOL

docker exec -i $SUPABASE_CONTAINER psql -U postgres -d postgres -f /tmp/sample-data.sql

echo -e "${GREEN}Banco de dados inicializado com sucesso!${NC}"
echo -e "${YELLOW}Credenciais de acesso para teste:${NC}"
echo -e "  - Email: ${GREEN}admin@exemplo.com${NC}"
echo -e "  - Senha: ${GREEN}senha123${NC} (você precisará definir esta senha no primeiro acesso)"
echo ""
echo -e "${YELLOW}Acesse o Supabase Studio para gerenciar o banco de dados:${NC} http://localhost:54322"

