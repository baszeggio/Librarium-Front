# 🗡️ Librarium Backend - API RPG de Hábitos

[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-4.18+-blue.svg)](https://expressjs.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.5+-green.svg)](https://mongodb.com/)
[![JWT](https://img.shields.io/badge/JWT-Auth-orange.svg)](https://jwt.io/)
[![Railway](https://img.shields.io/badge/Deployed%20on-Railway-purple.svg)](https://railway.app/)

> **Backend do Librarium** - Um gerenciador de hábitos gamificado com temática dark fantasy inspirado em Hollow Knight e Devil May Cry. Transforme sua jornada de desenvolvimento pessoal em uma aventura épica!

## **Visão Geral**

O Librarium é uma API RESTful completa que gamifica o processo de construção de hábitos através de um sistema RPG imersivo. Com avatares evolutivos, sistema de conquistas, multiplayer e integrações avançadas, transforma tarefas mundanas em missões épicas.

## **Funcionalidades Principais**

### 🎮 **Sistema de Gamificação Avançado**
- **Sistema de XP e Níveis** - Progressão baseada em conquistas
- **Avatar Evolutivo** - 6 níveis de evolução com equipamentos únicos
- **Sistema de Títulos** - Títulos épicos desbloqueados por conquistas
- **Recompensas Dinâmicas** - XP baseado na dificuldade dos hábitos
- **Efeitos Visuais** - Auras, partículas e temas dinâmicos

### 🏆 **Sistema de Conquistas Inteligente**
- **16 Conquistas** com verificação automática
- **Sistema de Raridade** - Comum, Raro, Épico, Lendário
- **Verificações Inteligentes** - Sequências, eficiência, consistência
- **Conquistas Personalizadas** - Criadas pelos próprios usuários
- **Recompensas de XP** - Baseadas na dificuldade e raridade

### ⚔️ **Sistema Multiplayer**
- **Batalhas PvP** - Desafie outros jogadores
- **Sistema de Desafios** - Missões colaborativas
- **Ranking Global** - Competição entre usuários
- **Chat em Tempo Real** - Comunicação entre jogadores
- **Sistema de Amizades** - Conecte-se com outros jogadores

### 🔗 **Integrações Externas**
- **Google Calendar** - Sincronização de eventos
- **Google Fit** - Dados de saúde e atividade física
- **OAuth2** - Autenticação social segura
- **API de Terceiros** - Integração com serviços externos

### 📊 **Sistema de Dados Avançado**
- **Exportação Multi-formato** - JSON, XML, ZIP
- **Backup Automático** - Proteção de dados
- **Importação Inteligente** - Validação e mesclagem
- **Estatísticas Detalhadas** - Análises profundas
- **Sincronização Offline** - Funciona sem internet

## **Arquitetura Técnica**

### **Stack Principal**
- **Node.js 18+** - Runtime JavaScript
- **Express.js 4.18+** - Framework web
- **MongoDB 7.5+** - Banco de dados NoSQL
- **Mongoose 7.5+** - ODM para MongoDB
- **JWT** - Autenticação baseada em tokens

### **Segurança e Performance**
- **bcrypt** - Criptografia de senhas
- **Helmet** - Headers de segurança HTTP
- **CORS** - Configuração de origem cruzada
- **Rate Limiting** - Proteção contra abuso
- **Winston** - Sistema de logging estruturado
- **Compression** - Compressão gzip

### **Validação e Qualidade**
- **express-validator** - Validação de entrada
- **Morgan** - Logging de requisições HTTP
- **Error Handling** - Tratamento global de erros
- **Input Sanitization** - Sanitização de dados

## **Instalação e Configuração**

### **Pré-requisitos**
- Node.js 18+ 
- MongoDB 7.5+ (local ou Atlas)
- npm 8+ ou yarn 1.22+

### **Instalação Local**

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/librarium.git
cd librarium/backend
```

2. **Instale as dependências**
```bash
npm install
```

3. **Configure as variáveis de ambiente**
```bash
cp env.example .env
```

4. **Configure o arquivo `.env`**
```env
# ===== CONFIGURAÇÕES BÁSICAS =====
NODE_ENV=development
PORT=3000

# ===== BANCO DE DADOS =====
MONGODB_URI=mongodb://localhost:27017/librarium

# ===== AUTENTICAÇÃO JWT =====
JWT_SECRET=sua_chave_secreta_jwt_super_forte_aqui
JWT_EXPIRES_IN=7d

# ===== FRONTEND =====
FRONTEND_URL=http://localhost:3001

# ===== GOOGLE APIs =====
GOOGLE_CLIENT_ID=seu_google_client_id_aqui
GOOGLE_REDIRECT_URI=http://localhost:3000/api/integracao/google/oauth/callback

# ===== CORS =====
CORS_ORIGIN=http://localhost:3001,http://localhost:3000
CORS_CREDENTIALS=true

# ===== RATE LIMITING =====
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# ===== LOGS =====
LOG_LEVEL=info
LOG_FILE=logs/librarium.log
```

5. **Inicie o servidor**
```bash
# Desenvolvimento (com nodemon)
npm run dev

# Produção
npm start
```

### **Deploy no Railway**

1. **Conecte seu repositório** no Railway
2. **Adicione o serviço MongoDB** do Railway
3. **Configure as variáveis de ambiente**:
```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb://mongo:27017/librarium
JWT_SECRET=sua_chave_secreta_jwt_super_forte_aqui
CORS_ORIGIN=*
CORS_CREDENTIALS=true
LOG_LEVEL=warn
```

4. **Deploy automático** acontecerá

## **Documentação da API**

### **Base URL**
- **Local:** `http://localhost:3000/api`
- **Railway:** `https://seu-app.railway.app/api`

### **Health Check**
```bash
GET /api/saude
```

### **🔐 Autenticação (`/api/auth`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/registrar` | Registrar novo usuário | ❌ |
| POST | `/login` | Fazer login | ❌ |
| GET | `/verificar` | Verificar token | ✅ |
| GET | `/perfil` | Obter perfil do usuário | ✅ |
| PUT | `/perfil` | Atualizar perfil | ✅ |

**Exemplo de Registro:**
```bash
curl -X POST https://seu-app.railway.app/api/auth/registrar \
  -H "Content-Type: application/json" \
  -d '{
    "nomeUsuario": "guerreiro123",
    "email": "guerreiro@librarium.com",
    "senha": "minhasenha123"
  }'
```

### **⚔️ Hábitos (`/api/habitos`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar hábitos do usuário | ✅ |
| POST | `/` | Criar novo hábito | ✅ |
| GET | `/:id` | Obter hábito específico | ✅ |
| PUT | `/:id` | Atualizar hábito | ✅ |
| DELETE | `/:id` | Deletar hábito | ✅ |
| POST | `/:id/concluir` | Marcar hábito como concluído | ✅ |
| GET | `/:id/progresso` | Obter progresso do hábito | ✅ |

**Exemplo de Criação de Hábito:**
```bash
curl -X POST https://seu-app.railway.app/api/habitos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{
    "titulo": "Exercitar-se diariamente",
    "descricao": "30 minutos de exercício físico",
    "frequencia": "diario",
    "categoria": "saude",
    "dificuldade": "medio",
    "icone": "espada",
    "cor": "#FF6B6B"
  }'
```

### **👤 Usuários (`/api/usuarios`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/dashboard` | Dashboard completo do usuário | ✅ |
| GET | `/estatisticas` | Estatísticas detalhadas | ✅ |
| GET | `/ranking` | Ranking global de usuários | ✅ |
| GET | `/conquistas` | Conquistas do usuário | ✅ |
| PUT | `/preferencias` | Atualizar preferências | ✅ |

### **📊 Estatísticas (`/api/estatisticas`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/sistema` | Estatísticas gerais do sistema | ✅ |
| GET | `/grafico-semanal` | Gráfico dos últimos 7 dias | ✅ |
| GET | `/categorias` | Estatísticas por categoria | ✅ |
| GET | `/heatmap` | Heatmap de atividades | ✅ |
| GET | `/comparativo-mensal` | Comparativo mensal | ✅ |

### **🏆 Conquistas (`/api/conquistas`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar conquistas do usuário | ✅ |
| POST | `/verificar` | Verificar conquistas automaticamente | ✅ |
| GET | `/tipos` | Listar tipos de conquistas disponíveis | ✅ |
| POST | `/criar` | Criar conquista personalizada | ✅ |

### **🎭 Avatar (`/api/avatar`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Obter dados do avatar | ✅ |
| POST | `/evoluir` | Forçar evolução do avatar | ✅ |
| GET | `/equipamentos` | Listar equipamentos disponíveis | ✅ |
| PUT | `/equipar` | Equipar item no avatar | ✅ |
| GET | `/historico` | Histórico de evoluções | ✅ |

### **⚔️ Multiplayer (`/api/multiplayer`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/batalha` | Listar batalhas disponíveis | ✅ |
| POST | `/batalha` | Criar nova batalha | ✅ |
| GET | `/desafio` | Listar desafios | ✅ |
| POST | `/desafio` | Criar novo desafio | ✅ |
| GET | `/ranking` | Ranking multiplayer | ✅ |

### **🔗 Integrações (`/api/integracao`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/status` | Status das integrações | ✅ |
| POST | `/google/oauth` | Iniciar OAuth do Google | ✅ |
| GET | `/google/oauth/callback` | Callback do OAuth | ❌ |
| POST | `/google/calendar/sync` | Sincronizar Google Calendar | ✅ |
| POST | `/google/fit/sync` | Sincronizar Google Fit | ✅ |

### **📦 Dados (`/api/dados`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/exportar/json` | Exportar dados em JSON | ✅ |
| GET | `/exportar/xml` | Exportar dados em XML | ✅ |
| GET | `/exportar/zip` | Exportar dados em ZIP | ✅ |
| POST | `/importar` | Importar dados | ✅ |
| GET | `/estatisticas` | Estatísticas de exportação | ✅ |

### **🏪 Loja (`/api/loja`)**

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar itens da loja | ✅ |
| POST | `/comprar` | Comprar item | ✅ |
| GET | `/inventario` | Inventário do usuário | ✅ |

## **Modelos de Dados**

### **Usuário**
```javascript
{
  _id: ObjectId,
  nomeUsuario: String,
  email: String,
  senha: String, // criptografada com bcrypt
  experiencia: Number,
  nivel: Number,
  titulo: String,
  avatar: {
    nivel: Number,
    equipamentos: {
      arma: String,
      armadura: String,
      acessorio: String
    },
    efeitos: [String],
    tema: String
  },
  sequencia: {
    atual: Number,
    maiorSequencia: Number
  },
  conquistas: [ObjectId],
  preferencias: {
    notificacoes: Boolean,
    tema: String,
    idioma: String
  },
  dadosSaude: [Object],
  createdAt: Date,
  updatedAt: Date
}
```

### **Hábito**
```javascript
{
  _id: ObjectId,
  idUsuario: ObjectId,
  titulo: String,
  descricao: String,
  frequencia: String, // 'diario', 'semanal', 'mensal'
  categoria: String, // 'saude', 'estudo', 'trabalho', etc
  dificuldade: String, // 'facil', 'medio', 'dificil', 'lendario'
  recompensaExperiencia: Number,
  icone: String,
  cor: String,
  ativo: Boolean,
  sequencia: {
    atual: Number,
    maiorSequencia: Number
  },
  estatisticas: {
    totalConclusoes: Number,
    totalPerdidos: Number,
    taxaConclusao: Number
  },
  createdAt: Date,
  updatedAt: Date
}
```

### **Progresso**
```javascript
{
  _id: ObjectId,
  idHabito: ObjectId,
  idUsuario: ObjectId,
  data: Date,
  status: String, // 'concluido', 'perdido', 'parcial'
  observacoes: String,
  experienciaGanha: Number,
  dificuldade: String,
  createdAt: Date
}
```

### **Conquista**
```javascript
{
  _id: ObjectId,
  idUsuario: ObjectId,
  tipo: String,
  titulo: String,
  descricao: String,
  raridade: String, // 'comum', 'raro', 'epico', 'lendario'
  recompensaXP: Number,
  criterios: Object,
  desbloqueada: Boolean,
  dataDesbloqueio: Date,
  createdAt: Date
}
```

## **Sistema de Gamificação**

### **Níveis e Títulos**
- **Nível 1-10**: Aspirante (100 XP por nível)
- **Nível 11-20**: Caçador (200 XP por nível)
- **Nível 21-30**: Guardião do Librarium (300 XP por nível)
- **Nível 31-40**: Conjurador Supremo (400 XP por nível)
- **Nível 41+**: Lenda Viva (500 XP por nível)

### **Recompensas por Dificuldade**
- **Fácil**: 10 XP
- **Médio**: 20 XP
- **Difícil**: 35 XP
- **Lendário**: 50 XP

### **Sistema de Conquistas**
- **16 Conquistas** implementadas
- **Verificação Automática** a cada 5 minutos
- **Sistema de Raridade** com recompensas diferenciadas
- **Conquistas Personalizadas** criadas pelos usuários

### **Avatar Evolutivo**
- **6 Níveis de Evolução** baseados em XP e conquistas
- **Sistema de Equipamentos** com desbloqueios automáticos
- **Efeitos Visuais** dinâmicos
- **Personalização Avançada** de aparência

## **Segurança**

### **Autenticação e Autorização**
- **JWT (JSON Web Tokens)** para autenticação
- **bcrypt** para hash seguro de senhas
- **Middleware de autenticação** em rotas protegidas
- **Verificação de token** em todas as requisições

### **Proteção da API**
- **Helmet** para headers de segurança HTTP
- **CORS** configurado para origens específicas
- **Rate Limiting** para proteção contra abuso
- **Validação de entrada** com express-validator
- **Sanitização de dados** para prevenir ataques

### **Logs e Monitoramento**
- **Winston** para logging estruturado
- **Morgan** para logs de requisições HTTP
- **Tratamento global de erros**
- **Métricas de performance**

## **Configuração Avançada**

### **Variáveis de Ambiente Completas**

```env
# ===== CONFIGURAÇÕES BÁSICAS =====
NODE_ENV=production
PORT=3000

# ===== BANCO DE DADOS =====
MONGODB_URI=mongodb://mongo:27017/librarium

# ===== AUTENTICAÇÃO JWT =====
JWT_SECRET=sua_chave_secreta_jwt_super_forte_aqui
JWT_EXPIRES_IN=7d

# ===== FRONTEND =====
FRONTEND_URL=https://seu-frontend.vercel.app

# ===== GOOGLE APIs =====
GOOGLE_CLIENT_ID=seu_google_client_id_aqui
GOOGLE_REDIRECT_URI=https://seu-app.railway.app/api/integracao/google/oauth/callback

# ===== CORS =====
CORS_ORIGIN=https://seu-frontend.vercel.app
CORS_CREDENTIALS=true

# ===== RATE LIMITING =====
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=50

# ===== LOGS =====
LOG_LEVEL=warn
LOG_FILE=logs/librarium.log

# ===== SEGURANÇA =====
BCRYPT_SALT_ROUNDS=12
SESSION_SECRET=sua_session_secret_aqui

# ===== ARQUIVOS =====
MAX_FILE_SIZE=10485760
UPLOAD_PATH=uploads/

# ===== Sistema de Avatar Evolutivo =====
AVATAR_EVOLUCAO_AUTOMATICA=true
AVATAR_VERIFICACAO_INTERVALO=300000
AVATAR_MAX_NIVEL=5
AVATAR_EFEITOS_ATIVOS=true

# ===== Sistema de Conquistas Avançado =====
CONQUISTAS_VERIFICACAO_AUTOMATICA=true
CONQUISTAS_VERIFICACAO_INTERVALO=300000
CONQUISTAS_LIMPEZA_AUTOMATICA=true
CONQUISTAS_LIMPEZA_INTERVALO=86400000
CONQUISTAS_LIMPEZA_DIAS=90

# ===== Sistema de Exportação de Dados =====
EXPORTACAO_FORMATOS_DISPONIVEIS=json,xml,zip
EXPORTACAO_TAMANHO_MAXIMO=10485760
EXPORTACAO_BACKUP_AUTOMATICO=true
EXPORTACAO_DIRETORIO_TEMP=./temp
EXPORTACAO_DIRETORIO_BACKUP=./backups
```

## **Testando a API**

### **Script de Teste Automatizado**
```bash
# Execute o script de teste completo
node test-server.js
```

### **Testes Manuais**

**1. Health Check**
```bash
curl https://seu-app.railway.app/api/saude
```

**2. Registrar Usuário**
```bash
curl -X POST https://seu-app.railway.app/api/auth/registrar \
  -H "Content-Type: application/json" \
  -d '{
    "nomeUsuario": "guerreiro123",
    "email": "guerreiro@librarium.com",
    "senha": "minhasenha123"
  }'
```

**3. Fazer Login**
```bash
curl -X POST https://seu-app.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "guerreiro@librarium.com",
    "senha": "minhasenha123"
  }'
```

**4. Criar Hábito**
```bash
curl -X POST https://seu-app.railway.app/api/habitos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{
    "titulo": "Exercitar-se diariamente",
    "descricao": "30 minutos de exercício físico",
    "frequencia": "diario",
    "categoria": "saude",
    "dificuldade": "medio",
    "icone": "espada",
    "cor": "#FF6B6B"
  }'
```

## **Monitoramento e Logs**

### **Logs Estruturados**
- **Desenvolvimento**: Logs detalhados no console
- **Produção**: Logs em arquivo com rotação
- **Níveis**: error, warn, info, debug
- **Formato**: JSON estruturado

### **Métricas Disponíveis**
- **Tempo de resposta** das requisições
- **Taxa de erro** por endpoint
- **Uso de memória** do servidor
- **Conexões ativas** do MongoDB
- **Rate limiting** por IP

### **Health Check**
```bash
GET /api/saude
```

**Resposta:**
```json
{
  "sucesso": true,
  "mensagem": "🗡️ Librarium está funcionando perfeitamente!",
  "timestamp": "2025-01-10T23:46:44.363Z",
  "versao": "1.0.0",
  "ambiente": "production",
  "uptime": 285.73,
  "funcionalidades": {
    "autenticacao": true,
    "habitos": true,
    "conquistas": true,
    "avatarEvolutivo": true,
    "multiplayer": true,
    "integracoes": true,
    "exportacao": true,
    "sistemaConquistas": true
  }
}
```

## **Deploy e Produção**

### **Railway (Recomendado)**
1. Conecte seu repositório GitHub
2. Adicione o serviço MongoDB
3. Configure as variáveis de ambiente
4. Deploy automático

### **Outras Plataformas**
- **Heroku** - Compatível
- **Vercel** - Para funções serverless
- **DigitalOcean** - VPS personalizado
- **AWS** - EC2 ou Lambda

### **Docker (Opcional)**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## **Contribuição**

### **Como Contribuir**
1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. **Commit** suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. **Push** para a branch (`git push origin feature/nova-feature`)
5. **Abra** um Pull Request

### **Padrões de Código**
- **ESLint** para linting
- **Prettier** para formatação
- **Conventional Commits** para mensagens
- **Testes** para novas funcionalidades

## 📄 **Licença**

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🙏 **Agradecimentos**

- **Hollow Knight** - Inspiração para a temática dark fantasy
- **Devil May Cry** - Inspiração para o sistema de combate
- **Express.js** - Framework web robusto
- **MongoDB** - Banco de dados flexível
- **Railway** - Plataforma de deploy confiável

---

## 🎮 **Que a Caçada Comece!**

**Bem-vindo ao Librarium!** ⚔️✨

Transforme sua jornada de desenvolvimento pessoal em uma aventura épica. Cada hábito é uma missão, cada conquista é uma vitória, e cada dia é uma nova oportunidade de evoluir.

**O Librarium aguarda seus heróis...** 🗡️👑

---

**Desenvolvido com ódio, Cursor IDE e muita cafeína por Pedro Zucchi**

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black.svg)](https://github.com/pedro-zucchi90)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue.svg)](https://www.linkedin.com/in/pedro-zucchi-52b50132b/)
