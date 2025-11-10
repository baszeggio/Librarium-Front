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
    // Verificar se está desbloqueada baseado em desbloqueadaEm (campo do backend)
    // Também verificar outros campos possíveis
    final desbloqueadaEm = json['desbloqueadaEm'];
    final desbloqueada = json['desbloqueada'];
    final unlocked = json['unlocked'];
    
    // Verificar múltiplos campos para determinar se está desbloqueada
    bool estaDesbloqueada = false;
    if (desbloqueadaEm != null && desbloqueadaEm.toString().isNotEmpty) {
      estaDesbloqueada = true;
    } else if (desbloqueada == true || unlocked == true) {
      estaDesbloqueada = true;
    }
    
    DateTime? dataDesbloqueio;
    if (estaDesbloqueada && desbloqueadaEm != null) {
      try {
        dataDesbloqueio = desbloqueadaEm is DateTime 
            ? desbloqueadaEm 
            : DateTime.parse(desbloqueadaEm.toString());
      } catch (e) {
        print('Erro ao parsear dataDesbloqueio: $e');
        dataDesbloqueio = null;
      }
    }
    
    final achievement = Achievement(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? '',
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'] ?? '',
      raridade: json['raridade'] ?? 'comum',
      recompensaXP: json['experienciaRecompensa'] ?? json['recompensaXP'] ?? 0,
      desbloqueada: estaDesbloqueada,
      dataDesbloqueio: dataDesbloqueio,
      icone: json['icone'] ?? 'trophy',
    );
    
    // Log para debug
    if (estaDesbloqueada) {
      print('Conquista desbloqueada: ${achievement.titulo} (ID: ${achievement.id})');
    }
    
    return achievement;
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
      // Tentar buscar conquistas da API
      print('Carregando conquistas do backend...');
      final achievementsData = await ApiService.getAchievements();
      print('Conquistas recebidas: ${achievementsData.length}');
      
      if (achievementsData is List) {
        // Salvar estado anterior de conquistas desbloqueadas
        final previousUnlockedIds = _achievements
            .where((a) => a.desbloqueada)
            .map((a) => a.id)
            .toSet();
        
        // Se a lista estiver vazia, usar conquistas mockadas para exibir todas as conquistas disponíveis
        if (achievementsData.isEmpty) {
          print('Lista de conquistas vazia do backend, usando conquistas mockadas');
          _achievements = _getMockAchievements();
        } else {
          // Usar os dados do backend
          _achievements = achievementsData
              .map((achievementJson) {
                // Log detalhado de cada conquista
                print('Processando conquista: ${achievementJson['titulo']} - desbloqueadaEm: ${achievementJson['desbloqueadaEm']} - desbloqueada: ${achievementJson['desbloqueada']}');
                return Achievement.fromJson(achievementJson);
              })
              .toList();
        }
        
        print('Conquistas carregadas: ${_achievements.length}');
        final desbloqueadas = _achievements.where((a) => a.desbloqueada).toList();
        print('Conquistas desbloqueadas: ${desbloqueadas.length}');
        for (var a in desbloqueadas) {
          print('  - ${a.titulo} (ID: ${a.id})');
        }
        
        // Verificar se há novas conquistas desbloqueadas
        final currentUnlockedIds = _achievements
            .where((a) => a.desbloqueada)
            .map((a) => a.id)
            .toSet();
        
        final novasDesbloqueadas = currentUnlockedIds.difference(previousUnlockedIds);
        if (novasDesbloqueadas.isNotEmpty) {
          print('${novasDesbloqueadas.length} nova(s) conquista(s) desbloqueada(s)! IDs: $novasDesbloqueadas');
        }
      } else {
        // Se não for uma lista, usar conquistas mockadas
        print('Resposta da API não é uma lista válida, usando conquistas mockadas');
        _achievements = _getMockAchievements();
      }
    } catch (e) {
      // Se houver erro, usar conquistas mockadas para garantir que sempre haja conquistas para exibir
      print('Erro ao carregar conquistas da API: $e');
      _achievements = _getMockAchievements();
      print('Usando dados mockados devido ao erro');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyAchievements() async {
    try {
      // Salvar estado anterior de conquistas desbloqueadas
      final previousUnlockedIds = _achievements
          .where((a) => a.desbloqueada)
          .map((a) => a.id)
          .toSet();
      
      print('Verificando conquistas...');
      final response = await ApiService.verifyAchievements();
      print('Resposta da verificação: $response');
      
      // Aguardar um pouco para garantir que o backend processou as conquistas
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Sempre recarregar conquistas após verificação, independente da resposta
      // O backend pode ter processado as conquistas mesmo se a resposta não indicar sucesso explicitamente
      await loadAchievements();
      
      // Aguardar mais um pouco para garantir que os dados foram atualizados
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Recarregar novamente para garantir que as conquistas estão atualizadas
      await loadAchievements();
      
      // Verificar se há novas conquistas desbloqueadas
      final currentUnlockedIds = _achievements
          .where((a) => a.desbloqueada)
          .map((a) => a.id)
          .toSet();
      
      final novasDesbloqueadas = currentUnlockedIds.difference(previousUnlockedIds);
      
      if (novasDesbloqueadas.isNotEmpty) {
        print('${novasDesbloqueadas.length} nova(s) conquista(s) desbloqueada(s)! IDs: $novasDesbloqueadas');
        // Notificar listeners sobre novas conquistas
        notifyListeners();
      } else {
        print('Nenhuma nova conquista desbloqueada.');
      }
      
      // Notificar listeners mesmo se não houver novas conquistas para atualizar a UI
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      // Não interromper o fluxo se a verificação falhar
      print('Erro ao verificar conquistas: $e');
      // Mesmo com erro, tentar recarregar conquistas para mostrar estado atual
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        await loadAchievements();
        notifyListeners();
      } catch (loadError) {
        print('Erro ao recarregar conquistas após verificação: $loadError');
      }
    }
  }

  Future<void> loadAchievementsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final achievementsData = await ApiService.getAchievementsByCategory(category);
      if (achievementsData.isNotEmpty) {
        _achievements = achievementsData
            .map((achievementJson) => Achievement.fromJson(achievementJson))
            .toList();
      } else {
        _achievements = [];
      }
    } catch (e) {
      _error = e.toString();
      _achievements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAchievementsByRarity(String rarity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final achievementsData = await ApiService.getAchievementsByRarity(rarity);
      if (achievementsData.isNotEmpty) {
        _achievements = achievementsData
            .map((achievementJson) => Achievement.fromJson(achievementJson))
            .toList();
      } else {
        _achievements = [];
      }
    } catch (e) {
      _error = e.toString();
      _achievements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCustomAchievement({
    required String titulo,
    required String descricao,
    required String raridade,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.createCustomAchievement({
        'titulo': titulo,
        'descricao': descricao,
        'raridade': raridade.toLowerCase(),
      });

      if (response['sucesso'] == true) {
        await loadAchievements();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao criar conquista');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAchievementAsRead(String achievementId) async {
    try {
      await ApiService.markAchievementAsRead(achievementId);
      await loadAchievements();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Adiciona uma conquista personalizada localmente (fallback offline)
  void addCustomAchievementLocal({
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
        desbloqueada: false, // Não desbloqueada por padrão
        icone: 'assets/green_award.png',
      ),
      Achievement(
        id: '2',
        tipo: 'sequencia_3',
        titulo: 'Rising Soul',
        descricao: 'Mantenha uma sequência de 3 dias',
        raridade: 'comum',
        recompensaXP: 75,
        desbloqueada: false, // Não desbloqueada por padrão
        icone: 'assets/green_award.png',
      ),
      Achievement(
        id: '3',
        tipo: 'categoria_saude',
        titulo: 'Fragile Strength',
        descricao: 'Complete 5 hábitos de saúde',
        raridade: 'comum',
        recompensaXP: 100,
        desbloqueada: false,
        icone: 'assets/green_award.png',
      ),
      Achievement(
        id: '13',
        tipo: 'primeira_semana',
        titulo: 'Path of Pain',
        descricao: 'Complete sua primeira semana de hábitos',
        raridade: 'comum',
        recompensaXP: 125,
        desbloqueada: false,
        icone: 'assets/green_award.png',
      ),
      Achievement(
        id: '14',
        tipo: 'explorador',
        titulo: 'Explorer',
        descricao: 'Crie hábitos em 3 categorias diferentes',
        raridade: 'comum',
        recompensaXP: 150,
        desbloqueada: false,
        icone: 'assets/green_award.png',
      ),

      // Conquistas Médias (Vermelho)
      Achievement(
        id: '4',
        tipo: 'sequencia_7',
        titulo: 'Pure Nail',
        descricao: 'Mantenha uma sequência de 7 dias',
        raridade: 'raro',
        recompensaXP: 200,
        desbloqueada: false, // Não desbloqueada por padrão
        icone: 'assets/red_award.png',
      ),
      Achievement(
        id: '5',
        tipo: 'perfeccionista',
        titulo: 'Perfect Completion',
        descricao: 'Complete 10 hábitos com 100% de eficiência',
        raridade: 'raro',
        recompensaXP: 300,
        desbloqueada: false,
        icone: 'assets/red_award.png',
      ),
      Achievement(
        id: '6',
        tipo: 'guerreiro',
        titulo: 'Soul Warrior',
        descricao: 'Complete 20 hábitos difíceis',
        raridade: 'raro',
        recompensaXP: 400,
        desbloqueada: false,
        icone: 'assets/red_award.png',
      ),
      Achievement(
        id: '15',
        tipo: 'metamorfose',
        titulo: 'Metamorphosis',
        descricao: 'Evolua seu avatar pela primeira vez',
        raridade: 'raro',
        recompensaXP: 350,
        desbloqueada: false,
        icone: 'assets/red_award.png',
      ),
      Achievement(
        id: '16',
        tipo: 'colecionador',
        titulo: 'Collector',
        descricao: 'Desbloqueie 5 conquistas diferentes',
        raridade: 'raro',
        recompensaXP: 450,
        desbloqueada: false,
        icone: 'assets/red_award.png',
      ),

      // Conquistas Difíceis (Dourado)
      Achievement(
        id: '7',
        tipo: 'sequencia_30',
        titulo: 'Steel Soul',
        descricao: 'Mantenha uma sequência de 30 dias',
        raridade: 'epico',
        recompensaXP: 500,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),
      Achievement(
        id: '8',
        tipo: 'lendario',
        titulo: 'Void Heart',
        descricao: 'Alcance o nível 50',
        raridade: 'epico',
        recompensaXP: 1000,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),
      Achievement(
        id: '9',
        tipo: 'conquistador',
        titulo: 'True Completion',
        descricao: 'Desbloqueie todas as conquistas comuns',
        raridade: 'epico',
        recompensaXP: 750,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),
      Achievement(
        id: '17',
        tipo: 'mestre',
        titulo: 'Master of Habits',
        descricao: 'Complete 100 hábitos no total',
        raridade: 'epico',
        recompensaXP: 1500,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),
      Achievement(
        id: '18',
        tipo: 'perfeito',
        titulo: 'Perfect Run',
        descricao: 'Mantenha 100% de eficiência por 30 dias',
        raridade: 'epico',
        recompensaXP: 2000,
        desbloqueada: false,
        icone: 'assets/gold_award.png',
      ),

      // Conquistas Épicas (Rei)
      Achievement(
        id: '10',
        tipo: 'sequencia_100',
        titulo: 'The Radiance',
        descricao: 'Mantenha uma sequência de 100 dias',
        raridade: 'lendario',
        recompensaXP: 2000,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
      Achievement(
        id: '11',
        tipo: 'deus_habitos',
        titulo: 'The Hollow Knight',
        descricao: 'Complete 1000 hábitos no total',
        raridade: 'lendario',
        recompensaXP: 5000,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
      Achievement(
        id: '12',
        tipo: 'lenda_absoluta',
        titulo: 'Sealed Siblings',
        descricao: 'Desbloqueie todas as conquistas do jogo',
        raridade: 'lendario',
        recompensaXP: 10000,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
      Achievement(
        id: '19',
        tipo: 'perfeicao_absoluta',
        titulo: 'Pantheon of Hallownest',
        descricao: 'Complete todos os hábitos com 100% de eficiência',
        raridade: 'lendario',
        recompensaXP: 7500,
        desbloqueada: false,
        icone: 'assets/king_award.png',
      ),
      Achievement(
        id: '20',
        tipo: 'lendario_verdadeiro',
        titulo: 'Godmaster',
        descricao: 'Alcance o nível máximo (100)',
        raridade: 'lendario',
        recompensaXP: 15000,
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

