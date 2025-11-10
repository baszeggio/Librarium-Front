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
  final bool? completado; // Indica se o hábito foi completado hoje (opcional)

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
    this.completado,
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
      completado: json['completado'] ?? json['concluidoHoje'] ?? json['statusHoje'] == 'concluido',
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
      if (habitsData.isNotEmpty) {
        _habits = habitsData.map((habitJson) => Habit.fromJson(habitJson)).toList();
      } else {
        // Lista vazia - usuário não tem hábitos ainda
        _habits = [];
      }
    } catch (e) {
      // Não usar dados mock - mostrar lista vazia e erro
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
      // Mapear categoria 'casa' para valor aceito pelo backend
      // O backend pode não aceitar 'casa', então mapeamos para 'geral' ou outro valor válido
      String categoriaMapeada = categoria;
      if (categoria == 'casa') {
        // Se o backend não aceita 'casa', usar 'geral' ou verificar valores válidos
        // Valores válidos comuns: 'geral', 'saude', 'estudo', 'trabalho', 'social'
        categoriaMapeada = 'geral'; // Fallback temporário
      }
      
      final habitData = {
        'titulo': titulo,
        'descricao': descricao,
        'frequencia': frequencia,
        'categoria': categoriaMapeada,
        'dificuldade': dificuldade,
        'icone': icone,
        'cor': cor,
      };

      final response = await ApiService.createHabit(habitData);
      
      if (response['sucesso'] == true || response['success'] == true) {
        // Recarregar hábitos para incluir o novo
        await loadHabits();
        
        // Aguardar um pouco para garantir que o backend processou
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Verificar conquistas será feito pela tela que cria o hábito
        // para garantir que as conquistas sejam recarregadas corretamente
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
      
      if (response['sucesso'] == true || response['success'] == true) {
        // Recarregar hábitos para obter dados atualizados com streak atualizado
        await loadHabits();
        
        // Aguardar um pouco para garantir que o backend processou
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Recarregar novamente para garantir dados atualizados
        await loadHabits();
        
        // A verificação de conquistas será feita pelas telas que chamam completeHabit
        // para garantir que as conquistas sejam recarregadas corretamente
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao completar hábito');
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteHabit(habitId);
      
      if (response['sucesso'] == true || response['success'] == true) {
        // Remover hábito da lista local
        _habits.removeWhere((habit) => habit.id == habitId);
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao deletar hábito');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHabit(String habitId, Map<String, dynamic> habitData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateHabit(habitId, habitData);
      
      if (response['sucesso'] == true || response['success'] == true) {
        // Recarregar hábitos para obter dados atualizados
        await loadHabits();
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao atualizar hábito');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getHabitProgress(String habitId) async {
    try {
      final response = await ApiService.getHabitProgress(habitId);
      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verifica se o hábito pode ser completado conforme o tipo
  bool canCompleteHabit(Habit habit) {
    // Se já foi completado no período, não pode completar novamente
    if (habit.completado == true) {
      return false;
    }

    // Verificar conforme o tipo de frequência
    switch (habit.frequencia.toLowerCase()) {
      case 'diario':
        // Diário: só pode completar 1x por dia
        // O backend já retorna se foi completado hoje
        return habit.completado != true;
      
      case 'semanal':
        // Semanal: só pode completar 1x por semana
        // O backend já retorna se foi completado esta semana
        return habit.completado != true;
      
      case 'mensal':
        // Mensal: só pode completar 1x por mês
        // O backend já retorna se foi completado este mês
        return habit.completado != true;
      
      default:
        // Para outros tipos, permitir completar
        return true;
    }
  }

  // Retorna mensagem explicativa se não pode completar
  String? getCannotCompleteReason(Habit habit) {
    if (habit.completado == true) {
      switch (habit.frequencia.toLowerCase()) {
        case 'diario':
          return 'Este hábito já foi completado hoje';
        case 'semanal':
          return 'Este hábito já foi completado esta semana';
        case 'mensal':
          return 'Este hábito já foi completado este mês';
        default:
          return 'Este hábito já foi completado';
      }
    }
    return null;
  }
}
