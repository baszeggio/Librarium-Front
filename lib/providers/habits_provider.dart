import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Habit {
  final String id;
  final String titulo;
  final String descricao;
  final String frequencia;
  final String categoria;
  final String dificuldade;
  final String icone;
  final String cor;
  final bool ativo;
  final int sequenciaAtual;
  final int maiorSequencia;
  final int totalConclusoes;
  final int totalPerdidos;
  final double taxaConclusao;

  Habit({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.frequencia,
    required this.categoria,
    required this.dificuldade,
    required this.icone,
    required this.cor,
    required this.ativo,
    required this.sequenciaAtual,
    required this.maiorSequencia,
    required this.totalConclusoes,
    required this.totalPerdidos,
    required this.taxaConclusao,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    // MongoDB retorna _id como ObjectId, que pode vir como string ou objeto
    String getId() {
      if (json['_id'] != null) {
        if (json['_id'] is String) {
          return json['_id'];
        } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
          return json['_id']['\$oid'];
        } else {
          return json['_id'].toString();
        }
      }
      return json['id']?.toString() ?? '';
    }

    return Habit(
      id: getId(),
      titulo: json['titulo'] ?? json['title'] ?? '',
      descricao: json['descricao'] ?? json['description'] ?? '',
      frequencia: json['frequencia'] ?? json['frequency'] ?? 'diario',
      categoria: json['categoria'] ?? json['category'] ?? 'geral',
      dificuldade: json['dificuldade'] ?? json['difficulty'] ?? 'medio',
      icone: json['icone'] ?? json['icon'] ?? 'espada',
      cor: json['cor'] ?? json['color'] ?? '#6A0572',
      ativo: json['ativo'] ?? json['active'] ?? true,
      sequenciaAtual: json['sequencia']?['atual'] ?? json['sequencia']?['current'] ?? json['currentStreak'] ?? 0,
      maiorSequencia: json['sequencia']?['maiorSequencia'] ?? json['sequencia']?['longest'] ?? json['longestStreak'] ?? 0,
      totalConclusoes: json['estatisticas']?['totalConclusoes'] ?? json['estatisticas']?['totalCompletions'] ?? json['totalCompletions'] ?? 0,
      totalPerdidos: json['estatisticas']?['totalPerdidos'] ?? json['estatisticas']?['totalMissed'] ?? json['totalMissed'] ?? 0,
      taxaConclusao: (json['estatisticas']?['taxaConclusao'] ?? json['estatisticas']?['completionRate'] ?? json['completionRate'] ?? 0.0).toDouble(),
    );
  }
}

class HabitsProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _error;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Habit> get activeHabits => _habits.where((habit) => habit.ativo).toList();
  List<Habit> get habitsByCategory => _habits.where((habit) => habit.categoria.isNotEmpty).toList();

  Future<void> loadHabits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final habitsData = await ApiService.getHabits();
      _habits = habitsData.map((habitJson) => Habit.fromJson(Map<String, dynamic>.from(habitJson as Map))).toList();
      _error = null;
    } catch (e) {
      _habits = [];
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createHabit({
    required String titulo,
    required String descricao,
    required String frequencia,
    required String categoria,
    required String dificuldade,
    required String icone,
    required String cor,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final habitData = {
        'titulo': titulo,
        'descricao': descricao,
        'frequencia': frequencia,
        'categoria': categoria,
        'dificuldade': dificuldade,
        'icone': icone,
        'cor': cor,
      };

      final response = await ApiService.createHabit(habitData);
      
      // Aceitar diferentes formatos de resposta do backend
      if (response['sucesso'] == true || response['success'] == true) {
        // Pode vir como 'habito', 'habit', 'data' ou diretamente o objeto
        final habitJson = response['habito'] ?? response['habit'] ?? response['data'] ?? response;
        final Map<String, dynamic> parsed = Map<String, dynamic>.from(habitJson as Map);
        final newHabit = Habit.fromJson(parsed);
        _habits.add(newHabit);
        _error = null;
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao criar hábito');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cria um hábito local de exemplo (offline) para visualização
  void addLocalHabitExample({
    required String titulo,
    required String descricao,
    required String frequencia,
    required String categoria,
    required String dificuldade,
    required String icone,
    required String cor,
  }) {
    final String localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final Habit example = Habit(
      id: localId,
      titulo: titulo.isEmpty ? 'Hábito de Exemplo' : titulo,
      descricao: descricao.isEmpty ? 'Este é um hábito criado localmente para demonstração.' : descricao,
      frequencia: frequencia,
      categoria: categoria,
      dificuldade: dificuldade,
      icone: icone,
      cor: cor,
      ativo: true,
      sequenciaAtual: 0,
      maiorSequencia: 0,
      totalConclusoes: 0,
      totalPerdidos: 0,
      taxaConclusao: 0.0,
    );
    _habits.add(example);
    notifyListeners();
  }

  Future<void> completeHabit(String habitId) async {
    try {
      final response = await ApiService.completeHabit(habitId);
      
      if (response['sucesso'] == true) {
        // Recarregar hábitos para obter dados atualizados
        await loadHabits();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao completar hábito');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
