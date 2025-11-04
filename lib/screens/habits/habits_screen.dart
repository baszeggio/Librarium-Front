import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/habits_provider.dart';
import '../../providers/achievements_provider.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/custom_button.dart';
import 'create_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitsProvider>().loadHabits();
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
          child: Consumer<HabitsProvider>(
            builder: (context, habitsProvider, child) {
              if (habitsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (habitsProvider.error != null) {
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
                        'Erro ao carregar hábitos',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        habitsProvider.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Tentar Novamente',
                        onPressed: () {
                          habitsProvider.loadHabits();
                        },
                      ),
                    ],
                  ),
                );
              }

              return _buildHabitsList(habitsProvider);
            },
          ),
        ),
      ),
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateHabitScreen(),
              ),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(Icons.add),
          label: FittedBox(
            fit: BoxFit.scaleDown,
            child: const Text('Novo Hábito'),
          ),
          extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildHabitsList(HabitsProvider habitsProvider) {
    final habits = habitsProvider.habits;

    return Column(
      children: [
        // Header
        Padding(
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
                'Meus Hábitos',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  habitsProvider.loadHabits();
                },
                icon: const Icon(Icons.refresh),
                color: Colors.white,
              ),
            ],
          ),
        ),

        // Lista de hábitos
        Expanded(
          child: habits.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final bool isCompleted = habit.completado ?? false;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key(habit.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Excluir Hábito'),
                                  content: const Text('Tem certeza que deseja excluir este hábito?'),
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
                              ) ??
                              false;
                        },
                        onDismissed: (direction) async {
                          try {
                            await habitsProvider.deleteHabit(habit.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Hábito "${habit.titulo}" deletado com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao deletar hábito: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: HabitCard(
                          habit: habit,
                          onComplete: isCompleted
                              ? null
                              : () async {
                                  await habitsProvider.completeHabit(habit.id);
                                  // Verificar e recarregar conquistas
                                  try {
                                    await context.read<AchievementsProvider>().verifyAchievements();
                                  } catch (e) {
                                    print('Erro ao verificar conquistas: $e');
                                  }
                                },
                          onDelete: () {
                            _showDeleteDialog(context, habit.id, habit.titulo, habitsProvider);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add_task,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum hábito criado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie seu primeiro hábito para começar sua jornada épica!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Criar Primeiro Hábito',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateHabitScreen(),
                  ),
                );
              },
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String habitId, String habitTitle, HabitsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Deletar Hábito',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja deletar o hábito "$habitTitle"?\n\nEsta ação não pode ser desfeita.',
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
                await provider.deleteHabit(habitId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hábito "$habitTitle" deletado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao deletar hábito: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}
