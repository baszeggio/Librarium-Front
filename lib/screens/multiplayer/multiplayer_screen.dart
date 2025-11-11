import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../providers/multiplayer_provider.dart';
import '../../providers/messages_provider.dart';
import '../../providers/friends_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/avatar_widget.dart';
import '../../services/api_service.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedChatUser;
  String? _selectedChatUserName;
  List<dynamic> _conversations = [];
  bool _loadingConversations = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MultiplayerProvider>().loadBattles();
      context.read<MultiplayerProvider>().loadChallenges();
      context.read<MessagesProvider>().loadMessages();
      context.read<FriendsProvider>().loadAll();
      _loadConversations();
    });

  }

  Future<void> _loadConversations() async {
    setState(() => _loadingConversations = true);
    try {
      final conversas = await ApiService.listarConversas();
      setState(() {
        _conversations = conversas;
        _loadingConversations = false;
      });
    } catch (e) {
      setState(() => _loadingConversations = false);
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _searchController.dispose();
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
              Color(0xFF050709),
              Color(0xFF0A0E12),
              Color(0xFF14181C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Quick Actions
              _buildQuickActions(),
              
              // Tabs
              _buildTabs(),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBattlesTab(),
                    _buildChallengesTab(),
                    _buildChatTab(),
                    _buildFriendsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              _tabController.animateTo(0); // Ir para tab de batalhas
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.sports_mma,
              label: 'Batalha Rápida',
              color: Colors.red,
              onTap: () => _createQuickBattle(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.people,
              label: 'Desafiar Amigo',
              color: Colors.blue,
              onTap: () => _showChallengeFriendDialog(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.chat_bubble_outline,
              label: 'Nova Conversa',
              color: Colors.green,
              onTap: () {
                _tabController.animateTo(2);
                _showUserSearchDialog();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickActionButton(
              icon: Icons.person_add,
              label: 'Adicionar',
              color: Colors.orange,
              onTap: () {
                _tabController.animateTo(3);
                _showUserSearchDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).colorScheme.primary,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        isScrollable: false,
        tabAlignment: TabAlignment.fill,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sports_mma, size: 16),
                const SizedBox(width: 4),
                const Flexible(
                  child: Text(
                    'Batalhas',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Consumer<MultiplayerProvider>(
                  builder: (context, provider, _) {
                    // Obter ID do usuário logado
                    final authProvider = context.read<AuthProvider>();
                    final currentUserId = authProvider.user?['_id']?.toString() ?? authProvider.user?['id']?.toString();
                    
                    // Se não houver ID do usuário, não mostrar badge
                    if (currentUserId == null) return const SizedBox.shrink();
                    
                    // Contar apenas batalhas pendentes que o usuário recebeu (não as que criou)
                    final pending = provider.battles.where((b) {
                      if (b.status == 'aguardando') {
                        final isJogador2 = b.jogador2Id == currentUserId;
                        final isJogador1 = b.jogador1Id == currentUserId;
                        return isJogador2 && !isJogador1;
                      }
                      return false;
                    }).length;
                    if (pending == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        pending > 99 ? '99+' : '$pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.group_work, size: 16),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Desafios',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 16),
                const SizedBox(width: 4),
                const Flexible(
                  child: Text(
                    'Chat',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Consumer<MessagesProvider>(
                  builder: (context, provider, _) {
                    // Contar mensagens não lidas de todas as conversas
                    int totalNaoLidas = 0;
                    for (var conversa in _conversations) {
                      totalNaoLidas += (conversa['naoLidas'] as num? ?? 0).toInt();
                    }
                    if (totalNaoLidas == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        totalNaoLidas > 99 ? '99+' : '$totalNaoLidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 4),
                const Flexible(
                  child: Text(
                    'Amigos',
                    style: TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Consumer<FriendsProvider>(
                  builder: (context, provider, _) {
                    if (provider.pendingRequestsCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        provider.pendingRequestsCount > 99 
                            ? '99+' 
                            : '${provider.pendingRequestsCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== TAB CONTENT ==========

  Widget _buildBattlesTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<MultiplayerProvider>().loadBattles();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<MultiplayerProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          'Erro ao carregar batalhas',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => provider.loadBattles(),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                // Obter ID do usuário logado
                final authProvider = context.read<AuthProvider>();
                final currentUserId = authProvider.user?['_id']?.toString() ?? authProvider.user?['id']?.toString();
                
                // Debug: imprimir informações do usuário
                print('Current User ID: $currentUserId');
                print('Total de batalhas no provider: ${provider.battles.length}');
                
                // Se não houver ID do usuário, não mostrar batalhas
                if (currentUserId == null) {
                  return Center(
                    child: Text(
                      'Erro ao carregar informações do usuário',
                      style: TextStyle(color: Colors.red[400]),
                    ),
                  );
                }
                
                // Filtrar batalhas: mostrar apenas as que o usuário recebeu (jogador2) quando status é 'aguardando'
                // Para outras batalhas, mostrar todas (em_andamento, concluida, etc)
                final battles = provider.battles.where((battle) {
                  if (battle.status == 'aguardando') {
                    // Apenas mostrar batalhas onde o usuário é jogador2 (destinatário)
                    // e NÃO é jogador1 (criador)
                    final isJogador2 = battle.jogador2Id == currentUserId;
                    final isJogador1 = battle.jogador1Id == currentUserId;
                    print('Batalha ${battle.id}: status=aguardando, isJogador2=$isJogador2 (${battle.jogador2Id} == $currentUserId), isJogador1=$isJogador1 (${battle.jogador1Id} == $currentUserId)');
                    return isJogador2 && !isJogador1;
                  }
                  // Para outras batalhas, mostrar todas onde o usuário participa
                  final participa = battle.jogador1Id == currentUserId || battle.jogador2Id == currentUserId;
                  print('Batalha ${battle.id}: status=${battle.status}, participa=$participa');
                  return participa;
                }).toList();
                
                print('Batalhas filtradas: ${battles.length}');

                if (battles.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.sports_mma, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma batalha encontrada',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Criar Primeira Batalha',
                          onPressed: () => _showCreateBattleDialog(),
                          backgroundColor: Colors.red,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: battles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final battle = battles[index];
                        return _buildBattleCard(battle);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Criar Nova Batalha',
                      onPressed: () => _showCreateBattleDialog(),
                      backgroundColor: Colors.red,
                      width: double.infinity,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleCard(dynamic battle) {
    // Obter ID do usuário logado para determinar o adversário
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.user?['_id']?.toString() ?? authProvider.user?['id']?.toString();
    
    // Determinar o adversário: se o usuário é jogador1, mostrar jogador2, e vice-versa
    final isJogador1 = battle.jogador1Id == currentUserId;
    final adversarioNome = isJogador1 ? battle.jogador2 : battle.jogador1;
    
    // Se não conseguir determinar o adversário, usar fallback
    final adversarioDisplay = adversarioNome.isNotEmpty ? adversarioNome : 'Adversário';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: battle.status == 'aguardando' 
              ? Colors.orange.withOpacity(0.5)
              : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                battle.status == 'concluida' 
                    ? Icons.emoji_events 
                    : Icons.sports_mma,
                color: battle.status == 'aguardando' 
                    ? Colors.orange 
                    : Colors.red[300],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vs. $adversarioDisplay',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildTag('${battle.status}', Colors.grey),
                        _buildTag('${battle.tipoBatalha}', Colors.blue),
                        if (battle.resultado != null)
                          _buildTag(
                            'Vencedor: ${battle.resultado?['vencedor'] ?? 'Empate'}',
                            Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (battle.status == 'aguardando') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Aceitar',
                    onPressed: () {
                      context.read<MultiplayerProvider>().acceptBattle(battle.id);
                    },
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Recusar',
                    onPressed: () {
                      // TODO: Implementar recusar batalha
                    },
                    backgroundColor: Colors.grey[800]!,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<MultiplayerProvider>().loadChallenges();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomButton(
              text: 'Criar Novo Desafio',
              onPressed: () => _showCreateChallengeDialog(),
              backgroundColor: Colors.blue,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            // Lista de desafios aqui
            Text(
              'Desafios serão exibidos aqui',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        // Header com botão de voltar se estiver em uma conversa
        if (_selectedChatUser != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _selectedChatUser = null;
                      _selectedChatUserName = null;
                    });
                    _loadConversations();
                  },
                ),
                AvatarWidget(
                  avatar: null,
                  size: 32,
                  fotoPerfilUrl: _conversations.firstWhere(
                    (c) => c['usuarioId'] == _selectedChatUser,
                    orElse: () => {'usuario': {}},
                  )['usuario']?['fotoPerfil'],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedChatUserName ?? 'Usuário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Lista de conversas ou mensagens
        Expanded(
          child: _buildConversationsList(),
        ),
        // Input de mensagem
        if (_selectedChatUser != null) _buildChatInput(),
      ],
    );
  }

  Widget _buildConversationsList() {
    if (_selectedChatUser == null) {
      // Mostrar lista de conversas
      if (_loadingConversations) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_conversations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'Nenhuma conversa ainda',
                style: TextStyle(color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              Text(
                'Inicie uma conversa com alguém!',
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Iniciar Nova Conversa',
                onPressed: () => _showUserSearchDialog(),
                backgroundColor: Colors.green,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadConversations,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _conversations.length,
          itemBuilder: (context, index) {
            final conversa = _conversations[index];
            return _buildConversationCard(conversa);
          },
        ),
      );
    }

    // Mostrar mensagens da conversa selecionada
    return Consumer<MessagesProvider>(
      builder: (context, provider, _) {
        final messages = provider.messages;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageBubble(message);
          },
        );
      },
    );
  }

  Widget _buildConversationCard(dynamic conversa) {
    final usuario = conversa['usuario'];
    final ultimaMensagem = conversa['ultimaMensagem'];
    final naoLidas = conversa['naoLidas'] ?? 0;
    final isSelected = _selectedChatUser == conversa['usuarioId'];

    return InkWell(
      onTap: () {
        setState(() {
          _selectedChatUser = conversa['usuarioId'];
          _selectedChatUserName = usuario['nomeUsuario'];
        });
        // Carregar mensagens da conversa
        context.read<MessagesProvider>().loadConversation(conversa['usuarioId']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                AvatarWidget(
                  avatar: null,
                  size: 50,
                  fotoPerfilUrl: usuario['fotoPerfil'],
                ),
                if (naoLidas > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        naoLidas > 99 ? '99+' : '$naoLidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          usuario['nomeUsuario'] ?? 'Usuário',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (ultimaMensagem != null)
                        Text(
                          _formatTime(ultimaMensagem['createdAt']),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (ultimaMensagem != null)
                    Text(
                      ultimaMensagem['texto'] ?? '',
                      style: TextStyle(
                        color: naoLidas > 0 ? Colors.white : Colors.grey[400],
                        fontSize: 14,
                        fontWeight: naoLidas > 0 ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Nenhuma mensagem',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Agora';
          }
          return '${difference.inMinutes}m';
        }
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        return '${date.day}/${date.month}';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(dynamic message) {
    final isMe = message.remetente == context.read<AuthProvider>().user?['_id'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message.remetente,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              message.texto,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController,
              decoration: InputDecoration(
                hintText: 'Escreva uma mensagem...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<FriendsProvider>().loadAll();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomButton(
              text: 'Buscar Usuários',
              onPressed: () => _showUserSearchDialog(),
              backgroundColor: Colors.blue,
              width: double.infinity,
            ),
            const SizedBox(height: 16),
            Consumer<FriendsProvider>(
              builder: (context, provider, _) {
                final List<Widget> children = [];
                
                // Mostrar solicitações pendentes primeiro (se houver)
                if (provider.pendingRequests.isNotEmpty) {
                  children.add(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitações Pendentes (${provider.pendingRequests.length})',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.pendingRequests.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index >= provider.pendingRequests.length) {
                              return const SizedBox.shrink();
                            }
                            final request = provider.pendingRequests[index];
                            return _buildPendingRequestCard(request);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }

                // Mostrar lista de amigos (se houver)
                if (provider.friends.isNotEmpty) {
                  children.add(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Seus Amigos (${provider.friends.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.friends.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (index >= provider.friends.length) {
                              return const SizedBox.shrink();
                            }
                            final friend = provider.friends[index];
                            return _buildFriendCard(friend);
                          },
                        ),
                      ],
                    ),
                  );
                }

                // Se não houver solicitações nem amigos
                if (children.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Você ainda não tem amigos',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Busque usuários para adicionar!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(FriendRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatar: null,
            size: 50,
            fotoPerfilUrl: request.fotoPerfil,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.nomeUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Quer ser seu amigo',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => _acceptFriendRequest(request.id),
                tooltip: 'Aceitar',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _rejectFriendRequest(request.id),
                tooltip: 'Recusar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _acceptFriendRequest(String requestId) async {
    try {
      final friendsProvider = context.read<FriendsProvider>();
      await friendsProvider.acceptFriendRequest(requestId);
      // O provider já recarrega automaticamente via loadAll() no acceptFriendRequest
      // Mas garantimos que a UI seja atualizada
      if (mounted) {
        setState(() {}); // Força rebuild para atualizar a lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação aceita!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aceitar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectFriendRequest(String requestId) async {
    try {
      final friendsProvider = context.read<FriendsProvider>();
      await friendsProvider.rejectFriendRequest(requestId);
      // O provider já recarrega automaticamente via loadPendingRequests() no rejectFriendRequest
      // Mas garantimos que a UI seja atualizada
      if (mounted) {
        setState(() {}); // Força rebuild para atualizar a lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação recusada'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao recusar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFriendCard(dynamic friend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatar: null,
            size: 50,
            fotoPerfilUrl: friend.fotoPerfil,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.nomeUsuario,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Nível ${friend.nivel}',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.sports_mma, color: Colors.red),
                onPressed: () => _showCreateBattleDialog(friendId: friend.id, friendName: friend.nomeUsuario),
                tooltip: 'Desafiar',
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                onPressed: () {
                  setState(() {
                    _selectedChatUser = friend.id;
                    _selectedChatUserName = friend.nomeUsuario;
                  });
                  _tabController.animateTo(2);
                },
                tooltip: 'Conversar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== DIALOGS ==========

  void _showUserSearchDialog() {
    // Criar um controller local para o dialog
    final dialogSearchController = TextEditingController();
    List<dynamic> dialogSearchResults = [];
    bool dialogIsSearching = false;
    Timer? dialogSearchDebounce;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Função para buscar dentro do dialog
            Future<void> performDialogSearch(String query) async {
              if (query.trim().isEmpty) {
                setDialogState(() {
                  dialogSearchResults = [];
                  dialogIsSearching = false;
                });
                return;
              }

              setDialogState(() => dialogIsSearching = true);

              try {
                final results = await ApiService.searchUsers(query);
                setDialogState(() {
                  dialogSearchResults = results;
                  dialogIsSearching = false;
                });
              } catch (e) {
                setDialogState(() => dialogIsSearching = false);
              }
            }

            // Listener para atualizar busca em tempo real
            dialogSearchController.addListener(() {
              if (dialogSearchDebounce?.isActive ?? false) {
                dialogSearchDebounce!.cancel();
              }
              dialogSearchDebounce = Timer(const Duration(milliseconds: 500), () {
                performDialogSearch(dialogSearchController.text);
              });
            });

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text(
                'Buscar Usuários',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: dialogSearchController,
                      decoration: InputDecoration(
                        hintText: 'Digite o nome do usuário...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      autofocus: true,
                      onChanged: (value) {
                        // A busca já é feita pelo listener, mas podemos forçar atualização
                        if (value.trim().isEmpty) {
                          setDialogState(() {
                            dialogSearchResults = [];
                            dialogIsSearching = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (dialogIsSearching)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (dialogSearchResults.isEmpty && dialogSearchController.text.trim().isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhum usuário encontrado',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else if (dialogSearchResults.isNotEmpty)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: dialogSearchResults.length,
                          itemBuilder: (context, index) {
                            final user = dialogSearchResults[index];
                            return ListTile(
                              leading: AvatarWidget(
                                avatar: null,
                                size: 40,
                                fotoPerfilUrl: user['fotoPerfil'],
                              ),
                              title: Text(
                                user['nomeUsuario'] ?? 'Sem nome',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Nível ${user['nivel'] ?? 1}',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.person_add, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                      _addFriend(user['_id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
                                    onPressed: () {
                                      setState(() {
                                        _selectedChatUser = user['_id'];
                                        _selectedChatUserName = user['nomeUsuario'];
                                      });
                                      Navigator.pop(dialogContext);
                                      _tabController.animateTo(2);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogSearchDebounce?.cancel();
                    dialogSearchController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Limpar quando o dialog fechar
      dialogSearchDebounce?.cancel();
    });
  }

  void _showCreateBattleDialog({String? friendId, String? friendName}) {
    final opponentIdController = TextEditingController(text: friendId ?? '');
    String? selectedType = 'sequencia';
    final durationController = TextEditingController(text: '60');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Row(
                children: [
                  const Icon(Icons.sports_mma, color: Colors.red),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Criar Batalha',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (friendId == null)
                    IconButton(
                      icon: const Icon(Icons.people, size: 20),
                      color: Colors.blue,
                      onPressed: () => _showSelectFriendDialog(context, setState, opponentIdController),
                      tooltip: 'Escolher amigo',
                    ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (friendId != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Desafiando: $friendName',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          CustomTextField(
                            controller: opponentIdController,
                            label: 'ID do Adversário',
                            hint: 'Digite o ID ou escolha um amigo',
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => _showSelectFriendDialog(context, setState, opponentIdController),
                            icon: const Icon(Icons.people, size: 18),
                            label: const Text('Escolher dos Amigos'),
                            style: TextButton.styleFrom(foregroundColor: Colors.blue),
                          ),
                        ],
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
                        DropdownMenuItem(value: 'nivel_rapido', child: Text('Nível Rápido')),
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
                        const SnackBar(content: Text('Digite o ID do adversário ou escolha um amigo')),
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
                        context.read<MultiplayerProvider>().loadBattles();
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

  void _showSelectFriendDialog(BuildContext context, StateSetter setState, TextEditingController controller) {
    final friendsProvider = context.read<FriendsProvider>();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'Escolher Amigo',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: friendsProvider.friends.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Você não tem amigos ainda.\nAdicione amigos primeiro!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: friendsProvider.friends.length,
                    itemBuilder: (context, index) {
                      final friend = friendsProvider.friends[index];
                      return ListTile(
                        leading: AvatarWidget(
                          avatar: null,
                          size: 40,
                          fotoPerfilUrl: friend.fotoPerfil,
                        ),
                        title: Text(
                          friend.nomeUsuario,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Nível ${friend.nivel}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        onTap: () {
                          setState(() {
                            controller.text = friend.id;
                          });
                          Navigator.pop(dialogContext);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateChallengeDialog() {
    // Similar ao create battle, mas para desafios
    _showCreateBattleDialog();
  }

  void _showChallengeFriendDialog() {
    final friendsProvider = context.read<FriendsProvider>();
    
    if (friendsProvider.friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não tem amigos ainda. Adicione amigos primeiro!'),
          backgroundColor: Colors.orange,
        ),
      );
      _tabController.animateTo(3);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'Desafiar Amigo',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: friendsProvider.friends.length,
              itemBuilder: (context, index) {
                final friend = friendsProvider.friends[index];
                return ListTile(
                  leading: AvatarWidget(
                    avatar: null,
                    size: 40,
                    fotoPerfilUrl: friend.fotoPerfil,
                  ),
                  title: Text(
                    friend.nomeUsuario,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Nível ${friend.nivel}',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.sports_mma, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _showCreateBattleDialog(friendId: friend.id, friendName: friend.nomeUsuario);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _createQuickBattle() {
    // Criar batalha com configurações padrão
    final friendsProvider = context.read<FriendsProvider>();
    if (friendsProvider.friends.isNotEmpty) {
      _showChallengeFriendDialog();
    } else {
      _showCreateBattleDialog();
    }
  }

  Future<void> _addFriend(String userId) async {
    try {
      await context.read<FriendsProvider>().sendFriendRequest(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação de amizade enviada!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _selectedChatUser == null) return;
    
    try {
      await context.read<MessagesProvider>().sendMessage(
        destinatarioId: _selectedChatUser!,
        texto: text,
        tipo: 'privada',
      );
      
      _chatController.clear();
      
      // Recarregar conversas para atualizar última mensagem
      _loadConversations();
      
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

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

