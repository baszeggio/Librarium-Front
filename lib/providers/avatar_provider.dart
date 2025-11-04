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
    return (experiencia / experienciaProximoNivel).clamp(0.0, 1.0);
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

  Avatar? get avatar => _avatar;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAvatar() async {
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
        // Nível 1-10: 100 XP por nível
        // Nível 11-20: 200 XP por nível  
        // Nível 21-30: 300 XP por nível
        // Nível 31-40: 400 XP por nível
        // Nível 41+: 500 XP por nível
        int experienciaProximoNivel = 100;
        if (nivel < 10) {
          experienciaProximoNivel = 100; // XP necessário para passar do nível atual para o próximo
        } else if (nivel < 20) {
          experienciaProximoNivel = 200;
        } else if (nivel < 30) {
          experienciaProximoNivel = 300;
        } else if (nivel < 40) {
          experienciaProximoNivel = 400;
        } else {
          experienciaProximoNivel = 500;
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
          experiencia: experiencia,
          experienciaProximoNivel: experienciaProximoNivel,
        );
      } else {
        // Se não conseguir, deixar avatar como null silenciosamente
        _avatar = null;
      }
    } catch (e) {
      // Não mostrar erro - apenas deixar avatar como null
      _avatar = null;
      // Apenas logar o erro em debug, não expor para o usuário
      print('Erro ao carregar avatar (endpoint pode não existir): $e');
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
