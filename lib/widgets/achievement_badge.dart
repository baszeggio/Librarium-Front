import 'package:flutter/material.dart';
import '../providers/achievements_provider.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool isCompact;

  const AchievementBadge({
    super.key,
    required this.achievement,
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
          color: achievement.rarityColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: achievement.rarityColor.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone da conquista
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achievement.rarityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.center,
                child: Image.asset(
                  achievement.icone,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      _getAchievementIcon(achievement.tipo),
                      color: achievement.rarityColor,
                    );
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Informações da conquista
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.titulo,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: achievement.rarityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRarityText(achievement.raridade),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: achievement.rarityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (!isCompact) ...[
                  const SizedBox(height: 4),
                  Text(
                    achievement.descricao,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: achievement.rarityColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.recompensaXP} XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: achievement.rarityColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (achievement.dataDesbloqueio != null)
                      Text(
                        _formatDate(achievement.dataDesbloqueio!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
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
  }

  IconData _getAchievementIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'primeiro_habito':
        return Icons.play_arrow;
      case 'sequencia_7':
        return Icons.local_fire_department;
      case 'sequencia_30':
        return Icons.whatshot;
      case 'sequencia_100':
        return Icons.emoji_events;
      case 'perfeccionista':
        return Icons.star;
      case 'guerreiro':
        return Icons.fitness_center;
      case 'estudioso':
        return Icons.menu_book;
      case 'saudavel':
        return Icons.favorite;
      case 'produtivo':
        return Icons.work;
      case 'social':
        return Icons.people;
      case 'criativo':
        return Icons.palette;
      case 'organizado':
        return Icons.checklist;
      case 'disciplinado':
        return Icons.schedule;
      case 'focado':
        return Icons.center_focus_strong;
      case 'persistente':
        return Icons.trending_up;
      case 'lendario':
        return Icons.auto_awesome;
      default:
        return Icons.emoji_events;
    }
  }

  String _getRarityText(String raridade) {
    switch (raridade.toLowerCase()) {
      case 'comum':
        return 'COMUM';
      case 'raro':
        return 'RARO';
      case 'epico':
        return 'ÉPICO';
      case 'lendario':
        return 'LENDÁRIO';
      default:
        return raridade.toUpperCase();
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
