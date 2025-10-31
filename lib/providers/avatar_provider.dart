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
    if (nivel <= 10) return 'Aspirante';
    if (nivel <= 20) return 'Caçador';
    if (nivel <= 30) return 'Guardião do Librarium';
    if (nivel <= 40) return 'Conjurador Supremo';
    return 'Lenda Viva';
  }

  double get progressPercentage {
    if (experienciaProximoNivel == 0) return 1.0;
    return (experiencia / experienciaProximoNivel).clamp(0.0, 1.0);
  }

  // Retorna o asset da cabeça selecionada, se estiver configurado e válido
  String? get headAsset {
    final String? headKey = equipamentos['head'];
    if (headKey == null) return null;
    if (!headKey.endsWith('_head')) return null;
    return 'assets/' + headKey + '.png';
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
      final avatarData = await ApiService.getAvatar();
      
      // Aceitar diferentes formatos de resposta
      if (avatarData['sucesso'] == true || avatarData['success'] == true || avatarData['avatar'] != null) {
        final avatarJson = avatarData['avatar'] ?? avatarData['data'] ?? avatarData;
        final Map<String, dynamic> parsed = Map<String, dynamic>.from(avatarJson as Map);
        _avatar = Avatar.fromJson(parsed);
      } else {
        throw Exception(avatarData['mensagem'] ?? avatarData['message'] ?? 'Erro ao carregar avatar');
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

  // Define a cabeça do avatar (apenas aceita chaves que terminam com "_head")
  Future<void> setHead(String headKey) async {
    if (!headKey.endsWith('_head')) {
      return; // ignora entradas inválidas
    }

    // Garante que exista um avatar em memória
    _avatar ??= Avatar(
      nivel: 1,
      equipamentos: <String, String>{},
      efeitos: <String>[],
      tema: 'default',
      experiencia: 0,
      experienciaProximoNivel: 100,
    );

    _avatar!.equipamentos['head'] = headKey;
    notifyListeners();

    // Salvar no backend
    try {
      await ApiService.updateAvatarEquipament('head', headKey);
      // Recarregar avatar para sincronizar com backend
      await loadAvatar();
    } catch (e) {
      // Se falhar, mantém localmente mas registra erro
      _error = 'Erro ao salvar no servidor: ${e.toString()}';
      notifyListeners();
    }
  }
}
