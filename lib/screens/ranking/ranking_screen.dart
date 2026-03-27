import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<dynamic> _ranking = [];
  Map<String, dynamic>? _userRanking;
  Map<String, dynamic>? _stats;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRanking();
    _loadStats();
  }

  Future<void> _loadRanking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getMultiplayerRanking();
      final rankingData = response['ranking'];
      final usuarioAtual = response['usuarioAtual'];
      
      setState(() {
        _ranking = (rankingData is List) ? rankingData : [];
        if (usuarioAtual is Map) {
          _userRanking = Map<String, dynamic>.from(usuarioAtual);
        } else {
          _userRanking = null;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ApiService.getMultiplayerStats();
      setState(() {
        _stats = stats['estatisticas'];
      });
    } catch (e) {
      // Ignorar erros silenciosamente
    }
  }

  String _getRankIcon(int position) {
    if (position == 1) return '🥇';
    if (position == 2) return '🥈';
    if (position == 3) return '🥉';
    return '$position';
  }

  Color _getRankColor(int position) {
    if (position == 1) return Colors.amber;
    if (position == 2) return Colors.grey[400]!;
    if (position == 3) return Colors.brown[400]!;
    return Colors.grey[600]!;
  }

  /// Retorna o widget da foto do perfil se houver, senão um ícone padrão.
  Widget _buildProfilePhoto(dynamic player, double radius, Color fallbackColor) {
    final fotoPerfilUrl = player['fotoPerfil'] as String?;
    if (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty) {
      // Construir URL completa - pode vir já completa ou apenas o path
      String fotoUrl = fotoPerfilUrl;
      if (!fotoPerfilUrl.startsWith('http://') && !fotoPerfilUrl.startsWith('https://')) {
        // Se não começar com http, adicionar o baseUrl (removendo /api)
        final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
        fotoUrl = '$baseUrl$fotoPerfilUrl';
      }
      
      return CircleAvatar(
        radius: radius,
        backgroundColor: fallbackColor.withOpacity(0.1),
        child: ClipOval(
          child: Image.network(
            // Adicionar query parameter para cache busting
            '$fotoUrl?t=${DateTime.now().millisecondsSinceEpoch}',
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Se erro ao carregar, mostrar ícone padrão
              return Icon(Icons.person, color: fallbackColor, size: radius);
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: radius * 2,
                height: radius * 2,
                color: Colors.grey[800],
                child: Center(
                  child: SizedBox(
                    width: radius,
                    height: radius,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: fallbackColor.withOpacity(0.2),
        child: Icon(Icons.person, color: fallbackColor, size: radius),
      );
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
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ranking Global',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadRanking,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),

              // Estatísticas do usuário
              if (_stats != null) _buildUserStats(),

              // Posição do usuário
              if (_userRanking != null) _buildUserPosition(),

              // Lista de ranking
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Erro ao carregar ranking',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(_error!),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _loadRanking,
                                  child: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          )
                        : _ranking.isEmpty
                            ? Center(
                                child: Text(
                                  'Nenhum jogador no ranking ainda',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _ranking.length,
                                itemBuilder: (context, index) {
                                  final player = _ranking[index];
                                  final position = (player['posicao'] is int) 
                                      ? player['posicao'] as int 
                                      : (index + 1);
                                  final isTopThree = position <= 3;
                                  final rankColor = _getRankColor(position);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isTopThree
                                          ? Border.all(
                                              color: rankColor,
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // Posição
                                        Container(
                                          width: 50,
                                          alignment: Alignment.center,
                                          child: Text(
                                            _getRankIcon(position),
                                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: rankColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Foto de perfil ou ícone padrão
                                        _buildProfilePhoto(player, 24, rankColor),
                                        const SizedBox(width: 16),
                                        // Informações
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${player['nomeUsuario'] ?? 'Jogador'}${player['_id'] != null ? ' #${player['_id'].toString().length > 8 ? player['_id'].toString().substring(0, 8) : player['_id'].toString()}' : player['id'] != null ? ' #${player['id'].toString().length > 8 ? player['id'].toString().substring(0, 8) : player['id'].toString()}' : ''}',
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.star, size: 16, color: Colors.amber),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Nível ${player['nivel'] ?? 0}',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(Icons.trending_up, size: 16, color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${player['experiencia'] ?? 0} XP',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats() {
    if (_stats == null) return const SizedBox.shrink();

    final battles = _stats!['batalhas'] ?? {};

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suas Estatísticas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Batalhas', '${battles['total'] ?? 0}', Icons.sports_mma),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Vitórias', '${battles['vencidas'] ?? 0}', Icons.emoji_events),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard('Taxa', '${battles['taxaVitoria'] ?? 0}%', Icons.trending_up),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserPosition() {
    final fotoPerfilUrl = _userRanking?['fotoPerfil'] as String?;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.2),
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryColor,
        ),
      ),
      child: Row(
        children: [
          // Se houver fotoPerfil, mostra ela
          if (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty) ...[
            Builder(
              builder: (context) {
                // Construir URL completa - pode vir já completa ou apenas o path
                String fotoUrl = fotoPerfilUrl;
                if (!fotoPerfilUrl.startsWith('http://') && !fotoPerfilUrl.startsWith('https://')) {
                  // Se não começar com http, adicionar o baseUrl (removendo /api)
                  final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
                  fotoUrl = '$baseUrl$fotoPerfilUrl';
                }
                
                return CircleAvatar(
                  radius: 32,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  child: ClipOval(
                    child: Image.network(
                      // Adicionar query parameter para cache busting
                      '$fotoUrl?t=${DateTime.now().millisecondsSinceEpoch}',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Se erro ao carregar, mostrar ícone padrão
                        return Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 32,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 64,
                          height: 64,
                          color: Colors.grey[800],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ] else
            Icon(
              Icons.person,
              color: primaryColor,
              size: 32,
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sua Posição',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  '#${_userRanking!['posicao'] ?? '?'}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_userRanking!['_id'] != null || _userRanking!['id'] != null) ...[
                  const SizedBox(height: 4),
                  Builder(
                    builder: (context) {
                      final id = (_userRanking!['_id'] ?? _userRanking!['id'])?.toString() ?? '';
                      final displayId = id.length > 8 ? id.substring(0, 8) : id;
                      return Text(
                        'ID: $displayId',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontFamily: 'monospace',
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Nível ${_userRanking!['nivel'] ?? 0}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              Text(
                '${_userRanking!['experiencia'] ?? 0} XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
