# 🗡️ Librarium Frontend - App Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/Provider-6.1+-green.svg)](https://pub.dev/packages/provider)

> **Frontend do Librarium** - Um app Flutter gamificado com temática dark fantasy para gerenciamento de hábitos. Transforme sua jornada de desenvolvimento pessoal em uma aventura épica!

## **Visão Geral**

O Librarium Frontend é um aplicativo Flutter completo que gamifica o processo de construção de hábitos através de um sistema RPG imersivo. Com avatares evolutivos, sistema de conquistas, multiplayer e integrações avançadas, transforma tarefas mundanas em missões épicas.

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

### 📊 **Sistema de Dados Avançado**
- **Exportação Multi-formato** - JSON, XML, ZIP
- **Backup Automático** - Proteção de dados
- **Importação Inteligente** - Validação e mesclagem
- **Estatísticas Detalhadas** - Análises profundas
- **Sincronização Offline** - Funciona sem internet

## **Arquitetura Técnica**

### **Stack Principal**
- **Flutter 3.0+** - Framework de desenvolvimento
- **Dart 3.0+** - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **Go Router** - Navegação
- **HTTP** - Comunicação com API

### **UI e UX**
- **Material Design 3** - Design system moderno
- **Tema Dark Fantasy** - Visual imersivo
- **Animações Fluidas** - Transições suaves
- **Responsividade** - Adaptável a diferentes telas
- **Acessibilidade** - Inclusivo para todos

### **Funcionalidades Avançadas**
- **Lottie** - Animações complexas
- **FL Chart** - Gráficos interativos
- **Shimmer** - Efeitos de loading
- **Confetti** - Celebrações visuais
- **Cached Network Image** - Cache de imagens

## **Instalação e Configuração**

### **Pré-requisitos**
- Flutter 3.0+
- Dart 3.0+
- Android Studio / VS Code
- Git

### **Instalação Local**

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/librarium-front.git
cd librarium-front
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Configure a API**
```dart
// lib/services/api_service.dart
static const String baseUrl = 'https://librarium-backend-production.up.railway.app/api';
// Para desenvolvimento local: 'http://localhost:3000/api'
```

4. **Execute o app**
```bash
# Desenvolvimento
flutter run

# Build para produção
flutter build apk --release
```

### **Configuração de Assets**

Os assets estão organizados da seguinte forma:
```
assets/
├── avatars/          # Imagens dos avatares
├── icons/            # Ícones do app
├── backgrounds/      # Imagens de fundo
└── fonts/           # Fontes customizadas
```

## **Estrutura do Projeto**

```
lib/
├── main.dart                    # Ponto de entrada
├── theme/                       # Tema e cores
│   └── app_theme.dart
├── services/                     # Serviços
│   └── api_service.dart
├── providers/                    # Gerenciamento de estado
│   ├── auth_provider.dart
│   ├── habits_provider.dart
│   ├── avatar_provider.dart
│   ├── achievements_provider.dart
│   └── stats_provider.dart
├── screens/                      # Telas do app
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── habits/
│   │   ├── habits_screen.dart
│   │   └── create_habit_screen.dart
│   ├── achievements/
│   │   └── achievements_screen.dart
│   ├── stats/
│   │   └── stats_screen.dart
│   ├── multiplayer/
│   │   └── multiplayer_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/                      # Widgets reutilizáveis
    ├── custom_button.dart
    ├── custom_text_field.dart
    ├── loading_overlay.dart
    ├── avatar_widget.dart
    ├── habit_card.dart
    ├── stats_card.dart
    ├── achievement_badge.dart
    └── custom_bottom_nav.dart
```

## **Telas Principais**

### **🔐 Autenticação**
- **Login** - Acesso com email e senha
- **Registro** - Criação de nova conta
- **Validação** - Verificação de dados

### **🏠 Dashboard**
- **Avatar Evolutivo** - Visualização do personagem
- **Estatísticas** - Resumo do progresso
- **Hábitos do Dia** - Lista de tarefas
- **Conquistas Recentes** - Últimas vitórias

### **📝 Hábitos**
- **Lista de Hábitos** - Todos os hábitos criados
- **Criar Hábito** - Formulário de criação
- **Completar Hábito** - Marcar como concluído
- **Estatísticas** - Progresso individual

### **🏆 Conquistas**
- **Lista de Conquistas** - Todas as conquistas
- **Conquistas Desbloqueadas** - Já conquistadas
- **Conquistas Bloqueadas** - Ainda não desbloqueadas
- **Progresso** - Percentual de conclusão

### **📊 Estatísticas**
- **Resumo Geral** - Números principais
- **Gráfico Semanal** - Atividade dos últimos 7 dias
- **Por Categoria** - Estatísticas por tipo
- **Sequências** - Histórico de streaks

### **⚔️ Multiplayer**
- **Batalhas PvP** - Competições entre jogadores
- **Desafios Colaborativos** - Missões em equipe
- **Ranking Global** - Classificação mundial
- **Chat** - Comunicação entre usuários

### **👤 Perfil**
- **Informações do Usuário** - Dados pessoais
- **Avatar** - Visualização e equipamentos
- **Configurações** - Preferências do app
- **Logout** - Sair da conta

## **Widgets Customizados**

### **Componentes Base**
- **CustomButton** - Botões personalizados
- **CustomTextField** - Campos de texto
- **LoadingOverlay** - Tela de carregamento

### **Componentes Específicos**
- **AvatarWidget** - Visualização do avatar
- **HabitCard** - Card de hábito
- **StatsCard** - Card de estatística
- **AchievementBadge** - Badge de conquista
- **CustomBottomNav** - Navegação inferior

## **Tema Dark Fantasy**

### **Paleta de Cores**
- **Primária**: #6A0572 (Roxo escuro)
- **Secundária**: #9A031E (Vermelho escuro)
- **Accent**: #F77F00 (Laranja)
- **Background**: #0D1117 (Preto azulado)
- **Surface**: #161B22 (Cinza escuro)
- **Card**: #21262D (Cinza médio)

### **Tipografia**
- **Fonte Principal**: Librarium (Custom)
- **Tamanhos**: Display, Headline, Title, Body
- **Pesos**: Regular, Medium, Bold

### **Efeitos Visuais**
- **Gradientes** - Transições suaves de cor
- **Sombras** - Profundidade e elevação
- **Bordas** - Destaque de elementos
- **Animações** - Movimento fluido

## **Integração com Backend**

### **Endpoints Utilizados**
- **Autenticação**: `/api/auth/*`
- **Hábitos**: `/api/habitos/*`
- **Avatar**: `/api/avatar/*`
- **Conquistas**: `/api/conquistas/*`
- **Estatísticas**: `/api/estatisticas/*`
- **Multiplayer**: `/api/multiplayer/*`

### **Gerenciamento de Estado**
- **Provider** - Gerenciamento reativo
- **SharedPreferences** - Persistência local
- **HTTP** - Comunicação com API
- **Error Handling** - Tratamento de erros

## **Funcionalidades Futuras**

### **Próximas Versões**
- **Notificações Push** - Lembretes inteligentes
- **Modo Offline** - Funcionamento sem internet
- **Temas Personalizados** - Customização visual
- **Integração Social** - Compartilhamento
- **Analytics** - Métricas detalhadas

### **Melhorias Planejadas**
- **Performance** - Otimização de recursos
- **Acessibilidade** - Suporte completo
- **Internacionalização** - Múltiplos idiomas
- **Testes** - Cobertura completa
- **Documentação** - Guias detalhados

## **Desenvolvimento**

### **Comandos Úteis**
```bash
# Instalar dependências
flutter pub get

# Executar app
flutter run

# Build para Android
flutter build apk --release

# Build para iOS
flutter build ios --release

# Análise de código
flutter analyze

# Testes
flutter test

# Limpeza
flutter clean
```

### **Debugging**
- **Flutter Inspector** - Inspeção de widgets
- **Performance** - Análise de performance
- **Network** - Monitoramento de requisições
- **Logs** - Sistema de logging

## **Deploy**

### **Android**
1. Configure o `android/app/build.gradle`
2. Gere a chave de assinatura
3. Build da APK/AAB
4. Upload para Google Play

### **iOS**
1. Configure o `ios/Runner.xcworkspace`
2. Gere certificados de desenvolvimento
3. Build do IPA
4. Upload para App Store

### **Web**
1. Configure o `web/index.html`
2. Build para web
3. Deploy em servidor

## **Contribuição**

### **Como Contribuir**
1. **Fork** o projeto
2. **Crie** uma branch para sua feature
3. **Commit** suas mudanças
4. **Push** para a branch
5. **Abra** um Pull Request

### **Padrões de Código**
- **Dart/Flutter Lints** - Análise estática
- **Formatação** - Código consistente
- **Documentação** - Comentários claros
- **Testes** - Cobertura adequada

## 📄 **Licença**

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🙏 **Agradecimentos**

- **Flutter Team** - Framework incrível
- **Provider** - Gerenciamento de estado
- **Material Design** - Design system
- **Hollow Knight** - Inspiração visual
- **Devil May Cry** - Inspiração gamificada

---

## 🎮 **Que a Aventura Comece!**

**Bem-vindo ao Librarium!** ⚔️✨

Transforme sua jornada de desenvolvimento pessoal em uma aventura épica. Cada hábito é uma missão, cada conquista é uma vitória, e cada dia é uma nova oportunidade de evoluir.

**O Librarium aguarda seus heróis...** 🗡️👑

---

**Desenvolvido com paixão, Flutter e muita cafeína por Pedro Zucchi**

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black.svg)](https://github.com/pedro-zucchi90)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Profile-blue.svg)](https://www.linkedin.com/in/pedro-zucchi-52b50132b/)
