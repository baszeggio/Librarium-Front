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

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isTopThree
                                          ? Border.all(
                                              color: _getRankColor(position),
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
                                              color: _getRankColor(position),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Avatar/Ícone
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: _getRankColor(position).withOpacity(0.2),
                                          child: Icon(
                                            Icons.person,
                                            color: _getRankColor(position),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Informações
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                player['nomeUsuario'] ?? 'Jogador',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
        color: Colors.grey[900],
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
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

