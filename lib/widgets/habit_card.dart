import 'package:flutter/material.dart';
import '../providers/habits_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onComplete;
  final bool isCompact;

  const HabitCard({
    super.key,
    required this.habit,
    this.onComplete,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícone do hábito
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getHabitIcon(habit.icone),
                  color: Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Título e descrição
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.titulo,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isCompact && habit.descricao.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.descricao,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Botão de completar
              if (onComplete != null)
                Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: onComplete,
                    icon: Icon(
                      Icons.check,
                      color: Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))),
                    ),
                    iconSize: 20,
                  ),
                ),
            ],
          ),
          
          if (!isCompact) ...[
            const SizedBox(height: 12),
            
            // Informações do hábito
            Row(
              children: [
                _buildInfoChip(
                  context,
                  _getFrequencyText(habit.frequencia),
                  Icons.schedule,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  _getDifficultyText(habit.dificuldade),
                  Icons.trending_up,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  context,
                  '${habit.sequenciaAtual} dias',
                  Icons.local_fire_department,
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Barra de progresso da sequência
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sequência Atual',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                    Text(
                      '${habit.sequenciaAtual} dias',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: habit.maiorSequencia > 0 
                      ? habit.sequenciaAtual / habit.maiorSequencia 
                      : 0,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(int.parse(habit.cor.replaceFirst('#', '0xFF'))),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getHabitIcon(String icone) {
    switch (icone.toLowerCase()) {
      case 'espada':
        return Icons.fitness_center;
      case 'livro':
        return Icons.menu_book;
      case 'coração':
        return Icons.favorite;
      case 'cerebro':
        return Icons.psychology;
      case 'trabalho':
        return Icons.work;
      case 'casa':
        return Icons.home;
      case 'dinheiro':
        return Icons.attach_money;
      case 'tempo':
        return Icons.schedule;
      default:
        return Icons.task;
    }
  }

  String _getFrequencyText(String frequencia) {
    switch (frequencia.toLowerCase()) {
      case 'diario':
        return 'Diário';
      case 'semanal':
        return 'Semanal';
      case 'mensal':
        return 'Mensal';
      default:
        return frequencia;
    }
  }

  String _getDifficultyText(String dificuldade) {
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'medio':
        return 'Médio';
      case 'dificil':
        return 'Difícil';
      case 'lendario':
        return 'Lendário';
      default:
        return dificuldade;
    }
  }
}
