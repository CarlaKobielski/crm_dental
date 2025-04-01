#!/bin/bash

# Verificar se o Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker não encontrado. Instalando..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

# Verificar se o Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose não encontrado. Instalando..."
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.18.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Configurar variáveis de ambiente
echo "Configurando variáveis de ambiente..."
cp .env.example .env

read -p "URL do Supabase: " SUPABASE_URL
read -p "Chave anônima do Supabase: " SUPABASE_ANON_KEY
read -p "Chave de serviço do Supabase: " SUPABASE_SERVICE_ROLE_KEY
read -p "Chave de criptografia (32 caracteres): " ENCRYPTION_KEY

sed -i "s|NEXT_PUBLIC_SUPABASE_URL=.*|NEXT_PUBLIC_SUPABASE_URL=$SUPABASE_URL|g" .env
sed -i "s|NEXT_PUBLIC_SUPABASE_ANON_KEY=.*|NEXT_PUBLIC_SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY|g" .env
sed -i "s|SUPABASE_SERVICE_ROLE_KEY=.*|SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY|g" .env
sed -i "s|ENCRYPTION_KEY=.*|ENCRYPTION_KEY=$ENCRYPTION_KEY|g" .env

# Iniciar os contêineres
echo "Iniciando o Dental CRM..."
docker-compose up -d

echo "Instalação concluída! Acesse http://localhost:3000"

