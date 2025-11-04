import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/stats_card.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().loadStats();
    });
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
          child: Consumer<StatsProvider>(
            builder: (context, statsProvider, child) {
              if (statsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return _buildStatsContent(statsProvider);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            context.go('/dashboard');
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: 'Voltar ao Dashboard',
      ),
    );
  }

  Widget _buildStatsContent(StatsProvider statsProvider) {
    if (statsProvider.stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Carregando estatísticas...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
            ),
          ],
        ),
      );
    }

    final Stats stats = statsProvider.stats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(statsProvider),
          const SizedBox(height: 24),
          _buildProminentStreakCards(stats),
          const SizedBox(height: 24),
          _buildMainStatsCards(stats),
          const SizedBox(height: 24),
          _buildCategoryStats(stats),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(StatsProvider statsProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/dashboard');
                }
              },
              icon: const Icon(Icons.arrow_back),
              color: Colors.white,
              tooltip: 'Voltar',
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Estatísticas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF14181C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                statsProvider.loadStats();
              },
              icon: const Icon(Icons.refresh),
              color: Colors.white,
              tooltip: 'Atualizar',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProminentStreakCards(Stats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sequência',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.3),
                      Colors.deepOrange.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${stats.currentStreak}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sequência Atual',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dias consecutivos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.red.shade900.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.whatshot,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${stats.longestStreak}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 42,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Maior Sequência',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'dias consecutivos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainStatsCards(Stats stats) {
    final nivel = stats.level;
    int xpNecessarioParaNivelAtual = 0;
    int xpNecessarioParaProximoNivel = 0;

    if (nivel <= 1) {
      xpNecessarioParaNivelAtual = 0;
      xpNecessarioParaProximoNivel = 100;
    } else if (nivel < 10) {
      xpNecessarioParaNivelAtual = (nivel - 1) * 100;
      xpNecessarioParaProximoNivel = nivel * 100;
    } else if (nivel < 20) {
      xpNecessarioParaNivelAtual = 900 + ((nivel - 10) * 200);
      xpNecessarioParaProximoNivel = 1000 + ((nivel - 10) * 200);
    } else if (nivel < 30) {
      xpNecessarioParaNivelAtual = 2900 + ((nivel - 20) * 300);
      xpNecessarioParaProximoNivel = 3000 + ((nivel - 20) * 300);
    } else {
      xpNecessarioParaNivelAtual = 5900 + ((nivel - 30) * 400);
      xpNecessarioParaProximoNivel = 6000 + ((nivel - 30) * 400);
    }
    final xpParaProximoNivel = xpNecessarioParaProximoNivel - xpNecessarioParaNivelAtual;
    final xpAtualNoNivel = (stats.totalXP - xpNecessarioParaNivelAtual).clamp(0, xpParaProximoNivel);
    final progressoXP = xpParaProximoNivel > 0
        ? (xpAtualNoNivel / xpParaProximoNivel).clamp(0.0, 1.0)
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo Geral',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Taxa de Conclusão',
                value: '${(stats.completionRate * 100).toInt()}%',
                icon: Icons.trending_up,
                color: Colors.green,
                subtitle: 'de todos os hábitos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Total de XP',
                value: '${stats.totalXP}',
                icon: Icons.star,
                color: Colors.purple,
                subtitle: 'pontos de experiência',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nível ${stats.level}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Nível ${stats.level + 1}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progressoXP,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$xpAtualNoNivel / $xpParaProximoNivel XP',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                  ),
                  Text(
                    '${(progressoXP * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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

  Widget _buildCategoryStats(Stats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Categoria',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...stats.categoryStats.entries.map((entry) {
          final category = entry.key;
          final count = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
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
                  Icon(
                    _getCategoryIcon(category),
                    color: _getCategoryColor(category),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getCategoryDisplayName(category),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                  Text(
                    '$count hábitos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'saude':
        return Icons.favorite;
      case 'estudo':
        return Icons.menu_book;
      case 'trabalho':
        return Icons.work;
      case 'casa':
        return Icons.home;
      case 'social':
        return Icons.people;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'saude':
        return Colors.red;
      case 'estudo':
        return Colors.blue;
      case 'trabalho':
        return Colors.orange;
      case 'casa':
        return Colors.green;
      case 'social':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'saude':
        return 'Saúde';
      case 'estudo':
        return 'Estudo';
      case 'trabalho':
        return 'Trabalho';
      case 'casa':
        return 'Casa';
      case 'social':
        return 'Social';
      default:
        return category;
    }
  }
}
