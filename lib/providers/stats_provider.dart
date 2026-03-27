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
      // Buscar dashboard e dados semanais em paralelo
      final dashboardFuture = ApiService.getUserDashboard();
      final weeklyChartFuture = ApiService.getWeeklyChart();
      
      final dashboardData = await dashboardFuture;
      final weeklyChartData = await weeklyChartFuture;
      
      if (dashboardData['sucesso'] == true && dashboardData['dashboard'] != null) {
        final dashboard = dashboardData['dashboard'];
        final statsHoje = dashboard['estatisticasHoje'] ?? {};
        final usuario = dashboard['usuario'] ?? {};
        final sequencia = usuario['sequencia'] ?? {};
        
        // Calcular estatísticas de categoria se houver hábitos
        Map<String, int> categoryStats = {};
        if (dashboard['habitos'] != null) {
          final habits = dashboard['habitos'] as List;
          for (var habit in habits) {
            if (habit is Map && habit['categoria'] != null) {
              final categoria = habit['categoria'].toString();
              categoryStats[categoria] = (categoryStats[categoria] ?? 0) + 1;
            }
          }
        }
        
        // Processar dados semanais reais
        List<Map<String, dynamic>> weeklyData = [];
        if (weeklyChartData['sucesso'] == true && weeklyChartData['graficoSemanal'] != null) {
          final graficoSemanal = weeklyChartData['graficoSemanal'] as List;
          
          // Garantir que temos 7 dias (da mais antiga até hoje)
          final hoje = DateTime.now();
          final diasSemana = <String, Map<String, dynamic>>{};
          
          // Inicializar todos os 7 dias
          for (int i = 6; i >= 0; i--) {
            final data = hoje.subtract(Duration(days: i));
            final dataString = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
            diasSemana[dataString] = {
              'data': dataString,
              'concluidos': 0,
              'perdidos': 0,
              'experiencia': 0,
              'habitos': []
            };
          }
          
          // Preencher com dados reais da API
          for (var dia in graficoSemanal) {
            if (dia is Map<String, dynamic> && dia['data'] != null) {
              final dataString = dia['data'].toString().split('T')[0];
              if (diasSemana.containsKey(dataString)) {
                diasSemana[dataString] = Map<String, dynamic>.from(dia);
              }
            }
          }
          
          // Converter para lista ordenada
          weeklyData = diasSemana.values.toList();
        }
        
        // Mapear os campos do backend para o modelo Stats
        _stats = Stats(
          totalHabits: statsHoje['totalHabitos'] ?? 
                      (dashboard['habitos'] as List?)?.length ?? 0,
          completedHabits: statsHoje['habitosConcluidos'] ?? 0,
          currentStreak: sequencia['atual'] ?? sequencia['sequenciaAtual'] ?? 0,
          longestStreak: sequencia['maiorSequencia'] ?? sequencia['maior'] ?? 0,
          completionRate: (statsHoje['porcentagemConclusao'] ?? 0.0) / 100.0,
          totalXP: usuario['experiencia'] ?? 0,
          level: usuario['nivel'] ?? 1,
          categoryStats: categoryStats,
          weeklyData: weeklyData,
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
