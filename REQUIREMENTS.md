# Requisitos de Infraestrutura para Dental CRM

## Requisitos de Hardware
- CPU: Mínimo 2 cores, recomendado 4 cores
- RAM: Mínimo 4GB, recomendado 8GB
- Armazenamento: Mínimo 20GB SSD

## Requisitos de Software
- Docker e Docker Compose
- Ou:
  - Node.js 18.x ou superior
  - PostgreSQL 14.x ou superior (ou usar Supabase)

## Requisitos de Rede
- Conexão de internet estável
- Domínio dedicado com SSL (recomendado)
- Portas abertas: 80 (HTTP), 443 (HTTPS), 3000 (aplicação)

## Instruções de Instalação

### Usando Docker (recomendado)
1. Clone o repositório: `git clone https://github.com/seu-usuario/dental-crm.git`
2. Entre na pasta: `cd dental-crm`
3. Execute o script de instalação: `./install.sh`

### Instalação Manual
1. Clone o repositório: `git clone https://github.com/seu-usuario/dental-crm.git`
2. Entre na pasta: `cd dental-crm`
3. Instale as dependências: `npm install`
4. Crie um arquivo .env com as variáveis necessárias
5. Construa a aplicação: `npm run build`
6. Inicie o servidor: `npm start`

## Manutenção
- Atualizações: `git pull && docker-compose up -d --build`
- Backups: Acesse `/api/backup` para baixar um backup completo
- Logs: `docker-compose logs -f`

