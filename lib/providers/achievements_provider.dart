import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Achievement {
  final String id;
  final String tipo;
  final String titulo;
  final String descricao;
  final String raridade;
  final int recompensaXP;
  final bool desbloqueada;
  final DateTime? dataDesbloqueio;
  final String icone;

  Achievement({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.raridade,
    required this.recompensaXP,
    required this.desbloqueada,
    this.dataDesbloqueio,
    required this.icone,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      raridade: json['raridade'] ?? 'comum',
      recompensaXP: json['recompensaXP'] ?? 0,
      desbloqueada: json['desbloqueada'] ?? false,
      dataDesbloqueio: json['dataDesbloqueio'] != null 
          ? DateTime.parse(json['dataDesbloqueio']) 
          : null,
      icone: json['icone'] ?? 'trophy',
    );
  }

  Color get rarityColor {
    switch (raridade.toLowerCase()) {
      case 'comum':
        return Colors.grey;
      case 'raro':
        return Colors.blue;
      case 'epico':
        return Colors.purple;
      case 'lendario':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get rarityIcon {
    switch (raridade.toLowerCase()) {
      case 'comum':
        return 'assets/icons/common_trophy.png';
      case 'raro':
        return 'assets/icons/rare_trophy.png';
      case 'epico':
        return 'assets/icons/epic_trophy.png';
      case 'lendario':
        return 'assets/icons/legendary_trophy.png';
      default:
        return 'assets/icons/common_trophy.png';
    }
  }
}

class AchievementsProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Achievement> get unlockedAchievements => 
      _achievements.where((achievement) => achievement.desbloqueada).toList();
  
  List<Achievement> get lockedAchievements => 
      _achievements.where((achievement) => !achievement.desbloqueada).toList();

  int get totalAchievements => _achievements.length;
  int get unlockedCount => unlockedAchievements.length;
  double get completionPercentage => 
      totalAchievements > 0 ? (unlockedCount / totalAchievements) : 0.0;

  Future<void> loadAchievements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Usar conquistas mockadas com diferentes raridades
      _achievements = _getMockAchievements();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adiciona uma conquista personalizada localmente
  void addCustomAchievement({
    required String titulo,
    required String descricao,
    required String raridade,
  }) {
    final String id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final String icone = _mapRarityToAwardAsset(raridade);
    final Achievement custom = Achievement(
      id: id,
      tipo: 'custom',
      titulo: titulo,
      descricao: descricao,
      raridade: raridade.toLowerCase(),
      recompensaXP: _xpByRarity(raridade),
      desbloqueada: true,
      dataDesbloqueio: DateTime.now(),
      icone: icone,
    );
    _achievements.insert(0, custom);
    notifyListeners();
  }

  String _mapRarityToAwardAsset(String raridade) {
    switch (raridade.toLowerCase()) {
      case 'comum':
        return 'assets/green_award.png';
      case 'raro':
        return 'assets/red_award.png';
      case 'epico':
        return 'assets/gold_award.png';
      case 'lendario':
        return 'assets/king_award.png';
      default:
        return 'assets/green_award.png';
    }
  }

  int _xpByRarity(String raridade) {
    switch (raridade.toLowerCase()) {
      case 'comum':
        return 50;
      case 'raro':
        return 200;
      case 'epico':
        return 500;
      case 'lendario':
        return 1000;
      default:
        return 50;
    }
  }

  List<Achievement> _getMockAchievements() {
    return [
      // Conquistas Fáceis (Verde)
      Achievement(
        id: '1',
        tipo: 'primeiro_habito',
        titulo: 'The First Step',
        descricao: 'Crie seu primeiro hábito na jornada',
        raridade: 'comum',
        recompensaXP: 50,
        desbloqueada: true,
        dataDesbloqueio: DateTime.now().subtract(const Duration(days: 1)),
        icone: 'assets/green_award.png',
      ),
      Achievement(
        id: '2',
        tipo: 'sequencia_3',
        titulo: 'Rising Soul',
        descricao: 'Mantenha uma sequência de 3 dias',
        raridade: 'comum',
        recompensaXP: 75,
        desbloqueada: true,
        dataDesbloqueio: DateTime.now().subtract(const Duration(days: 2)),
        icone: 'assets/green_award.png',
      ),
      Achievement(
        id: '3',
        tipo: 'categoria_saude',
        titulo: 'Vitality',
        descricao: 'Complete 5 hábitos de saúde',
        raridade: 'comum',
        recompensaXP: 100,
        desbloqueada: false,
        icone: 'assets/green_award.png',
      ),

      // Conquistas Médias (Vermelho)
      Achievement(
        id: '4',
        tipo: 'sequencia_7',
        titulo: 'Golden Week',
        descricao: 'Mantenha uma sequência de 7 dias',
        raridade: 'raro',
        recompensaXP: 200,
        desbloqueada: true,
        dataDesbloqueio: DateTime.now().subtract(const Duration(days: 3)),
        icone: 'assets/red_award.png',
      ),
      Achievement(
        id: '5',
        tipo: 'perfeccionista',
        titulo: 'Pure Nail',
        descricao: 'Complete 10 hábitos com 100% de eficiência',
        raridade: 'raro',
        recompensaXP: 300,
        desbloqueada: false,
        icone: 'assets/red_award.png',
      ),
      Achievement(
        id: '6',
        tipo: 'guerreiro',
        titulo: 'Warrior\'s Path',
        descricao: 'Complete 20 hábitos difíceis',
        raridade: 'raro',
        recompensaXP: 400,
        desbloqueada: false,
        icone: 'assets/red_award.png',
      ),

      // Conquistas Difíceis (Dourado)
      Achievement(
        id: '7',
        tipo: 'sequencia_30',
        titulo: 'Master of Discipline',
        descricao: 'Mantenha uma sequência de 30 dias',
        raridade: 'epico',
        recompensaXP: 500,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),
      Achievement(
        id: '8',
        tipo: 'lendario',
        titulo: 'Living Legend',
        descricao: 'Alcance o nível 50',
        raridade: 'epico',
        recompensaXP: 1000,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),
      Achievement(
        id: '9',
        tipo: 'conquistador',
        titulo: 'Conqueror',
        descricao: 'Desbloqueie todas as conquistas comuns',
        raridade: 'epico',
        recompensaXP: 750,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),

      // Conquistas Épicas (Rei)
      Achievement(
        id: '10',
        tipo: 'sequencia_100',
        titulo: 'Emperor of Persistence',
        descricao: 'Mantenha uma sequência de 100 dias',
        raridade: 'lendario',
        recompensaXP: 2000,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
      Achievement(
        id: '11',
        tipo: 'deus_habitos',
        titulo: 'God of Habits',
        descricao: 'Complete 1000 hábitos no total',
        raridade: 'lendario',
        recompensaXP: 5000,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
      Achievement(
        id: '12',
        tipo: 'lenda_absoluta',
        titulo: 'Absolute Legend',
        descricao: 'Desbloqueie todas as conquistas do jogo',
        raridade: 'lendario',
        recompensaXP: 10000,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
    ];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
