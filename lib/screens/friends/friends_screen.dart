import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/friends_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../services/api_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amizades',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showSearchDialog,
                      icon: const Icon(Icons.search),
                      color: Colors.white,
                      tooltip: 'Buscar usuários',
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(text: 'Amigos', icon: Icon(Icons.people)),
                  Tab(
                    text: 'Pendentes',
                    icon: Icon(Icons.person_add),
                  ),
                  Tab(text: 'Enviadas', icon: Icon(Icons.send)),
                ],
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFriendsTab(),
                    _buildPendingRequestsTab(),
                    _buildSentRequestsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer<FriendsProvider>(
      builder: (context, friendsProvider, child) {
        if (friendsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (friendsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Erro ao carregar amigos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  friendsProvider.error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Tentar Novamente',
                  onPressed: () => friendsProvider.loadFriends(),
                ),
              ],
            ),
          );
        }

        final friends = friendsProvider.friends;

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Você ainda não tem amigos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Busque por usuários e adicione amigos!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Buscar Usuários',
                  onPressed: _showSearchDialog,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => friendsProvider.loadFriends(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return _buildFriendCard(friend);
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          AvatarWidget(
            avatar: null,
            size: 50,
            fotoPerfilUrl: friend.fotoPerfil,
          ),
          const SizedBox(width: 16),
          
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.nomeUsuario,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${friend.titulo} • Nível ${friend.nivel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // Ações
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'message') {
                // Navegar para chat com o amigo
                context.push('/chat/${friend.id}');
              } else if (value == 'battle') {
                _showCreateBattleDialog(friend.id, friend.nomeUsuario);
              } else if (value == 'challenge') {
                _showCreateChallengeDialog(friend.id, friend.nomeUsuario);
              } else if (value == 'remove') {
                _showRemoveFriendDialog(friend.amizadeId, friend.nomeUsuario);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'message',
                child: Row(
                  children: [
                    Icon(Icons.message, size: 18),
                    SizedBox(width: 8),
                    Text('Enviar Mensagem'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'battle',
                child: Row(
                  children: [
                    Icon(Icons.sports_mma, size: 18),
                    SizedBox(width: 8),
                    Text('Desafiar para Batalha'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'challenge',
                child: Row(
                  children: [
                    Icon(Icons.flag, size: 18),
                    SizedBox(width: 8),
                    Text('Enviar Desafio'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.person_remove, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remover Amigo', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    return Consumer<FriendsProvider>(
      builder: (context, friendsProvider, child) {
        if (friendsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = friendsProvider.pendingRequests;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma solicitação pendente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => friendsProvider.loadPendingRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildFriendRequestCard(request, isPending: true);
            },
          ),
        );
      },
    );
  }

  Widget _buildSentRequestsTab() {
    return Consumer<FriendsProvider>(
      builder: (context, friendsProvider, child) {
        if (friendsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = friendsProvider.sentRequests;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma solicitação enviada',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => friendsProvider.loadSentRequests(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildFriendRequestCard(request, isPending: false);
            },
          ),
        );
      },
    );
  }

  Widget _buildFriendRequestCard(FriendRequest request, {required bool isPending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatar: null,
            size: 50,
            fotoPerfilUrl: request.fotoPerfil,
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.nomeUsuario,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nível ${request.nivel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          if (isPending)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _acceptRequest(request.id),
                  tooltip: 'Aceitar',
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _rejectRequest(request.id),
                  tooltip: 'Rejeitar',
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aguardando...',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();
    bool isSearching = false;
    List<dynamic> searchResults = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: const Text(
                'Buscar Usuários',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Nome de usuário ou email',
                        labelStyle: TextStyle(color: Colors.grey),
                        hintText: 'Digite para buscar...',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (value) async {
                        if (value.trim().isEmpty) return;
                        setState(() => isSearching = true);
                        try {
                          final results = await ApiService.searchUsers(value.trim());
                          setState(() {
                            searchResults = results;
                            isSearching = false;
                          });
                        } catch (e) {
                          setState(() => isSearching = false);
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
                    ),
                    if (isSearching)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    if (searchResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final user = searchResults[index];
                            return _buildSearchResultCard(user, setState);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSearchResultCard(dynamic user, StateSetter setState) {
    final bool saoAmigos = user['saoAmigos'] ?? false;
    final bool solicitacaoPendente = user['solicitacaoPendente'] ?? false;
    final String? fotoPerfil = user['fotoPerfil'] as String?;
    final avatar = user['avatar'] as Map<String, dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatar: null,
            size: 40,
            fotoPerfilUrl: fotoPerfil,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['nomeUsuario'] ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nível ${user['nivel'] ?? 1} • ${user['titulo'] ?? 'Aspirante'}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          if (saoAmigos)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Amigo',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            )
          else if (solicitacaoPendente)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Pendente',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.person_add, size: 20),
              color: Colors.blue,
              onPressed: () async {
                try {
                  await context.read<FriendsProvider>().sendFriendRequest(user['_id'] ?? user['id']);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitação de amizade enviada!'),
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
              tooltip: 'Enviar solicitação',
            ),
        ],
      ),
    );
  }

  Future<void> _acceptRequest(String amizadeId) async {
    try {
      await context.read<FriendsProvider>().acceptFriendRequest(amizadeId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação aceita!'),
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
  }

  Future<void> _rejectRequest(String amizadeId) async {
    try {
      await context.read<FriendsProvider>().rejectFriendRequest(amizadeId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitação rejeitada'),
            backgroundColor: Colors.orange,
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
  }

  void _showRemoveFriendDialog(String amizadeId, String nomeUsuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Remover Amigo',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja remover $nomeUsuario da sua lista de amigos?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<FriendsProvider>().removeFriend(amizadeId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Amigo removido'),
                      backgroundColor: Colors.orange,
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _showCreateBattleDialog(String adversarioId, String adversarioNome) {
    // Implementar diálogo de criação de batalha
    // Pode reutilizar código do multiplayer_screen.dart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Criar batalha com $adversarioNome'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showCreateChallengeDialog(String adversarioId, String adversarioNome) {
    // Implementar diálogo de criação de desafio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Criar desafio para $adversarioNome'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

