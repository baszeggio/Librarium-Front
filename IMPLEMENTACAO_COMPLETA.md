# 🗡️ Librarium Flutter App - Documentação Completa

## 📋 Visão Geral

O Librarium é um aplicativo de rastreamento de hábitos gamificado com temática dark fantasy. O app oferece uma experiência RPG completa onde os usuários evoluem seus avatares através da consistência nos hábitos.

## 🎯 Funcionalidades Principais

### ✅ **Sistema de Autenticação**
- Login/Registro com email e senha
- Autenticação JWT
- Recuperação de senha
- Perfil do usuário

### ✅ **Gerenciamento de Hábitos**
- CRUD completo de hábitos
- Categorização por tipo
- Dificuldade configurável
- Frequência personalizada
- Histórico de progresso

### ✅ **Sistema de Gamificação**
- Avatar evolutivo (6 níveis)
- Sistema de XP e níveis
- Conquistas automáticas (25+ tipos)
- Equipamentos e customização
- Efeitos visuais progressivos

### ✅ **Multiplayer**
- Batalhas entre usuários
- Sistema de desafios
- Chat e mensagens
- Ranking global
- Estatísticas competitivas

### ✅ **Integrações**
- Google Calendar
- Google Fit
- Sincronização de dados de saúde
- Notificações push

### ✅ **Modo Offline**
- Armazenamento local (SQLite)
- Sincronização automática
- Funcionamento sem internet
- Queue de operações

---

## 🏗️ Arquitetura do App

### 📁 **Estrutura de Pastas**

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── routes.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── controllers/
│   └── themes/
└── services/
    ├── auth_service.dart
    ├── habit_service.dart
    ├── achievement_service.dart
    ├── multiplayer_service.dart
    ├── sync_service.dart
    └── notification_service.dart
```

### 🔧 **Tecnologias Utilizadas**

- **Flutter**: Framework principal
- **SQLite**: Banco local (sqflite)
- **Provider/Riverpod**: Gerenciamento de estado
- **Dio**: Cliente HTTP
- **Shared Preferences**: Configurações locais
- **Workmanager**: Tarefas em background
- **Local Notifications**: Notificações locais
- **Connectivity Plus**: Detecção de conectividade

---

## 📱 Telas e Navegação

### 🏠 **Tela Principal (Home)**

#### **Bottom Navigation Bar**
```
🏠 Início    ⚔️ Batalhas    📊 Progresso    👤 Perfil
```

#### **Tela de Início**
- **Header com Avatar**: Nível, XP, título
- **Hábitos do Dia**: Lista de hábitos pendentes
- **Conquistas Recentes**: Últimas conquistas desbloqueadas
- **Estatísticas Rápidas**: Sequência atual, hábitos concluídos
- **Ações Rápidas**: Botões para criar hábito, ver ranking

### ⚔️ **Sistema de Batalhas**

#### **Tela de Batalhas**
- **Batalhas Ativas**: Lista de batalhas em andamento
- **Criar Batalha**: Modal para desafiar outros usuários
- **Histórico**: Batalhas concluídas
- **Ranking**: Top jogadores

#### **Tela de Criação de Batalha**
- **Seleção de Adversário**: Lista de usuários online
- **Tipo de Batalha**: Sequência, XP diário, hábitos concluídos
- **Duração**: 1h, 3h, 6h, 24h
- **Configurações**: Privada, permitir espectadores

#### **Tela de Batalha Ativa**
- **Progresso em Tempo Real**: Pontuação de ambos os jogadores
- **Chat da Batalha**: Mensagens durante a batalha
- **Estatísticas**: Métricas detalhadas
- **Ações**: Finalizar, abandonar

### 📊 **Sistema de Progresso**

#### **Tela de Estatísticas**
- **Gráficos**: Semanal, mensal, anual
- **Heatmap**: Calendário de atividades
- **Categorias**: Progresso por tipo de hábito
- **Conquistas**: Lista completa com progresso

#### **Tela de Hábitos**
- **Lista de Hábitos**: Todos os hábitos criados
- **Filtros**: Por categoria, status, dificuldade
- **Criação/Edição**: Formulário completo
- **Histórico**: Progresso individual de cada hábito

### 👤 **Sistema de Perfil**

#### **Tela de Perfil**
- **Avatar 3D**: Visualização do avatar atual
- **Informações**: Nível, XP, título, conquistas
- **Customização**: Equipamentos, cores, efeitos
- **Configurações**: Notificações, tema, idioma

#### **Tela de Customização**
- **Equipamentos**: Arma, armadura, acessório
- **Efeitos**: Aura, partículas, temas
- **Cores**: Paleta personalizada
- **Preview**: Visualização em tempo real

### 🏆 **Sistema de Conquistas**

#### **Tela de Conquistas**
- **Categorias**: Por tipo de conquista
- **Progresso**: Barra de progresso para cada conquista
- **Raridade**: Comum, Raro, Épico, Lendário
- **Recompensas**: XP, itens, títulos

### 💬 **Sistema de Mensagens**

#### **Tela de Chat**
- **Lista de Conversas**: Usuários com mensagens
- **Chat Individual**: Interface de mensagens
- **Notificações**: Mensagens não lidas
- **Anexos**: Imagens, emojis, stickers

### 🔗 **Integrações**

#### **Tela de Integrações**
- **Google Calendar**: Sincronização de hábitos
- **Google Fit**: Dados de saúde
- **Status**: Estado das integrações
- **Configurações**: Permissões e preferências

---

## 🎨 Design System

### 🌙 **Tema Dark Fantasy**

#### **Cores Principais**
```dart
// Cores base
primary: Color(0xFF1A1A2E)      // Preto profundo
secondary: Color(0xFF16213E)    // Azul escuro
accent: Color(0xFF0F3460)       // Azul médio
highlight: Color(0xFFE94560)    // Vermelho sangue

// Cores de status
success: Color(0xFF4CAF50)      // Verde
warning: Color(0xFFFF9800)      // Laranja
error: Color(0xFFF44336)        // Vermelho
info: Color(0xFF2196F3)         // Azul

// Cores de texto
textPrimary: Color(0xFFFFFFFF)  // Branco
textSecondary: Color(0xFFB0B0B0) // Cinza claro
textMuted: Color(0xFF808080)    // Cinza médio
```

#### **Tipografia**
```dart
// Fontes
primaryFont: 'Cinzel'           // Títulos e headers
secondaryFont: 'Crimson Text'   // Corpo do texto
monospaceFont: 'Fira Code'      // Código e números

// Tamanhos
h1: 32.sp
h2: 24.sp
h3: 20.sp
h4: 18.sp
body: 16.sp
caption: 14.sp
small: 12.sp
```

#### **Componentes Base**

##### **Botões**
```dart
// Botão Primário
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.accent,
    foregroundColor: Colors.textPrimary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 8,
    shadowColor: Colors.accent.withOpacity(0.3),
  ),
  child: Text('Texto do Botão'),
)

// Botão Secundário
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.accent, width: 2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Texto do Botão'),
)
```

##### **Cards**
```dart
Card(
  elevation: 4,
  shadowColor: Colors.primary.withOpacity(0.3),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  color: Colors.secondary,
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        // Conteúdo do card
      ],
    ),
  ),
)
```

##### **Inputs**
```dart
TextField(
  style: TextStyle(color: Colors.textPrimary),
  decoration: InputDecoration(
    labelText: 'Label',
    labelStyle: TextStyle(color: Colors.textSecondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.accent),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.accent.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.accent, width: 2),
    ),
  ),
)
```

### 🎭 **Animações e Efeitos**

#### **Transições de Página**
```dart
// Transição personalizada
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => NextPage(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  },
)
```

#### **Animações de Avatar**
```dart
// Evolução do avatar
AnimatedContainer(
  duration: Duration(seconds: 2),
  curve: Curves.easeInOut,
  child: AvatarWidget(
    level: newLevel,
    effects: evolutionEffects,
  ),
)
```

#### **Efeitos de Partículas**
```dart
// Partículas de XP
ParticleSystem(
  particles: [
    Particle(
      position: Offset(x, y),
      velocity: Offset(vx, vy),
      color: Colors.highlight,
      size: 4.0,
    ),
  ],
  duration: Duration(seconds: 3),
)
```

---

## 🗄️ Banco de Dados Local

### 📊 **Estrutura SQLite**

#### **Tabela de Usuários**
```sql
CREATE TABLE usuarios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome_usuario TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  experiencia INTEGER DEFAULT 0,
  nivel INTEGER DEFAULT 1,
  titulo TEXT,
  avatar_data TEXT, -- JSON do avatar
  ultima_sincronizacao DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### **Tabela de Hábitos**
```sql
CREATE TABLE habitos (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id INTEGER NOT NULL,
  titulo TEXT NOT NULL,
  descricao TEXT,
  categoria TEXT NOT NULL,
  dificuldade INTEGER DEFAULT 1,
  frequencia TEXT DEFAULT 'diario',
  ativo BOOLEAN DEFAULT 1,
  meta_diaria INTEGER DEFAULT 1,
  xp_por_conclusao INTEGER DEFAULT 10,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
);
```

#### **Tabela de Progresso**
```sql
CREATE TABLE progresso (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  habito_id INTEGER NOT NULL,
  data DATE NOT NULL,
  status TEXT DEFAULT 'pendente', -- pendente, concluido, falhado
  experiencia_ganha INTEGER DEFAULT 0,
  observacoes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (habito_id) REFERENCES habitos (id)
);
```

#### **Tabela de Conquistas**
```sql
CREATE TABLE conquistas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuario_id INTEGER NOT NULL,
  tipo TEXT NOT NULL,
  nome TEXT NOT NULL,
  descricao TEXT,
  raridade TEXT DEFAULT 'comum',
  xp_recompensa INTEGER DEFAULT 0,
  desbloqueada BOOLEAN DEFAULT 0,
  data_desbloqueio DATETIME,
  progresso_atual INTEGER DEFAULT 0,
  progresso_necessario INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
);
```

#### **Tabela de Batalhas**
```sql
CREATE TABLE batalhas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  jogador1_id INTEGER NOT NULL,
  jogador2_id INTEGER NOT NULL,
  tipo_batalha TEXT NOT NULL,
  status TEXT DEFAULT 'aguardando',
  duracao INTEGER NOT NULL,
  data_inicio DATETIME,
  data_fim DATETIME,
  pontuacao_jogador1 INTEGER DEFAULT 0,
  pontuacao_jogador2 INTEGER DEFAULT 0,
  vencedor_id INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (jogador1_id) REFERENCES usuarios (id),
  FOREIGN KEY (jogador2_id) REFERENCES usuarios (id),
  FOREIGN KEY (vencedor_id) REFERENCES usuarios (id)
);
```

#### **Tabela de Mensagens**
```sql
CREATE TABLE mensagens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  remetente_id INTEGER NOT NULL,
  destinatario_id INTEGER NOT NULL,
  texto TEXT NOT NULL,
  tipo TEXT DEFAULT 'privada',
  lida BOOLEAN DEFAULT 0,
  anexos TEXT, -- JSON de anexos
  resposta_para INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (remetente_id) REFERENCES usuarios (id),
  FOREIGN KEY (destinatario_id) REFERENCES usuarios (id),
  FOREIGN KEY (resposta_para) REFERENCES mensagens (id)
);
```

#### **Tabela de Sincronização**
```sql
CREATE TABLE sincronizacao (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tabela TEXT NOT NULL,
  registro_id INTEGER NOT NULL,
  operacao TEXT NOT NULL, -- CREATE, UPDATE, DELETE
  dados TEXT NOT NULL, -- JSON dos dados
  sincronizado BOOLEAN DEFAULT 0,
  tentativas INTEGER DEFAULT 0,
  ultima_tentativa DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🔄 Sistema de Sincronização

### 📡 **Estratégia Offline-First**

#### **Fluxo de Sincronização**
```dart
class SyncService {
  // 1. Verificar conectividade
  Future<bool> isConnected() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  // 2. Sincronizar dados pendentes
  Future<void> syncPendingData() async {
    if (!await isConnected()) return;
    
    final pendingOperations = await _getPendingOperations();
    
    for (final operation in pendingOperations) {
      try {
        await _syncOperation(operation);
        await _markAsSynced(operation.id);
      } catch (e) {
        await _incrementRetryCount(operation.id);
      }
    }
  }

  // 3. Sincronizar dados do servidor
  Future<void> syncFromServer() async {
    if (!await isConnected()) return;
    
    // Sincronizar hábitos
    await _syncHabits();
    
    // Sincronizar conquistas
    await _syncAchievements();
    
    // Sincronizar batalhas
    await _syncBattles();
    
    // Sincronizar mensagens
    await _syncMessages();
  }
}
```

#### **Queue de Operações**
```dart
class OperationQueue {
  // Adicionar operação à queue
  Future<void> addOperation({
    required String table,
    required int recordId,
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final operation = SyncOperation(
      table: table,
      recordId: recordId,
      operation: operation,
      data: jsonEncode(data),
      createdAt: DateTime.now(),
    );
    
    await _database.insert('sincronizacao', operation.toMap());
  }

  // Processar queue
  Future<void> processQueue() async {
    final operations = await _getPendingOperations();
    
    for (final operation in operations) {
      await _processOperation(operation);
    }
  }
}
```

---

## 🔔 Sistema de Notificações

### 📱 **Notificações Locais**

#### **Configuração**
```dart
class NotificationService {
  static final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  // Agendar notificação de hábito
  static Future<void> scheduleHabitReminder({
    required int habitId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      habitId,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Lembretes de Hábitos',
          channelDescription: 'Notificações para lembrar de completar hábitos',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

#### **Tipos de Notificações**
- **Lembretes de Hábitos**: Horários configurados
- **Conquistas Desbloqueadas**: Imediatas
- **Batalhas**: Convites e resultados
- **Mensagens**: Novas mensagens recebidas
- **Evolução de Avatar**: Quando evoluir de nível

---

## 🎮 Sistema de Gamificação

### ⚔️ **Avatar Evolutivo**

#### **Níveis de Evolução**
```dart
enum AvatarLevel {
  aspirante(1, 10, 'Aspirante'),
  cacador(11, 20, 'Caçador'),
  guardiao(21, 30, 'Guardião'),
  conjurador(31, 39, 'Conjurador'),
  conjuradorAvancado(40, 49, 'Conjurador Avançado'),
  conjuradorSupremo(50, 999, 'Conjurador Supremo');

  const AvatarLevel(this.minLevel, this.maxLevel, this.title);
  
  final int minLevel;
  final int maxLevel;
  final String title;
}
```

#### **Sistema de Equipamentos**
```dart
class Equipment {
  final String id;
  final String name;
  final EquipmentType type;
  final Rarity rarity;
  final int requiredLevel;
  final Map<String, dynamic> stats;
  final String imagePath;
  final List<String> effects;
}

enum EquipmentType {
  weapon,
  armor,
  accessory,
  aura,
  particles,
}
```

#### **Sistema de Conquistas**
```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final Rarity rarity;
  final int xpReward;
  final Map<String, dynamic> requirements;
  final String iconPath;
  final List<String> rewards;
}

enum AchievementType {
  firstHabit,
  weeklyStreak,
  monthlyConsistency,
  levelUp,
  habitVariety,
  xpMilestone,
  custom,
}
```

---

## 🏗️ Implementação por Fases

### 🚀 **Fase 1 - MVP (4 semanas)**

#### **Semana 1-2: Estrutura Base**
- [ ] Configuração do projeto Flutter
- [ ] Estrutura de pastas e arquitetura
- [ ] Configuração do banco SQLite
- [ ] Sistema de autenticação
- [ ] Tela de login/registro

#### **Semana 3-4: Funcionalidades Core**
- [ ] CRUD de hábitos
- [ ] Sistema de progresso
- [ ] Tela principal com hábitos do dia
- [ ] Sistema básico de XP e níveis
- [ ] Sincronização com backend

### ⚔️ **Fase 2 - Gamificação (3 semanas)**

#### **Semana 5-6: Avatar e Conquistas**
- [ ] Sistema de avatar evolutivo
- [ ] Customização de equipamentos
- [ ] Sistema de conquistas
- [ ] Animações de evolução
- [ ] Efeitos visuais

#### **Semana 7: Polimento**
- [ ] Refinamento das animações
- [ ] Otimização de performance
- [ ] Testes de usabilidade
- [ ] Correção de bugs

### 🌐 **Fase 3 - Multiplayer (4 semanas)**

#### **Semana 8-9: Sistema de Batalhas**
- [ ] Tela de batalhas
- [ ] Criação de batalhas
- [ [ ] Batalhas em tempo real
- [ ] Sistema de ranking

#### **Semana 10-11: Chat e Mensagens**
- [ ] Sistema de mensagens
- [ ] Chat em tempo real
- [ ] Notificações de mensagens
- [ ] Sistema de amizades

### 🔗 **Fase 4 - Integrações (2 semanas)**

#### **Semana 12-13: Integrações Externas**
- [ ] Google Calendar
- [ ] Google Fit
- [ ] Notificações push
- [ ] Modo offline completo

---

## 📱 Especificações Técnicas

### 🔧 **Configurações do Projeto**

#### **pubspec.yaml**
```yaml
name: librarium
description: Gamified habit tracker with dark fantasy theme

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.0.5
  
  # Database
  sqflite: ^2.3.0
  path: ^1.8.3
  
  # Network
  dio: ^5.3.2
  connectivity_plus: ^5.0.1
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Background Tasks
  workmanager: ^0.5.1
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # UI
  flutter_svg: ^2.0.9
  lottie: ^2.7.0
  shimmer: ^3.0.0
  
  # Utils
  intl: ^0.18.1
  uuid: ^4.2.1
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

#### **Configurações Android**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
```

#### **Configurações iOS**
```xml
<!-- ios/Runner/Info.plist -->
<key>UIBackgroundModes</key>
<array>
  <string>background-processing</string>
  <string>background-fetch</string>
</array>
```

---

## 🎨 Guia de Design

### 🖼️ **Assets Necessários**

#### **Ícones e Ilustrações**
```
assets/images/
├── avatars/
│   ├── aspirante.png
│   ├── cacador.png
│   ├── guardiao.png
│   ├── conjurador.png
│   ├── conjurador_avancado.png
│   └── conjurador_supremo.png
├── equipment/
│   ├── weapons/
│   ├── armor/
│   ├── accessories/
│   └── effects/
├── achievements/
│   ├── common/
│   ├── rare/
│   ├── epic/
│   └── legendary/
├── ui/
│   ├── buttons/
│   ├── cards/
│   ├── inputs/
│   └── backgrounds/
└── animations/
    ├── xp_gain.json
    ├── level_up.json
    ├── achievement_unlock.json
    └── battle_effects.json
```

#### **Cores e Gradientes**
```dart
class AppColors {
  // Gradientes principais
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accentGradient = LinearGradient(
    colors: [Color(0xFF0F3460), Color(0xFFE94560)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Cores de status
  static const successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
  );
  
  static const warningGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFC107)],
  );
}
```

### 🎭 **Animações Personalizadas**

#### **Lottie Animations**
- **XP Gain**: Partículas de XP subindo
- **Level Up**: Efeito de evolução do avatar
- **Achievement Unlock**: Conquista desbloqueada
- **Battle Effects**: Efeitos de batalha
- **Loading**: Loading personalizado

#### **Custom Animations**
```dart
class CustomAnimations {
  // Animação de evolução do avatar
  static Widget avatarEvolution({
    required Widget child,
    required bool isEvolving,
  }) {
    return AnimatedContainer(
      duration: Duration(seconds: 2),
      curve: Curves.easeInOut,
      transform: isEvolving 
        ? Matrix4.identity()..scale(1.2)
        : Matrix4.identity(),
      child: AnimatedOpacity(
        opacity: isEvolving ? 0.8 : 1.0,
        duration: Duration(milliseconds: 500),
        child: child,
      ),
    );
  }
  
  // Animação de conquista
  static Widget achievementUnlock({
    required Widget child,
    required bool isUnlocked,
  }) {
    return AnimatedScale(
      scale: isUnlocked ? 1.0 : 0.0,
      duration: Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      child: child,
    );
  }
}
```

---

## 🧪 Testes

### 🔬 **Estratégia de Testes**

#### **Testes Unitários**
```dart
// Exemplo de teste para serviço de hábitos
class HabitServiceTest {
  late HabitService habitService;
  late MockDatabase mockDatabase;
  
  setUp(() {
    mockDatabase = MockDatabase();
    habitService = HabitService(mockDatabase);
  });
  
  test('should create habit successfully', () async {
    // Arrange
    final habit = Habit(
      title: 'Test Habit',
      category: 'Health',
      difficulty: 1,
    );
    
    when(mockDatabase.insert(any, any))
        .thenAnswer((_) async => 1);
    
    // Act
    final result = await habitService.createHabit(habit);
    
    // Assert
    expect(result, isA<Habit>());
    expect(result.title, equals('Test Habit'));
  });
}
```

#### **Testes de Widget**
```dart
// Exemplo de teste para widget de hábito
class HabitCardTest {
  testWidgets('should display habit information correctly', (tester) async {
    // Arrange
    final habit = Habit(
      id: 1,
      title: 'Test Habit',
      category: 'Health',
      difficulty: 2,
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: HabitCard(habit: habit),
      ),
    );
    
    // Assert
    expect(find.text('Test Habit'), findsOneWidget);
    expect(find.text('Health'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(2));
  });
}
```

#### **Testes de Integração**
```dart
// Exemplo de teste de integração
class AppIntegrationTest {
  testWidgets('should complete full habit flow', (tester) async {
    // Arrange
    await tester.pumpWidget(MyApp());
    
    // Act & Assert
    // 1. Login
    await tester.enterText(find.byKey(Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password');
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();
    
    // 2. Create habit
    await tester.tap(find.byKey(Key('create_habit_button')));
    await tester.enterText(find.byKey(Key('habit_title_field')), 'New Habit');
    await tester.tap(find.byKey(Key('save_habit_button')));
    await tester.pumpAndSettle();
    
    // 3. Complete habit
    await tester.tap(find.byKey(Key('complete_habit_button')));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('Habit completed!'), findsOneWidget);
  });
}
```

---

## 🚀 Deploy e Distribuição

### 📱 **Build para Produção**

#### **Android (APK/AAB)**
```bash
# Build APK
flutter build apk --release --target-platform android-arm64

# Build AAB (Google Play)
flutter build appbundle --release
```

#### **iOS (IPA)**
```bash
# Build para iOS
flutter build ios --release
```

### 🔧 **Configurações de Build**

#### **android/app/build.gradle**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.librarium.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### **ios/Runner/Info.plist**
```xml
<key>CFBundleDisplayName</key>
<string>Librarium</string>
<key>CFBundleIdentifier</key>
<string>com.librarium.app</string>
<key>CFBundleVersion</key>
<string>1.0.0</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

---

## 📊 Métricas e Analytics

### 📈 **Métricas de Uso**

#### **Eventos Principais**
```dart
class AnalyticsService {
  static Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    // Implementar tracking com Firebase Analytics ou similar
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  // Eventos específicos do app
  static Future<void> trackHabitCompleted(int habitId, String category) async {
    await trackEvent('habit_completed', {
      'habit_id': habitId,
      'category': category,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static Future<void> trackLevelUp(int newLevel, int xpGained) async {
    await trackEvent('level_up', {
      'new_level': newLevel,
      'xp_gained': xpGained,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static Future<void> trackBattleCreated(String battleType, int duration) async {
    await trackEvent('battle_created', {
      'battle_type': battleType,
      'duration': duration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

#### **Métricas de Performance**
- **Tempo de carregamento**: Inicialização do app
- **Tempo de sincronização**: Sincronização com backend
- **Uso de memória**: Monitoramento de RAM
- **Bateria**: Consumo de energia
- **Crash rate**: Taxa de crashes

---

## 🔒 Segurança

### 🛡️ **Medidas de Segurança**

#### **Armazenamento Local**
```dart
class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  // Armazenar token JWT
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }
  
  // Recuperar token JWT
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }
  
  // Limpar dados sensíveis
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

#### **Validação de Dados**
```dart
class DataValidator {
  // Validar email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validar senha
  static bool isValidPassword(String password) {
    return password.length >= 6 && password.length <= 50;
  }
  
  // Validar dados de hábito
  static bool isValidHabit(Map<String, dynamic> data) {
    return data['title'] != null && 
           data['title'].toString().isNotEmpty &&
           data['category'] != null &&
           data['difficulty'] != null &&
           data['difficulty'] >= 1 && 
           data['difficulty'] <= 5;
  }
}
```

---

## 📚 Documentação Adicional

### 📖 **Recursos para Desenvolvedores**

#### **APIs e Endpoints**
- [Documentação da API Backend](./backend/API_DOCUMENTATION.md)
- [Modelos de Dados](./backend/INDICE_DOCUMENTACAO.md)
- [Guia de Integração](./backend/README.md)

#### **Design e UX**
- [Guia de Design System](./docs/design-system.md)
- [Componentes UI](./docs/ui-components.md)
- [Animações e Transições](./docs/animations.md)

#### **Arquitetura e Código**
- [Arquitetura do App](./docs/architecture.md)
- [Padrões de Código](./docs/coding-standards.md)
- [Convenções de Nomenclatura](./docs/naming-conventions.md)

---

## 🎯 Conclusão

Esta documentação fornece um guia completo para o desenvolvimento do aplicativo Librarium Flutter. O app combina funcionalidades de rastreamento de hábitos com elementos de gamificação RPG, oferecendo uma experiência única e envolvente para os usuários.

### 🚀 **Próximos Passos**

1. **Configurar o ambiente de desenvolvimento**
2. **Implementar a estrutura base do projeto**
3. **Desenvolver as funcionalidades core**
4. **Adicionar elementos de gamificação**
5. **Implementar funcionalidades multiplayer**
6. **Integrar com serviços externos**
7. **Testes e otimizações**
8. **Deploy e distribuição**

### 🎮 **Que a caçada comece!**

O Librarium está pronto para ser desenvolvido e levar os usuários em uma jornada épica de transformação de hábitos! ⚔️🗡️

---

**Desenvolvido com ❤️ pela equipe Librarium**  
*Versão 1.0.0 - Janeiro 2024*