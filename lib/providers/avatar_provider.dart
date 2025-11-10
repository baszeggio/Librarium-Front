import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Avatar {
  final int nivel;
  final Map<String, String> equipamentos;
  final List<String> efeitos;
  final String tema;
  final int experiencia;
  final int experienciaProximoNivel;

  Avatar({
    required this.nivel,
    required this.equipamentos,
    required this.efeitos,
    required this.tema,
    required this.experiencia,
    required this.experienciaProximoNivel,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      nivel: json['nivel'] ?? 1,
      equipamentos: Map<String, String>.from(json['equipamentos'] ?? {}),
      efeitos: List<String>.from(json['efeitos'] ?? []),
      tema: json['tema'] ?? 'default',
      experiencia: json['experiencia'] ?? 0,
      experienciaProximoNivel: json['experienciaProximoNivel'] ?? 100,
    );
  }

  String get avatarImage {
    // Retorna a imagem do avatar baseada no nível
    switch (nivel) {
      case 1:
        return 'assets/avatars/level_1.png';
      case 2:
        return 'assets/avatars/level_2.png';
      case 3:
        return 'assets/avatars/level_3.png';
      case 4:
        return 'assets/avatars/level_4.png';
      case 5:
        return 'assets/avatars/level_5.png';
      default:
        return 'assets/avatars/level_6.png';
    }
  }

  String get title {
    // O título deve vir do backend, mas temos um fallback baseado no nível
    // Baseado na lógica do backend (models/User.js - tituloCalculado)
    if (nivel >= 31) return 'Conjurador Supremo';
    if (nivel >= 21) return 'Guardião do Librarium';
    if (nivel >= 11) return 'Caçador';
    return 'Aspirante'; // Fallback para níveis 1-10
  }

  double get progressPercentage {
    if (experienciaProximoNivel == 0) return 1.0;
    // Garantir que o progresso não passe de 100%
    final progresso = (experiencia / experienciaProximoNivel).clamp(0.0, 1.0);
    return progresso;
  }

  // Retorna o asset da cabeça selecionada, se estiver configurado e válido
  String? get headAsset {
    final String? headKey = equipamentos['head'];
    if (headKey == null || headKey.isEmpty) return null;
    if (!headKey.endsWith('_head')) return null;
    // Verificar se o asset existe (assumindo que existe se termina com _head)
    return 'assets/$headKey.png';
  }
}

class AvatarProvider extends ChangeNotifier {
  Avatar? _avatar;
  bool _isLoading = false;
  String? _error;
  Future<void>? _loadingFuture; // Rastrear requisição em andamento

  Avatar? get avatar => _avatar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAvatar() async {
    // Se já há uma requisição em andamento, aguardar ela terminar
    if (_loadingFuture != null) {
      try {
        await _loadingFuture;
        return;
      } catch (e) {
        // Se a requisição anterior falhou, continuar com nova requisição
      }
    }

    _loadingFuture = _loadAvatarInternal();
    try {
      await _loadingFuture;
    } finally {
      _loadingFuture = null;
    }
  }

  Future<void> _loadAvatarInternal() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Endpoint /api/avatar não existe - ir direto para o fallback do perfil
      // Tentar pegar do perfil do usuário (endpoint correto)
      final profileData = await ApiService.getProfile();
      if (profileData['sucesso'] == true && profileData['usuario'] != null) {
        final usuario = profileData['usuario'];
        final nivel = usuario['nivel'] ?? 1;
        final experiencia = usuario['experiencia'] ?? 0;
        
        // Calcular XP necessário para próximo nível baseado no sistema do backend
        // O backend deve fazer o upgrade de nível automaticamente quando XP passa do limite
        // Mas precisamos calcular o XP excedente para exibir corretamente na UI
        
        // Calcular XP total necessário para o próximo nível
        int xpTotalProximoNivel;
        if (nivel < 10) {
          xpTotalProximoNivel = nivel * 100;
        } else if (nivel < 20) {
          xpTotalProximoNivel = (1000 + ((nivel - 10) * 200)).toInt();
        } else if (nivel < 30) {
          xpTotalProximoNivel = (3000 + ((nivel - 20) * 300)).toInt();
        } else if (nivel < 40) {
          xpTotalProximoNivel = (6000 + ((nivel - 30) * 400)).toInt();
        } else {
          xpTotalProximoNivel = (10000 + ((nivel - 40) * 500)).toInt();
        }
        
        // Calcular XP total necessário para o nível atual
        int xpTotalNivelAtual;
        if (nivel <= 1) {
          xpTotalNivelAtual = 0;
        } else if (nivel <= 10) {
          xpTotalNivelAtual = (nivel - 1) * 100;
        } else if (nivel <= 20) {
          xpTotalNivelAtual = (1000 + ((nivel - 11) * 200)).toInt();
        } else if (nivel <= 30) {
          xpTotalNivelAtual = (3000 + ((nivel - 21) * 300)).toInt();
        } else if (nivel <= 40) {
          xpTotalNivelAtual = (6000 + ((nivel - 31) * 400)).toInt();
        } else {
          xpTotalNivelAtual = (10000 + ((nivel - 41) * 500)).toInt();
        }
        
        // Calcular XP necessário para o próximo nível (diferença)
        int experienciaProximoNivel = xpTotalProximoNivel - xpTotalNivelAtual;
        
        // Se o XP passou do limite, calcular o excedente
        // O backend deve fazer o upgrade, mas se não fez, vamos calcular o XP excedente
        int experienciaExibida = experiencia;
        if (experiencia >= xpTotalProximoNivel) {
          // XP passou do limite - o backend deve ter feito upgrade
          // Mas se não fez, vamos calcular o excedente para exibir
          experienciaExibida = experiencia - xpTotalNivelAtual;
          
          // Se ainda passou do limite do próximo nível, calcular excedente
          if (experienciaExibida >= experienciaProximoNivel) {
            experienciaExibida = experienciaExibida % experienciaProximoNivel;
          }
        } else {
          // XP normal - calcular relativo ao nível atual
          experienciaExibida = experiencia - xpTotalNivelAtual;
        }
        
        // Converter personalizacaoAvatar corretamente (pode vir como Map<String, dynamic>)
        Map<String, String> equipamentos = {};
        if (usuario['personalizacaoAvatar'] != null) {
          final personalizacao = usuario['personalizacaoAvatar'];
          if (personalizacao is Map) {
            // Primeiro, extrair campos do custom (head, tema, bodyColor)
            if (personalizacao['custom'] != null && personalizacao['custom'] is Map) {
              final custom = personalizacao['custom'] as Map;
              custom.forEach((key, value) {
                if (key is String && value != null) {
                  equipamentos[key] = value.toString();
                }
              });
            }
            
            // Depois, extrair outros campos diretos
            personalizacao.forEach((key, value) {
              // Ignorar 'custom' pois já processamos acima
              if (key == 'custom') return;
              
              if (key is String && value is String) {
                equipamentos[key] = value;
              } else if (key is String && value != null && value is! Map) {
                equipamentos[key] = value.toString();
              }
            });
          }
        }
        
        _avatar = Avatar(
          nivel: nivel,
          equipamentos: equipamentos,
          efeitos: List<String>.from(usuario['efeitos'] ?? []),
          tema: usuario['tema'] ?? 'default',
          experiencia: experienciaExibida.clamp(0, experienciaProximoNivel),
          experienciaProximoNivel: experienciaProximoNivel,
        );
      } else {
        // Se não conseguir, deixar avatar como null silenciosamente
        _avatar = null;
      }
    } catch (e) {
      // Tratar erro de rate limiting especificamente
      final errorMessage = e.toString();
      if (errorMessage.contains('Muitas requisições') || 
          errorMessage.contains('rate limit') ||
          errorMessage.contains('429')) {
        // Se for rate limiting, manter o avatar atual e não mostrar erro
        print('Rate limit atingido ao carregar avatar. Mantendo dados atuais.');
        // Não atualizar _avatar para manter os dados atuais
      } else {
        // Para outros erros, manter avatar como null silenciosamente
        _avatar = null;
        // Apenas logar o erro em debug, não expor para o usuário
        print('Erro ao carregar avatar: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> evolveAvatar() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.forceAvatarEvolution();
      if (response['sucesso'] == true) {
        await loadAvatar();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao evoluir avatar');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> customizeAvatar(Map<String, dynamic> customization) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.customizeAvatar(customization);
      if (response['sucesso'] == true || response['success'] == true) {
        // Atualizar localmente primeiro para feedback imediato
        if (customization['personalizacaoAvatar'] != null) {
          final personalizacao = customization['personalizacaoAvatar'] as Map<String, dynamic>;
          _avatar ??= Avatar(
            nivel: 1,
            equipamentos: <String, String>{},
            efeitos: <String>[],
            tema: 'default',
            experiencia: 0,
            experienciaProximoNivel: 100,
          );
          
          // Atualizar tema e bodyColor
          if (personalizacao['tema'] != null) {
            _avatar = Avatar(
              nivel: _avatar!.nivel,
              equipamentos: Map<String, String>.from(_avatar!.equipamentos)
                ..addAll(Map<String, String>.from(
                  personalizacao.map((key, value) => MapEntry(key.toString(), value.toString()))
                )),
              efeitos: _avatar!.efeitos,
              tema: personalizacao['tema']?.toString() ?? _avatar!.tema,
              experiencia: _avatar!.experiencia,
              experienciaProximoNivel: _avatar!.experienciaProximoNivel,
            );
          }
        }
        
        // Recarregar do servidor para garantir sincronização
        await loadAvatar();
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao customizar avatar');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> loadAvailableEquipment() async {
    try {
      final equipment = await ApiService.getAvailableEquipment();
      return equipment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> equipItem(String itemId, String itemType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.equipItem(itemId, itemType);
      if (response['sucesso'] == true) {
        await loadAvatar();
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao equipar item');
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

  // Define a cabeça do avatar (apenas aceita chaves que terminam com "_head")
  Future<void> setHead(String headKey) async {
    if (!headKey.endsWith('_head')) {
      return; // ignora entradas inválidas
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Garante que exista um avatar em memória - carregar se não existir
    if (_avatar == null) {
      await loadAvatar();
    }

    // Se ainda não tiver avatar, criar um básico
    _avatar ??= Avatar(
      nivel: 1,
      equipamentos: <String, String>{},
      efeitos: <String>[],
      tema: 'default',
      experiencia: 0,
      experienciaProximoNivel: 100,
    );

    // Atualizar localmente primeiro para feedback imediato
    final oldHead = _avatar!.equipamentos['head'];
    final oldEquipamentos = Map<String, String>.from(_avatar!.equipamentos);
    _avatar!.equipamentos['head'] = headKey;
    
    // Criar nova instância do Avatar para garantir que o headAsset seja recalculado
    _avatar = Avatar(
      nivel: _avatar!.nivel,
      equipamentos: Map<String, String>.from(_avatar!.equipamentos),
      efeitos: List<String>.from(_avatar!.efeitos),
      tema: _avatar!.tema,
      experiencia: _avatar!.experiencia,
      experienciaProximoNivel: _avatar!.experienciaProximoNivel,
    );
    
    notifyListeners();
    
    // Salvar no servidor
    try {
      final response = await ApiService.customizeAvatar({
        'personalizacaoAvatar': {
          ...oldEquipamentos,
          'head': headKey,
        }
      });
      
      if (response['sucesso'] == true || response['success'] == true) {
        // Recarregar avatar do servidor para garantir sincronização completa
        await loadAvatar();
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao salvar');
      }
    } catch (e) {
      // Reverter se falhar
      _avatar = Avatar(
        nivel: _avatar!.nivel,
        equipamentos: oldEquipamentos,
        efeitos: List<String>.from(_avatar!.efeitos),
        tema: _avatar!.tema,
        experiencia: _avatar!.experiencia,
        experienciaProximoNivel: _avatar!.experienciaProximoNivel,
      );
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
