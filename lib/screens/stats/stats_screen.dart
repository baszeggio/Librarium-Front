import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
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
              Color(0xFF0D1117),
              Color(0xFF161B22),
              Color(0xFF21262D),
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

              // Mesmo com erro, exibir conteúdo com fallback mock
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
    // Usar apenas dados reais do provider
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
          // Header
          Container(
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
                // Botão de voltar mais visível
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
                // Botão de refresh
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
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
          ),

          const SizedBox(height: 24),

          // Cards de estatísticas principais
          _buildMainStatsCards(stats),

          const SizedBox(height: 24),

          // Gráfico semanal
          _buildWeeklyChart(stats),

          const SizedBox(height: 24),

          // Estatísticas por categoria
          _buildCategoryStats(stats),

          const SizedBox(height: 24),

          // Estatísticas de sequência
          _buildStreakStats(stats),
        ],
      ),
    );
  }

  Widget _buildMainStatsCards(Stats stats) {
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
                title: 'Sequência Atual',
                value: '${stats.currentStreak}',
                icon: Icons.local_fire_department,
                color: Colors.orange,
                subtitle: 'dias consecutivos',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Maior Sequência',
                value: '${stats.longestStreak}',
                icon: Icons.whatshot,
                color: Colors.red,
                subtitle: 'dias consecutivos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
      ],
    );
  }

  Widget _buildWeeklyChart(Stats stats) {
    return Container(
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
          Text(
            'Atividade Semanal',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Gráfico simplificado sem FL Chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gráfico em Desenvolvimento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Em breve você verá seus dados aqui!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildStreakStats(Stats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sequências',
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStreakItem(
                    'Atual',
                    '${stats.currentStreak}',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                  _buildStreakItem(
                    'Maior',
                    '${stats.longestStreak}',
                    Icons.whatshot,
                    Colors.red,
                  ),
                  _buildStreakItem(
                    'Total',
                    '${stats.totalHabits}',
                    Icons.checklist,
                    Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
