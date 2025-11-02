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
      // Usar getUserDashboard que retorna estatísticas completas do usuário
      final dashboardData = await ApiService.getUserDashboard();
      
      if (dashboardData['sucesso'] == true && dashboardData['dashboard'] != null) {
        final dashboard = dashboardData['dashboard'];
        final statsHoje = dashboard['estatisticasHoje'] ?? {};
        final usuario = dashboard['usuario'] ?? {};
        final sequencia = usuario['sequencia'] ?? {};
        
        // Mapear os campos do backend para o modelo Stats
        _stats = Stats(
          totalHabits: statsHoje['totalHabitos'] ?? 
                      (dashboard['habitos'] as List?)?.length ?? 0,
          completedHabits: statsHoje['habitosConcluidos'] ?? 0,
          currentStreak: sequencia['atual'] ?? 0,
          longestStreak: sequencia['maiorSequencia'] ?? 0,
          completionRate: (statsHoje['porcentagemConclusao'] ?? 0.0) / 100.0,
          totalXP: usuario['experiencia'] ?? 0,
          level: usuario['nivel'] ?? 1,
          categoryStats: {}, // Será preenchido se necessário
          weeklyData: [],
          monthlyData: [],
        );
      } else {
        // Fallback: criar stats vazias se não conseguir carregar
        _stats = Stats(
          totalHabits: 0,
          completedHabits: 0,
          currentStreak: 0,
          longestStreak: 0,
          completionRate: 0.0,
          totalXP: 0,
          level: 1,
          categoryStats: {},
          weeklyData: [],
          monthlyData: [],
        );
      }
    } catch (e) {
      // Fallback em caso de erro - não usar dados mock
      _stats = Stats(
        totalHabits: 0,
        completedHabits: 0,
        currentStreak: 0,
        longestStreak: 0,
        completionRate: 0.0,
        totalXP: 0,
        level: 1,
        categoryStats: {},
        weeklyData: [],
        monthlyData: [],
      );
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
