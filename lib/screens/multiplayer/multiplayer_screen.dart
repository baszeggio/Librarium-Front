import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../services/api_service.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  bool _isLoadingBattles = false;
  String? _battlesError;
  List<dynamic> _battles = const [];
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _friends = [
    {'nome': 'Artemis', 'status': 'online'},
    {'nome': 'Theron', 'status': 'offline'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBattles();
    });
  }

  Future<void> _loadBattles() async {
    setState(() {
      _isLoadingBattles = true;
      _battlesError = null;
    });
    try {
      final battles = await ApiService.getBattles();
      setState(() {
        _battles = battles;
      });
    } catch (e) {
      setState(() {
        _battlesError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBattles = false;
        });
      }
    }
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
                    onPressed: _loadBattles,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Atualizar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoadingBattles) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_battlesError != null) ...[
                Text(
                  'Erro ao carregar batalhas',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              Text(
                  _battlesError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
                ),
              ] else if (_battles.isEmpty) ...[
                Text(
                  'Nenhuma batalha encontrada.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _battles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final b = _battles[index] as Map<String, dynamic>;
                    final String opponent = (b['oponente'] ?? b['opponent'] ?? 'Desconhecido').toString();
                    final String status = (b['status'] ?? 'indefinido').toString();
                    final String result = (b['resultado'] ?? 'n/a').toString();
                    final String startedAt = (b['inicio'] ?? b['startedAt'] ?? '').toString();
                    final String finishedAt = (b['fim'] ?? b['finishedAt'] ?? '').toString();
                    final rewards = b['recompensas'] ?? b['rewards'];
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
                            status == 'concluida' || status == 'finished' ? Icons.emoji_events : Icons.sports_mma,
                            color: Colors.red[300],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vs. $opponent',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    _buildTag('Status: $status'),
                                    if (result.isNotEmpty) _buildTag('Resultado: $result'),
                                    if (startedAt.isNotEmpty) _buildTag('Início: $startedAt'),
                                    if (finishedAt.isNotEmpty) _buildTag('Fim: $finishedAt'),
                                    if (rewards != null) _buildTag('Recompensas: ${rewards.toString()}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Criar Batalha',
                      onPressed: _showCreateBattleDialog,
                      backgroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Atualizar',
                      onPressed: _loadBattles,
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

  void _showCreateBattleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Criar Batalha',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Funcionalidade em desenvolvimento. Em breve você poderá criar batalhas PvP!',
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

  void _showBattlesList() {
    _loadBattles();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Ranking Global',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Funcionalidade em desenvolvimento. Em breve você poderá ver o ranking global!',
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
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          'Sem mensagens ainda. Diga oi!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final m = _messages[index];
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
                                        TextSpan(text: '${m['autor']}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: m['texto'] ?? ''),
                                      ],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Escreva uma mensagem...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'autor': 'Você', 'texto': text});
      _chatController.clear();
    });
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
              if (_friends.isEmpty)
                Text(
                  'Você ainda não tem amigos.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _friends.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final f = _friends[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_circle, color: f['status'] == 'online' ? Colors.green : Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f['nome'] ?? 'Jogador',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            f['status'] ?? '',
                            style: TextStyle(color: f['status'] == 'online' ? Colors.green : Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Adicionar Amigo', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome do jogador',
            labelStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _friends.add({'nome': name, 'status': 'offline'});
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
