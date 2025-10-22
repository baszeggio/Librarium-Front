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
      final achievementsData = await ApiService.getAchievements();
      _achievements = achievementsData.map((achievementJson) => 
          Achievement.fromJson(achievementJson)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
