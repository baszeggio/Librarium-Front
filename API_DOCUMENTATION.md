# 🗡️ Librarium API - Documentação Completa

## 📋 Visão Geral

A API do Librarium é um sistema completo de gerenciamento de hábitos gamificado com temática dark fantasy. Esta documentação cobre todas as funcionalidades implementadas.

## 🚀 Funcionalidades Implementadas

### ✅ **Sistema de Autenticação JWT**
- Registro de usuários
- Login e logout
- Validação de tokens
- Gerenciamento de perfis

### ✅ **CRUD de Hábitos**
- Criação, leitura, atualização e exclusão de hábitos
- Marcação de conclusão
- Histórico de progresso
- Categorização e dificuldade

### ✅ **Sistema de Conquistas Automáticas**
- Verificação automática de condições
- Desbloqueio baseado em progresso
- Recompensas de XP
- Conquistas personalizadas


### ✅ **Funcionalidades Multiplayer**
- Sistema de batalhas entre usuários
- Desafios personalizados
- Sistema de mensagens
- Ranking global

### ✅ **Integrações Externas**
- Google Calendar
- Google Fit
- Sincronização de dados de saúde

### ✅ **Exportação e Importação**
- Múltiplos formatos (JSON, XML, ZIP)
- Backup automático
- Validação de dados
- Sincronização

## 🔗 Endpoints da API

### Base URL
```
http://localhost:3000/api
```

### 🔐 **Autenticação** (`/auth`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/registrar` | Registrar novo usuário | ❌ |
| POST | `/login` | Fazer login | ❌ |
| GET | `/perfil` | Obter perfil do usuário | ✅ |
| PUT | `/perfil` | Atualizar perfil | ✅ |
| GET | `/verificar` | Verificar token | ✅ |

### ⚔️ **Hábitos** (`/habitos`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar hábitos do usuário | ✅ |
| POST | `/` | Criar novo hábito | ✅ |
| GET | `/:id` | Obter hábito específico | ✅ |
| PUT | `/:id` | Atualizar hábito | ✅ |
| DELETE | `/:id` | Deletar hábito | ✅ |
| POST | `/:id/concluir` | Marcar hábito como concluído | ✅ |
| GET | `/:id/progresso` | Obter progresso do hábito | ✅ |

### 🏆 **Conquistas** (`/conquistas`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar conquistas do usuário | ✅ |
| POST | `/verificar` | Verificar conquistas automaticamente | ✅ |
| GET | `/estatisticas` | Estatísticas de conquistas | ✅ |
| POST | `/personalizada` | Criar conquista personalizada | ✅ |
| PUT | `/:id/ler` | Marcar conquista como lida | ✅ |
| GET | `/categoria/:categoria` | Conquistas por categoria | ✅ |
| GET | `/raridade/:raridade` | Conquistas por raridade | ✅ |
| GET | `/progresso` | Progresso das conquistas | ✅ |
| GET | `/proximas` | Próximas conquistas disponíveis | ✅ |

### 🔔 **Notificações** (`/notificacoes`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar notificações | ✅ |
| GET | `/nao-lidas` | Notificações não lidas | ✅ |
| PUT | `/:id/ler` | Marcar como lida | ✅ |
| PUT | `/marcar-todas-lidas` | Marcar todas como lidas | ✅ |
| DELETE | `/:id` | Deletar notificação | ✅ |
| DELETE | `/limpar-antigas` | Limpar notificações antigas | ✅ |
| GET | `/estatisticas` | Estatísticas de notificações | ✅ |

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/agendada` | Criar notificação agendada | ✅ |
| GET | `/agendadas` | Listar notificações agendadas | ✅ |
| PUT | `/:id/cancelar` | Cancelar notificação agendada | ✅ |

### 📊 **Estatísticas** (`/estatisticas`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/sistema` | Estatísticas gerais do sistema | ✅ |
| GET | `/grafico-semanal` | Gráfico dos últimos 7 dias | ✅ |
| GET | `/categorias` | Estatísticas por categoria | ✅ |
| GET | `/heatmap` | Heatmap de atividades | ✅ |
| GET | `/comparativo-mensal` | Comparativo mensal | ✅ |

### 👤 **Usuários** (`/usuarios`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/dashboard` | Dashboard do usuário | ✅ |
| GET | `/estatisticas` | Estatísticas detalhadas | ✅ |
| GET | `/ranking` | Ranking de usuários | ✅ |
| GET | `/conquistas` | Conquistas do usuário | ✅ |
| PUT | `/preferencias` | Atualizar preferências | ✅ |
| PUT | `/avatar/evoluir` | Evoluir avatar | ✅ |
| PUT | `/avatar/customizar` | Customizar avatar | ✅ |
| GET | `/exportar` | Exportar dados (JSON) | ✅ |
| POST | `/importar` | Importar dados | ✅ |

### ⚔️ **Multiplayer** (`/multiplayer`)

#### **Batalhas**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/batalha/criar` | Criar nova batalha | ✅ |
| POST | `/batalha/:id/aceitar` | Aceitar batalha | ✅ |
| POST | `/batalha/:id/finalizar` | Finalizar batalha | ✅ |
| GET | `/batalha` | Listar batalhas | ✅ |

#### **Desafios**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/desafio` | Criar novo desafio | ✅ |
| POST | `/desafio/:id/responder` | Responder desafio | ✅ |
| GET | `/desafio` | Listar desafios | ✅ |

#### **Mensagens**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/mensagem` | Enviar mensagem | ✅ |
| GET | `/mensagem/conversa/:usuarioId` | Obter conversa | ✅ |
| PUT | `/mensagem/:id/ler` | Marcar como lida | ✅ |
| GET | `/mensagem/nao-lidas` | Mensagens não lidas | ✅ |
| GET | `/mensagem/estatisticas` | Estatísticas de mensagens | ✅ |

#### **Ranking e Estatísticas**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/ranking` | Ranking global | ✅ |
| GET | `/estatisticas` | Estatísticas multiplayer | ✅ |

### 🔗 **Integrações** (`/integracao`)

#### **Google Calendar**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/google/oauth` | Iniciar OAuth2 | ✅ |
| GET | `/google/oauth/callback` | Callback OAuth2 | ✅ |
| POST | `/google-calendar/sync` | Sincronizar hábitos | ✅ |
| GET | `/google-calendar/eventos` | Obter eventos | ✅ |
| DELETE | `/google/desconectar` | Desconectar integração | ✅ |

#### **Google Fit / Saúde**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| POST | `/health/sync` | Sincronizar dados de saúde | ✅ |
| GET | `/health/dados` | Obter dados de saúde | ✅ |

#### **Status e Configuração**
| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/status` | Status das integrações | ✅ |

### 📦 **Exportação/Importação** (`/dados`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/exportar/json` | Exportar dados em JSON | ✅ |
| GET | `/exportar/xml` | Exportar dados em XML | ✅ |
| GET | `/exportar/zip` | Exportar dados em ZIP | ✅ |
| POST | `/importar` | Importar dados | ✅ |
| POST | `/backup` | Criar backup manual | ✅ |
| GET | `/backups` | Listar backups | ✅ |
| GET | `/estatisticas` | Estatísticas de exportação | ✅ |
| POST | `/validar` | Validar dados | ✅ |
| DELETE | `/limpar` | Limpar dados antigos | ✅ |
| POST | `/sincronizar` | Sincronizar dados | ✅ |
| GET | `/configuracoes` | Obter configurações | ✅ |
| PUT | `/configuracoes` | Atualizar configurações | ✅ |

### 🏪 **Loja** (`/loja`)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| GET | `/` | Listar itens disponíveis | ✅ |
| POST | `/comprar` | Comprar item | ✅ |

## 🔑 **Autenticação**

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Exemplo de Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@exemplo.com",
    "senha": "123456"
  }'
```

### Exemplo de Uso com Token
```bash
curl -X GET http://localhost:3000/api/habitos \
  -H "Authorization: Bearer <seu_token_aqui>"
```

## 📊 **Modelos de Dados**

### Usuário
```javascript
{
  _id: ObjectId,
  nomeUsuario: String,
  email: String,
  senha: String (criptografada),
  experiencia: Number,
  nivel: Number,
  titulo: String,
  avatar: String,
  personalizacaoAvatar: {
    arma: String,
    armadura: String,
    acessorio: String
  },
  sequencia: {
    atual: Number,
    maiorSequencia: Number
  },
  preferencias: {
    notificacoes: Object,
    tema: String,
    idioma: String
  },
  subscriptionPush: Object,
  integracaoGoogle: Object,
  dadosSaude: Array
}
```

### Hábito
```javascript
{
  _id: ObjectId,
  idUsuario: ObjectId,
  titulo: String,
  descricao: String,
  frequencia: String,
  categoria: String,
  dificuldade: String,
  recompensaExperiencia: Number,
  icone: String,
  cor: String,
  ativo: Boolean,
  diasAlvo: Array,
  horarioLembrete: String,
  sequencia: {
    atual: Number,
    maiorSequencia: Number
  },
  estatisticas: {
    totalConclusoes: Number,
    totalPerdidos: Number,
    taxaConclusao: Number
  }
}
```

### Conquista
```javascript
{
  _id: ObjectId,
  idUsuario: ObjectId,
  titulo: String,
  descricao: String,
  tipo: String,
  categoria: String,
  icone: String,
  cor: String,
  experienciaRecompensa: Number,
  raridade: String,
  desbloqueadaEm: Date,
  condicoes: {
    tipo: String,
    valor: Number,
    periodo: String
  },
  visivel: Boolean
}
```

### Notificação
```javascript
{
  _id: ObjectId,
  destinatario: ObjectId,
  tipo: String,
  titulo: String,
  mensagem: String,
  lida: Boolean,
  dataLeitura: Date,
  prioridade: String,
  dados: Object,
  agendadaPara: Date,
  enviada: Boolean,
  dataEnvio: Date,
  canal: Array,
  tentativasEnvio: Number,
  maxTentativas: Number,
  erroEnvio: Object
}
```

## 🚀 **Como Usar**

### 1. **Instalação**
```bash
npm install
```

### 2. **Configuração**
```bash
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

### 3. **Execução**
```bash
# Desenvolvimento
npm run dev

# Produção
npm start

# Com PM2
pm2 start ecosystem.config.js --env production
```

### 4. **Testes**
```bash
npm test
npm run test:coverage
```

## 🔧 **Configurações**

### Variáveis de Ambiente

Crie um arquivo `.env` na raiz do backend com as seguintes variáveis:

```bash
# Banco de Dados
MONGODB_URI=mongodb://localhost:27017/librarium

# JWT
JWT_SECRET=sua_chave_secreta_jwt_aqui

# Servidor
PORT=3000
NODE_ENV=development

# Google APIs (OAuth2)
# IMPORTANTE: Para integrações funcionarem, você PRECISA de ambos:
GOOGLE_CLIENT_ID=seu_google_client_id_aqui
GOOGLE_CLIENT_SECRET=seu_google_client_secret_aqui

# Email (opcional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=seu_email@gmail.com
SMTP_PASS=sua_senha_de_app_aqui

# Segurança
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
CORS_ORIGIN=http://localhost:3000

# Logs
LOG_LEVEL=info
LOG_FILE=logs/app.log
```

**⚠️ IMPORTANTE sobre Google APIs:**
- Para as integrações com Google Calendar e Google Fit funcionarem, você **PRECISA** de ambos `GOOGLE_CLIENT_ID` e `GOOGLE_CLIENT_SECRET`
- Se você só tem o Client ID, essas funcionalidades não funcionarão

## 📈 **Monitoramento**

### Health Check
```bash
curl http://localhost:3000/api/saude
```

### Logs
- Console: Desenvolvimento
- Arquivo: Produção (logs/librarium.log)
- Winston: Sistema de logging estruturado

### Métricas
- Rate limiting
- Tempo de resposta
- Uso de memória
- Conexões de banco

## 🐛 **Tratamento de Erros**

### Códigos de Status
- `200`: Sucesso
- `201`: Criado
- `400`: Dados inválidos
- `401`: Não autorizado
- `403`: Proibido
- `404`: Não encontrado
- `409`: Conflito
- `429`: Muitas requisições
- `500`: Erro interno

### Formato de Erro
```json
{
  "erro": "Descrição do erro",
  "mensagem": "Mensagem amigável",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/endpoint",
  "method": "GET"
}
```

## 🔒 **Segurança**

- **JWT**: Autenticação baseada em tokens
- **bcrypt**: Hash de senhas com salt
- **Helmet**: Headers de segurança HTTP
- **Rate Limiting**: Proteção contra spam
- **CORS**: Configuração de origens permitidas
- **Validação**: Sanitização de entrada
- **Logs**: Auditoria de todas as operações

## 📚 **Recursos Adicionais**

- **Documentação Swagger**: Em desenvolvimento
- **SDK Flutter**: Em desenvolvimento
- **Webhooks**: Em desenvolvimento
- **API Versioning**: Em desenvolvimento

---

**🎮 Que a caçada comece! Bem-vindo ao Librarium!** ⚔️
