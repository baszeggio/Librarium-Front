import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/multiplayer_provider.dart';
import '../../providers/messages_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../ranking/ranking_screen.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _opponentIdController = TextEditingController();
  String? _selectedChatUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MultiplayerProvider>().loadBattles();
      context.read<MultiplayerProvider>().loadChallenges();
      context.read<MessagesProvider>().loadMessages();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    _opponentIdController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1117),
              Color(0xFF161B22),
              Color(0xFF21262D),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              // Exibir conteúdo mesmo se não autenticado para visualização
              return _buildMultiplayerContent();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMultiplayerContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/dashboard');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
              const SizedBox(width: 8),
              Text(
                'Multiplayer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Seção de batalhas
          _buildBattlesSection(),

          const SizedBox(height: 24),

          // Seção de desafios
          _buildChallengesSection(),

          const SizedBox(height: 24),

          // Seção de ranking
          _buildRankingSection(),

          const SizedBox(height: 24),

          // Chat em tempo real (front-end)
          _buildChatSection(),

          const SizedBox(height: 24),

          // Sistema de amizades (front-end)
          _buildFriendsSection(),
        ],
      ),
    );
  }

  Widget _buildBattlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batalhas PvP',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.sports_mma,
                    size: 32,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Suas Batalhas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      context.read<MultiplayerProvider>().loadBattles();
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<MultiplayerProvider>(
                builder: (context, multiplayerProvider, child) {
                  if (multiplayerProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (multiplayerProvider.error != null) {
                    return Column(
                      children: [
                        Text(
                          'Erro ao carregar batalhas',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          multiplayerProvider.error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                        ),
                      ],
                    );
                  }
                  
                  final battles = multiplayerProvider.battles;
                  if (battles.isEmpty) {
                    return Text(
                      'Nenhuma batalha encontrada.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                    );
                  }
                  
                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: battles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final battle = battles[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  battle.status == 'concluida' ? Icons.emoji_events : Icons.sports_mma,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vs. ${battle.jogador2}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          _buildTag('Status: ${battle.status}'),
                                          _buildTag('Tipo: ${battle.tipoBatalha}'),
                                          if (battle.resultado != null) 
                                            _buildTag('Resultado: ${battle.resultado?['vencedor'] ?? 'Empate'}'),
                                        ],
                                      ),
                                      if (battle.status == 'aguardando')
                                        const SizedBox(height: 8),
                                      if (battle.status == 'aguardando')
                                        CustomButton(
                                          text: 'Aceitar',
                                          onPressed: () {
                                            multiplayerProvider.acceptBattle(battle.id);
                                          },
                                          backgroundColor: Colors.green,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Criar Batalha',
                              onPressed: () => _showCreateBattleDialog(context),
                              backgroundColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Atualizar',
                              onPressed: () {
                                multiplayerProvider.loadBattles();
                              },
                              backgroundColor: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Desafios Colaborativos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.group_work,
                size: 48,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Trabalhe em equipe!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Participe de desafios colaborativos com outros jogadores!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Criar Desafio',
                      onPressed: () {
                        _showCreateChallengeDialog();
                      },
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Ver Desafios',
                      onPressed: () {
                        _showChallengesList();
                      },
                      backgroundColor: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranking Global',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.emoji_events,
                size: 48,
                color: Colors.orange[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Veja os melhores guerreiros!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Compare seu progresso com outros jogadores!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Ver Ranking',
                onPressed: () {
                  _showRanking();
                },
                backgroundColor: Colors.orange,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCreateBattleDialog(BuildContext context) {
    final opponentIdController = TextEditingController();
    String? selectedType = 'sequencia';
    final durationController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text(
                'Criar Batalha',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: opponentIdController,
                      label: 'ID do Adversário',
                      hint: 'Digite o ID do adversário',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Batalha',
                        labelStyle: TextStyle(color: Colors.grey),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'sequencia', child: Text('Sequência')),
                        DropdownMenuItem(value: 'xp_diario', child: Text('XP Diário')),
                        DropdownMenuItem(value: 'habitos_concluidos', child: Text('Hábitos Concluídos')),
                      ],
                      onChanged: (value) => setState(() => selectedType = value),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: durationController,
                      label: 'Duração (minutos)',
                      hint: '60',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    if (opponentIdController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Digite o ID do adversário')),
                      );
                      return;
                    }
                    try {
                      await context.read<MultiplayerProvider>().createBattle(
                        adversarioId: opponentIdController.text.trim(),
                        tipoBatalha: selectedType,
                        duracao: int.tryParse(durationController.text) ?? 60,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Batalha criada com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBattlesList() {
    context.read<MultiplayerProvider>().loadBattles();
  }

  void _showCreateChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Criar Desafio',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Funcionalidade em desenvolvimento. Em breve você poderá criar desafios colaborativos!',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChallengesList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Desafios Disponíveis',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Nenhum desafio disponível no momento.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRanking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RankingScreen(),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }

  Widget _buildChatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chat em Tempo Real',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<MessagesProvider>(
                  builder: (context, messagesProvider, child) {
                    final messages = messagesProvider.messages;
                    if (_selectedChatUser == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[600]),
                            const SizedBox(height: 8),
                            Text(
                              'Selecione um usuário para começar',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.message, size: 48, color: Colors.grey[600]),
                                const SizedBox(height: 8),
                                Text(
                                  'Nenhuma mensagem ainda.\nDiga oi!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final m = messages[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(
                                  children: [
                                    Icon(Icons.account_circle, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: '${m.remetente}: ',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(text: m.texto),
                                          ],
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedChatUser == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextButton.icon(
                    onPressed: _showSelectUserDialog,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Selecionar Usuário para Conversar'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: InputDecoration(
                        hintText: _selectedChatUser == null 
                            ? 'Selecione um usuário primeiro...'
                            : 'Escreva uma mensagem...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        enabled: _selectedChatUser != null,
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: _selectedChatUser == null ? null : _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                    tooltip: _selectedChatUser == null 
                        ? 'Selecione um usuário primeiro'
                        : 'Enviar mensagem',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    
    if (_selectedChatUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um usuário para conversar primeiro'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      _showSelectUserDialog();
      return;
    }
    
    try {
      final messagesProvider = context.read<MessagesProvider>();
      await messagesProvider.sendMessage(
        destinatarioId: _selectedChatUser!,
        texto: text,
        tipo: 'geral',
      );
      
      _chatController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensagem enviada!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSelectUserDialog() {
    final userIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Selecionar Usuário', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Para conversar, você precisa do ID do usuário.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: userIdController,
              label: 'ID do Usuário',
              hint: 'Cole o ID aqui',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (userIdController.text.trim().isNotEmpty) {
                setState(() {
                  _selectedChatUser = userIdController.text.trim();
                });
                Navigator.pop(context);
                context.read<MessagesProvider>().loadConversation(_selectedChatUser!);
              }
            },
            child: const Text('Selecionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sistema de Amizades',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Conecte-se com outros jogadores',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _showAddFriendDialog,
                    child: const Text('Adicionar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Funcionalidade de amigos em desenvolvimento.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Adicionar Amigo', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Funcionalidade em desenvolvimento. Em breve você poderá adicionar amigos!',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
