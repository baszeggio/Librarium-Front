import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/achievements_provider.dart';
import '../../widgets/custom_button.dart';
import 'edit_habit_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  Map<String, dynamic>? _progressData;
  bool _isLoadingProgress = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoadingProgress = true);
    try {
      final habitsProvider = context.read<HabitsProvider>();
      final progress = await habitsProvider.getHabitProgress(widget.habitId);
      setState(() => _progressData = progress);
    } catch (e) {
      // Ignorar erros silenciosamente
    } finally {
      setState(() => _isLoadingProgress = false);
    }
  }

  Future<void> _deleteHabit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este hábito? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final habitsProvider = context.read<HabitsProvider>();
        await habitsProvider.deleteHabit(widget.habitId);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hábito excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir hábito: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
              Color(0xFF050709),
              Color(0xFF0A0E12),
              Color(0xFF14181C),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<HabitsProvider>(
            builder: (context, habitsProvider, child) {
              final habit = habitsProvider.getHabitById(widget.habitId);

              if (habit == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Hábito não encontrado'),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Voltar',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditHabitScreen(habitId: habit.id),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteHabit(context),
                        color: Colors.red[300],
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        habit.titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))).withOpacity(0.3),
                              Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Descrição
                          if (habit.descricao.isNotEmpty) ...[
                            Text(
                              'Descrição',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              habit.descricao,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[300],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Estatísticas
                          Text(
                            'Estatísticas',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatsGrid(context, habit),
                          const SizedBox(height: 24),

                          // Ação rápida
                          Builder(
                            builder: (context) {
                              final canComplete = habitsProvider.canCompleteHabit(habit);
                              final reason = habitsProvider.getCannotCompleteReason(habit);
                              
                              return CustomButton(
                                text: habit.completado == true 
                                    ? 'Já Concluído' 
                                    : 'Marcar como Concluído',
                                onPressed: canComplete ? () async {
                                  await habitsProvider.completeHabit(habit.id);
                                  // Verificar e recarregar conquistas
                                  try {
                                    await context.read<AchievementsProvider>().verifyAchievements();
                                  } catch (e) {
                                    print('Erro ao verificar conquistas: $e');
                                  }
                                  _loadProgress();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Hábito concluído! +XP ganho!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } : null,
                                width: double.infinity,
                                backgroundColor: habit.completado == true 
                                    ? Colors.grey 
                                    : Theme.of(context).colorScheme.primary,
                              );
                            },
                          ),
                          if (habit.completado == true) ...[
                            const SizedBox(height: 8),
                            Text(
                              habitsProvider.getCannotCompleteReason(habit) ?? 'Hábito já concluído',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[400],
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Histórico de Progresso
                          Text(
                            'Histórico de Progresso',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_isLoadingProgress)
                            const Center(child: CircularProgressIndicator())
                          else if (_progressData != null && _progressData!['progressos'] != null)
                            _buildProgressHistory(_progressData!['progressos'])
                          else
                            Text(
                              'Nenhum progresso registrado ainda',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Habit habit) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _buildStatCard(
          context,
          'Sequência Atual',
          '${habit.sequenciaAtual}',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          context,
          'Maior Sequência',
          '${habit.maiorSequencia}',
          Icons.emoji_events,
          Colors.amber,
        ),
        _buildStatCard(
          context,
          'Total Concluído',
          '${habit.totalConclusoes}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          context,
          'Taxa de Sucesso',
          '${(habit.taxaConclusao * 100).toStringAsFixed(0)}%',
          Icons.trending_up,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHistory(List<dynamic> progressos) {
    if (progressos.isEmpty) {
      return Text(
        'Nenhum progresso registrado ainda',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[400],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: progressos.length > 10 ? 10 : progressos.length,
      itemBuilder: (context, index) {
        final progresso = progressos[index];
        final data = progresso['data'] != null 
            ? DateTime.parse(progresso['data'])
            : null;
        final status = progresso['status'] ?? 'concluido';
        final xp = progresso['experienciaGanha'] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: status == 'concluido' 
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                status == 'concluido' ? Icons.check_circle : Icons.cancel,
                color: status == 'concluido' ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data != null 
                          ? '${data.day}/${data.month}/${data.year}'
                          : 'Data não disponível',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (xp > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+$xp XP',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green[300],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                status == 'concluido' ? 'Concluído' : 'Perdido',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status == 'concluido' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

