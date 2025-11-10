import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Battle {
  final String id;
  final String jogador1;
  final String jogador2;
  final String? jogador1Id; // ID do jogador1
  final String? jogador2Id; // ID do jogador2
  final String tipoBatalha;
  final String status;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final Map<String, dynamic>? pontuacoes;
  final Map<String, dynamic>? resultado;
  final Map<String, dynamic>? recompensas;

  Battle({
    required this.id,
    required this.jogador1,
    required this.jogador2,
    this.jogador1Id,
    this.jogador2Id,
    required this.tipoBatalha,
    required this.status,
    this.dataInicio,
    this.dataFim,
    this.pontuacoes,
    this.resultado,
    this.recompensas,
  });

  factory Battle.fromJson(Map<String, dynamic> json) {
    // Extrair ID do jogador1 (pode ser ObjectId ou objeto populado)
    String? jogador1Id;
    if (json['jogador1'] is Map) {
      // Se for objeto populado, pegar o _id
      jogador1Id = json['jogador1']?['_id']?.toString() ?? 
                   json['jogador1']?['id']?.toString();
    } else if (json['jogador1'] != null) {
      // Se for string/ObjectId direto
      jogador1Id = json['jogador1'].toString();
    }
    
    // Debug
    print('Battle.fromJson - jogador1: ${json['jogador1']}, jogador1Id extraído: $jogador1Id');

    // Extrair ID do jogador2 (pode ser ObjectId ou objeto populado)
    String? jogador2Id;
    if (json['jogador2'] is Map) {
      // Se for objeto populado, pegar o _id
      jogador2Id = json['jogador2']?['_id']?.toString() ?? 
                   json['jogador2']?['id']?.toString();
    } else if (json['jogador2'] != null) {
      // Se for string/ObjectId direto
      jogador2Id = json['jogador2'].toString();
    }
    
    // Debug
    print('Battle.fromJson - jogador2: ${json['jogador2']}, jogador2Id extraído: $jogador2Id');

    return Battle(
      id: json['_id'] ?? json['id'] ?? '',
      jogador1: json['jogador1']?['nomeUsuario'] ?? json['jogador1']?.toString() ?? '',
      jogador2: json['jogador2']?['nomeUsuario'] ?? json['jogador2']?.toString() ?? '',
      jogador1Id: jogador1Id,
      jogador2Id: jogador2Id,
      tipoBatalha: json['tipoBatalha'] ?? '',
      status: json['status'] ?? 'aguardando',
      dataInicio: json['dataInicio'] != null 
          ? DateTime.parse(json['dataInicio'])
          : null,
      dataFim: json['dataFim'] != null 
          ? DateTime.parse(json['dataFim'])
          : null,
      pontuacoes: json['pontuacoes'],
      resultado: json['resultado'],
      recompensas: json['recompensas'],
    );
  }
}

class Challenge {
  final String id;
  final String remetente;
  final String destinatario;
  final String tipoDesafio;
  final String status;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String? mensagem;

  Challenge({
    required this.id,
    required this.remetente,
    required this.destinatario,
    required this.tipoDesafio,
    required this.status,
    this.dataInicio,
    this.dataFim,
    this.mensagem,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['_id'] ?? json['id'] ?? '',
      remetente: json['remetente']?['nomeUsuario'] ?? json['remetente'] ?? '',
      destinatario: json['destinatario']?['nomeUsuario'] ?? json['destinatario'] ?? '',
      tipoDesafio: json['tipoDesafio'] ?? '',
      status: json['status'] ?? 'pendente',
      dataInicio: json['dataInicio'] != null 
          ? DateTime.parse(json['dataInicio'])
          : null,
      dataFim: json['dataFim'] != null 
          ? DateTime.parse(json['dataFim'])
          : null,
      mensagem: json['mensagem'],
    );
  }
}

class MultiplayerProvider extends ChangeNotifier {
  List<Battle> _battles = [];
  List<Challenge> _challenges = [];
  bool _isLoading = false;
  String? _error;

  List<Battle> get battles => _battles;
  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Battle> get activeBattles => 
      _battles.where((b) => b.status == 'em_andamento' || b.status == 'aguardando').toList();
  
  List<Challenge> get pendingChallenges => 
      _challenges.where((c) => c.status == 'pendente').toList();

  Future<void> loadBattles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final battlesData = await ApiService.getBattles();
      _battles = battlesData
          .map((battleJson) {
            final battle = Battle.fromJson(battleJson);
            // Debug: imprimir informações da batalha
            print('Batalha carregada: id=${battle.id}, jogador1Id=${battle.jogador1Id}, jogador2Id=${battle.jogador2Id}, status=${battle.status}');
            return battle;
          })
          .toList();
      print('Total de batalhas carregadas: ${_battles.length}');
    } catch (e) {
      _error = e.toString();
      _battles = [];
      print('Erro ao carregar batalhas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChallenges() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final challengesData = await ApiService.getChallenges();
      _challenges = challengesData
          .map((challengeJson) => Challenge.fromJson(challengeJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _challenges = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createBattle({
    required String adversarioId,
    String? tipoBatalha,
    int? duracao,
    List<Map<String, dynamic>>? criterios,
    Map<String, dynamic>? configuracao,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createBattle({
        'adversarioId': adversarioId,
        if (tipoBatalha != null) 'tipoBatalha': tipoBatalha,
        if (duracao != null) 'duracao': duracao,
        if (criterios != null) 'criterios': criterios,
        if (configuracao != null) 'configuracao': configuracao,
      });

      if (response['sucesso'] == true) {
        await loadBattles();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao criar batalha');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptBattle(String battleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.acceptBattle(battleId);
      if (response['sucesso'] == true) {
        await loadBattles();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao aceitar batalha');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finishBattle(String battleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.finishBattle(battleId);
      if (response['sucesso'] == true) {
        await loadBattles();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao finalizar batalha');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createChallenge({
    required String adversarioId,
    String? tipoDesafio,
    DateTime? dataFim,
    String? mensagem,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createChallenge({
        'adversarioId': adversarioId,
        if (tipoDesafio != null) 'tipoDesafio': tipoDesafio,
        if (dataFim != null) 'dataFim': dataFim.toIso8601String(),
        if (mensagem != null) 'mensagem': mensagem,
      });

      if (response['sucesso'] == true) {
        await loadChallenges();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao criar desafio');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondChallenge(String challengeId, bool accept) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.respondToChallenge(
        challengeId,
        {'resposta': accept ? 'aceito' : 'recusado'},
      );

      if (response['sucesso'] == true) {
        await loadChallenges();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao responder desafio');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
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

