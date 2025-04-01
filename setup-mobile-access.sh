#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Configurando acesso para dispositivos móveis ao Dental CRM ===${NC}"

# Obter o endereço IP da máquina local
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  IP=$(hostname -I | awk '{print $1}')
else
  # Windows ou outro
  IP=$(ipconfig | grep -i "IPv4" | head -1 | awk '{print $NF}')
fi

if [ -z "$IP" ]; then
  echo -e "${RED}Não foi possível determinar o endereço IP local.${NC}"
  echo -e "${YELLOW}Por favor, informe manualmente o endereço IP da sua máquina:${NC}"
  read -p "Endereço IP: " IP
fi

# Atualizar o arquivo docker-compose.dev.yml para expor a aplicação na rede local
cat > docker-compose.mobile.yml << EOL
version: '3.8'

services:
  # Aplicação Next.js
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "0.0.0.0:3000:3000"  # Expor para todos os IPs
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - NEXT_PUBLIC_SUPABASE_URL=http://${IP}:54321
      - NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
      - SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
      - ENCRYPTION_KEY=81e8e5b5dace1bb4d8f140d76e610196
      - SMTP_HOST=mailhog
      - SMTP_PORT=1025
      - SMTP_SECURE=false
      - SMTP_USER=
      - SMTP_PASSWORD=
      - SMTP_FROM=noreply@dentalcrm.local
    depends_on:
      - supabase
    networks:
      - dental-network
    restart: unless-stopped
    command: npm run dev -- -H 0.0.0.0

  # Supabase Local
  supabase:
    image: supabase/supabase-local:latest
    ports:
      - "0.0.0.0:54321:54321"  # Expor para todos os IPs
      - "0.0.0.0:54322:54322"  # Expor para todos os IPs
    volumes:
      - supabase-data:/var/lib/postgresql/data
      - ./supabase:/supabase
    environment:
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_DB=postgres
      - SUPABASE_URL=http://${IP}:54321
      - SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
      - SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
    networks:
      - dental-network
    restart: unless-stopped

  # Mailhog para testes de email
  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025"  # SMTP
      - "0.0.0.0:8025:8025"  # Interface web
    networks:
      - dental-network
    restart: unless-stopped

volumes:
  supabase-data:

networks:
  dental-network:
    driver: bridge
EOL

# Criar script para iniciar o ambiente para acesso móvel
cat > run-mobile.sh << EOL
#!/bin/bash

# Cores para saída
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "\${GREEN}=== Iniciando Dental CRM para acesso via dispositivos móveis ===${NC}"

# Parar o ambiente de desenvolvimento padrão se estiver rodando
if docker-compose -f docker-compose.dev.yml ps | grep -q "supabase"; then
  echo -e "\${YELLOW}Parando o ambiente de desenvolvimento padrão...${NC}"
  docker-compose -f docker-compose.dev.yml down
fi

# Iniciar o ambiente para acesso móvel
echo -e "\${YELLOW}Iniciando o ambiente para acesso móvel...${NC}"
docker-compose -f docker-compose.mobile.yml up -d

echo -e "\${GREEN}Ambiente iniciado com sucesso!${NC}"
echo -e "\${YELLOW}Acesse a aplicação em dispositivos móveis usando:${NC}"
echo -e "  - Aplicação: \${GREEN}http://${IP}:3000${NC}"
echo -e "  - Supabase Studio: \${GREEN}http://${IP}:54322${NC}"
echo -e "  - MailHog: \${GREEN}http://${IP}:8025${NC}"
echo ""
echo -e "\${YELLOW}Para visualizar logs:${NC} docker-compose -f docker-compose.mobile.yml logs -f"
echo -e "\${YELLOW}Para parar o ambiente:${NC} docker-compose -f docker-compose.mobile.yml down"
EOL

chmod +x run-mobile.sh

echo -e "${GREEN}Configuração para acesso móvel concluída!${NC}"
echo -e "${YELLOW}Para iniciar o ambiente para acesso via dispositivos móveis, execute:${NC}"
echo -e "  ${GREEN}./run-mobile.sh${NC}"
echo ""
echo -e "${YELLOW}Seu endereço IP local é:${NC} ${GREEN}${IP}${NC}"
echo -e "${YELLOW}Dispositivos na mesma rede Wi-Fi poderão acessar o Dental CRM usando este endereço.${NC}"

