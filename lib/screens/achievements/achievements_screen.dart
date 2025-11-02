import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/achievements_provider.dart';
import '../../widgets/achievement_badge.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementsProvider>().loadAchievements();
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
          child: Consumer<AchievementsProvider>(
            builder: (context, achievementsProvider, child) {
              if (achievementsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (achievementsProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar conquistas',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievementsProvider.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          achievementsProvider.loadAchievements();
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              return _buildAchievementsList(achievementsProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsList(AchievementsProvider achievementsProvider) {
    final achievements = achievementsProvider.achievements;
    final unlockedAchievements = achievementsProvider.unlockedAchievements;
    final lockedAchievements = achievementsProvider.lockedAchievements;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child:               Row(
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
                'Conquistas',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  await achievementsProvider.verifyAchievements();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verificando conquistas...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome),
                color: Colors.white,
                tooltip: 'Verificar Conquistas',
              ),
              IconButton(
                onPressed: () {
                  achievementsProvider.loadAchievements();
                },
                icon: const Icon(Icons.refresh),
                color: Colors.white,
              ),
            ],
          ),
        ),

        // Estatísticas
        _buildStatsSection(achievementsProvider),

        const SizedBox(height: 24),

        // Conquistas Personalizadas
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
              Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Conquistas Personalizadas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => _showCreateCustomAchievementDialog(context),
                child: const Text('Criar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Lista de conquistas
        Expanded(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[400],
                  tabs: [
                    Tab(
                      text: 'Desbloqueadas (${unlockedAchievements.length})',
                    ),
                    Tab(
                      text: 'Bloqueadas (${lockedAchievements.length})',
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAchievementsListContent(unlockedAchievements, true),
                      _buildAchievementsListContent(lockedAchievements, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCreateCustomAchievementDialog(BuildContext context) {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    String raridade = 'comum';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text('Nova Conquista', style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Raridade: ', style: TextStyle(color: Colors.white70)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: raridade,
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: const [
                          DropdownMenuItem(value: 'comum', child: Text('Comum', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'raro', child: Text('Raro', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'epico', child: Text('Épico', style: TextStyle(color: Colors.white))),
                          DropdownMenuItem(value: 'lendario', child: Text('Lendário', style: TextStyle(color: Colors.white))),
                        ],
                        onChanged: (v) => setState(() => raridade = v ?? 'comum'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (tituloController.text.trim().isEmpty) return;
                try {
                  await context.read<AchievementsProvider>().createCustomAchievement(
                    titulo: tituloController.text.trim(),
                    descricao: descricaoController.text.trim(),
                    raridade: raridade,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conquista personalizada criada!'),
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
  }

  Widget _buildStatsSection(AchievementsProvider achievementsProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
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
              _buildStatItem(
                'Total',
                '${achievementsProvider.totalAchievements}',
                Icons.emoji_events,
              ),
              _buildStatItem(
                'Desbloqueadas',
                '${achievementsProvider.unlockedCount}',
                Icons.check_circle,
              ),
              _buildStatItem(
                'Progresso',
                '${(achievementsProvider.completionPercentage * 100).toInt()}%',
                Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: achievementsProvider.completionPercentage,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

  Widget _buildAchievementsListContent(List achievements, bool isUnlocked) {
    if (achievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isUnlocked ? Icons.emoji_events : Icons.lock,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isUnlocked 
                    ? 'Nenhuma conquista desbloqueada'
                    : 'Nenhuma conquista bloqueada',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isUnlocked 
                    ? 'Complete hábitos para desbloquear conquistas!'
                    : 'Continue sua jornada para desbloquear mais conquistas!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AchievementBadge(
            achievement: achievement,
          ),
        );
      },
    );
  }
}
