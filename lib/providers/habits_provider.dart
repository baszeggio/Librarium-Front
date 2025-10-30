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
    return Habit(
      id: json['_id'] ?? json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      frequencia: json['frequencia'] ?? 'diario',
      categoria: json['categoria'] ?? 'geral',
      dificuldade: json['dificuldade'] ?? 'medio',
      icone: json['icone'] ?? 'espada',
      cor: json['cor'] ?? '#6A0572',
      ativo: json['ativo'] ?? true,
      sequenciaAtual: json['sequencia']?['atual'] ?? 0,
      maiorSequencia: json['sequencia']?['maiorSequencia'] ?? 0,
      totalConclusoes: json['estatisticas']?['totalConclusoes'] ?? 0,
      totalPerdidos: json['estatisticas']?['totalPerdidos'] ?? 0,
      taxaConclusao: json['estatisticas']?['taxaConclusao']?.toDouble() ?? 0.0,
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
      _habits = habitsData.map((habitJson) => Habit.fromJson(habitJson)).toList();
    } catch (e) {
      // Fallback: preenche com exemplos locais para não deixar a tela vazia
      _habits = [
        Habit(
          id: 'local_example_1',
          titulo: 'Beber água',
          descricao: '8 copos por dia',
          frequencia: 'diario',
          categoria: 'saude',
          dificuldade: 'facil',
          icone: 'coracao',
          cor: '#45B7D1',
          ativo: true,
          sequenciaAtual: 2,
          maiorSequencia: 7,
          totalConclusoes: 5,
          totalPerdidos: 1,
          taxaConclusao: 0.83,
        ),
        Habit(
          id: 'local_example_2',
          titulo: 'Estudar 30min',
          descricao: 'Foco em Flutter',
          frequencia: 'diario',
          categoria: 'estudo',
          dificuldade: 'medio',
          icone: 'livro',
          cor: '#8250DF',
          ativo: true,
          sequenciaAtual: 4,
          maiorSequencia: 10,
          totalConclusoes: 12,
          totalPerdidos: 3,
          taxaConclusao: 0.8,
        ),
      ];
      // Mantém o erro registrado, mas provê dados visíveis
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
      
      if (response['sucesso'] == true) {
        final newHabit = Habit.fromJson(response['habito']);
        _habits.add(newHabit);
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao criar hábito');
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
