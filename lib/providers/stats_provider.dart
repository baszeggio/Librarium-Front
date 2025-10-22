import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Stats {
  final int totalHabits;
  final int completedHabits;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final int totalXP;
  final int level;
  final Map<String, int> categoryStats;
  final List<Map<String, dynamic>> weeklyData;
  final List<Map<String, dynamic>> monthlyData;

  Stats({
    required this.totalHabits,
    required this.completedHabits,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.totalXP,
    required this.level,
    required this.categoryStats,
    required this.weeklyData,
    required this.monthlyData,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalHabits: json['totalHabits'] ?? 0,
      completedHabits: json['completedHabits'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      completionRate: (json['completionRate'] ?? 0.0).toDouble(),
      totalXP: json['totalXP'] ?? 0,
      level: json['level'] ?? 1,
      categoryStats: Map<String, int>.from(json['categoryStats'] ?? {}),
      weeklyData: List<Map<String, dynamic>>.from(json['weeklyData'] ?? []),
      monthlyData: List<Map<String, dynamic>>.from(json['monthlyData'] ?? []),
    );
  }
}

class StatsProvider extends ChangeNotifier {
  Stats? _stats;
  bool _isLoading = false;
  String? _error;

  Stats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final statsData = await ApiService.getStats();
      
      if (statsData['sucesso'] == true) {
        _stats = Stats.fromJson(statsData['estatisticas']);
      } else {
        throw Exception(statsData['mensagem'] ?? 'Erro ao carregar estatísticas');
      }
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
