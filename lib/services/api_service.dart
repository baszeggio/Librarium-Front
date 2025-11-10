import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (requiresAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  // ========== AUTH ENDPOINTS ==========
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      print('Tentando fazer login com email: $email');
      print('URL: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'email': email, 'senha': senha}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tempo de conexão excedido. Verifique sua internet.');
        },
      );
      
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        throw Exception('Resposta vazia do servidor');
      }
      
      Map<String, dynamic> decodedResponse;
      try {
        decodedResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      } catch (e) {
        print('Erro ao decodificar JSON: $e');
        print('Response body: $responseBody');
        throw Exception('Resposta inválida do servidor. Tente novamente.');
      }
      
      // Se o status code não for 200-299, tratar como erro
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao fazer login (Status: ${response.statusCode})';
        print('Erro no login: $errorMsg');
        throw Exception(errorMsg);
      }
      
      print('Login bem-sucedido');
      return decodedResponse;
    } catch (e) {
      print('Exceção no login: $e');
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor. Verifique a conexão.');
      }
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        throw Exception('Erro de conexão. Verifique se o servidor está rodando e sua internet está funcionando.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(String nomeUsuario, String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registrar'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'nomeUsuario': nomeUsuario, 'email': email, 'senha': senha}),
      );
      
      final responseBody = response.body;
      if (responseBody.isEmpty) {
        throw Exception('Resposta vazia do servidor');
      }
      
      final decodedResponse = jsonDecode(responseBody) as Map<String, dynamic>;
      
      // Se o status code não for 200-299, tratar como erro
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao registrar (Status: ${response.statusCode})';
        throw Exception(errorMsg);
      }
      
      return decodedResponse;
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor. Verifique a conexão.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/perfil'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 429) {
        // Rate limiting - retornar erro específico
        throw Exception('Muitas requisições, tente novamente mais tarde');
      }
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao carregar perfil';
        throw Exception(errorMsg);
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor. Verifique a conexão.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/perfil'),
        headers: await _getHeaders(),
        body: jsonEncode(profileData),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao atualizar perfil';
        throw Exception(errorMsg);
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor. Verifique a conexão.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> uploadFotoPerfil(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token não encontrado');
      }

      // Otimizar imagem antes do upload
      final optimizedPath = await _optimizeImageForUpload(filePath);

      // Usar multipart para upload de arquivo
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/usuarios/foto-perfil'),
      );

      // Adicionar token de autenticação
      request.headers['Authorization'] = 'Bearer $token';

      // Adicionar arquivo otimizado
      final file = await http.MultipartFile.fromPath('foto', optimizedPath);
      request.files.add(file);

      // Enviar requisição
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao fazer upload da foto';
        throw Exception(errorMsg);
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor.');
      }
      rethrow;
    }
  }

  // Otimiza imagem para upload (compressão + redimensionamento)
  static Future<String> _optimizeImageForUpload(String filePath) async {
    try {
      // Ler arquivo original
      final file = File(filePath);
      final imageBytes = await file.readAsBytes();
      
      // Decodificar imagem
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        return filePath; // Retornar original se não conseguir decodificar
      }

      // Redimensionar se necessário (máximo 800x800)
      const maxSize = 800;
      img.Image resizedImage = originalImage;
      if (originalImage.width > maxSize || originalImage.height > maxSize) {
        final ratio = originalImage.width > originalImage.height
            ? maxSize / originalImage.width
            : maxSize / originalImage.height;
        
        resizedImage = img.copyResize(
          originalImage,
          width: (originalImage.width * ratio).round(),
          height: (originalImage.height * ratio).round(),
          maintainAspect: true,
        );
      }

      // Comprimir para JPEG com qualidade 85%
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Salvar em arquivo temporário
      final tempDir = await Directory.systemTemp;
      final tempFile = File('${tempDir.path}/optimized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      return tempFile.path;
    } catch (e) {
      // Se houver erro na otimização, retornar arquivo original
      print('Erro ao otimizar imagem: $e');
      return filePath;
    }
  }

  static Future<Map<String, dynamic>> removerFotoPerfil() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/foto-perfil'),
        headers: await _getHeaders(),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao remover foto';
        throw Exception(errorMsg);
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verificar'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {'sucesso': false, 'mensagem': 'Token inválido'};
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro ao verificar token'};
    }
  }

  // ========== HABITS ENDPOINTS ==========
  static Future<List<dynamic>> getHabits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/habitos'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return [];
      }
      
      final data = jsonDecode(response.body);
      return data['habitos'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getHabit(String habitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/habitos/$habitId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> habitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habitos'),
      headers: await _getHeaders(),
      body: jsonEncode(habitData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateHabit(String habitId, Map<String, dynamic> habitData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/habitos/$habitId'),
      headers: await _getHeaders(),
      body: jsonEncode(habitData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteHabit(String habitId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/habitos/$habitId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> completeHabit(String habitId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/habitos/$habitId/concluir'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode == 404) {
        throw Exception('Hábito já foi concluído hoje');
      }
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao concluir hábito';
        throw Exception(errorMsg);
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getHabitProgress(String habitId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/habitos/$habitId/progresso'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ========== ACHIEVEMENTS ENDPOINTS ==========
  static Future<List<dynamic>> getAchievements() async {
    try {
      // Tentar primeiro o endpoint de conquistas do usuário
      print('Tentando buscar conquistas do usuário...');
      try {
        final userResponse = await http.get(
          Uri.parse('$baseUrl/usuarios/conquistas'),
          headers: await _getHeaders(),
        );
        
        if (userResponse.statusCode >= 200 && userResponse.statusCode < 300) {
          final userData = jsonDecode(userResponse.body);
          final userAchievements = userData['conquistas'] ?? [];
          if (userAchievements.isNotEmpty) {
            print('Conquistas do usuário encontradas: ${userAchievements.length}');
            return userAchievements;
          }
        }
      } catch (e) {
        print('Erro ao buscar conquistas do usuário: $e');
      }
      
      // Se não encontrar, tentar o endpoint geral
      print('Tentando buscar conquistas gerais...');
      final response = await http.get(
        Uri.parse('$baseUrl/conquistas'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        // Se houver erro HTTP, retornar lista vazia para que o provider use dados mockados
        print('Erro ao buscar conquistas: ${response.statusCode}');
        return [];
      }
      
      final data = jsonDecode(response.body);
      final achievements = data['conquistas'] ?? [];
      print('Conquistas gerais encontradas: ${achievements.length}');
      return achievements;
    } catch (e) {
      if (e is FormatException) {
        print('Erro ao processar resposta de conquistas: $e');
        return [];
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> verifyAchievements() async {
    try {
      print('Chamando endpoint: $baseUrl/conquistas/verificar');
      final response = await http.post(
        Uri.parse('$baseUrl/conquistas/verificar'),
        headers: await _getHeaders(),
      );
      
      print('Status code da verificação: ${response.statusCode}');
      print('Body da resposta: ${response.body}');
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        // Se houver erro HTTP, retornar um mapa indicando que não houve sucesso
        // mas ainda permitir que o provider recarregue as conquistas
        try {
          final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
          print('Erro na verificação: ${decodedResponse['mensagem'] ?? decodedResponse['message']}');
          return {
            'sucesso': false,
            'success': false,
            'mensagem': decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        'Erro ao verificar conquistas',
          };
        } catch (e) {
          print('Erro ao decodificar resposta de erro: $e');
          return {
            'sucesso': false,
            'success': false,
            'mensagem': 'Erro ao verificar conquistas (status ${response.statusCode})',
          };
        }
      }
      
      final decoded = jsonDecode(response.body);
      print('Resposta decodificada: $decoded');
      return decoded as Map<String, dynamic>;
    } catch (e) {
      print('Exceção ao verificar conquistas: $e');
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAchievementStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas/estatisticas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createCustomAchievement(Map<String, dynamic> achievementData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conquistas/personalizada'),
      headers: await _getHeaders(),
      body: jsonEncode(achievementData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markAchievementAsRead(String achievementId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/conquistas/$achievementId/ler'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getAchievementsByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas/categoria/$category'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['conquistas'] ?? [];
  }

  static Future<List<dynamic>> getAchievementsByRarity(String rarity) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas/raridade/$rarity'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['conquistas'] ?? [];
  }

  static Future<Map<String, dynamic>> getAchievementProgress() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas/progresso'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getNextAchievements() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas/proximas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['conquistas'] ?? [];
  }

  // ========== NOTIFICATIONS ENDPOINTS ==========
  static Future<List<dynamic>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notificacoes'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['notificacoes'] ?? [];
  }

  static Future<List<dynamic>> getUnreadNotifications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notificacoes/nao-lidas'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 404) {
        // Endpoint não existe - retornar lista vazia silenciosamente
        return [];
      }
      final data = jsonDecode(response.body);
      return data['notificacoes'] ?? [];
    } catch (e) {
      // Retornar lista vazia em caso de erro
      return [];
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notificacoes/$notificationId/ler'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    final response = await http.put(
      Uri.parse('$baseUrl/notificacoes/marcar-todas-lidas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notificacoes/$notificationId'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> clearOldNotifications() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notificacoes/limpar-antigas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getNotificationStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notificacoes/estatisticas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createScheduledNotification(Map<String, dynamic> notificationData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notificacoes/agendada'),
      headers: await _getHeaders(),
      body: jsonEncode(notificationData),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getScheduledNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notificacoes/agendadas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['notificacoes'] ?? [];
  }

  static Future<Map<String, dynamic>> cancelScheduledNotification(String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notificacoes/$notificationId/cancelar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ========== STATS ENDPOINTS ==========
  static Future<Map<String, dynamic>> getSystemStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estatisticas/sistema'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getWeeklyChart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estatisticas/grafico-semanal'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getCategoryStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estatisticas/categorias'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getHeatmap() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estatisticas/heatmap'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getMonthlyComparison() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estatisticas/comparativo-mensal'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ========== USER ENDPOINTS ==========
  static Future<Map<String, dynamic>> getUserDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/dashboard'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {'sucesso': false, 'mensagem': 'Erro ao carregar dashboard'};
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro ao carregar dashboard'};
    }
  }

  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/estatisticas'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {'sucesso': false, 'mensagem': 'Erro ao carregar estatísticas'};
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'sucesso': false, 'mensagem': 'Erro ao carregar estatísticas'};
    }
  }

  static Future<List<dynamic>> getRanking() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/ranking'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['ranking'] ?? [];
  }

  static Future<List<dynamic>> getUserAchievements() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/conquistas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['conquistas'] ?? [];
  }

  static Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/preferencias'),
      headers: await _getHeaders(),
      body: jsonEncode(preferences),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> evolveAvatar() async {
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/avatar/evoluir'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> customizeAvatar(Map<String, dynamic> customization) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/avatar/customizar'),
        headers: await _getHeaders(),
        body: jsonEncode(customization),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao customizar avatar';
        throw Exception(errorMsg);
      }
      
      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> exportUserData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/exportar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> importUserData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/usuarios/importar'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ========== AVATAR ENDPOINTS ==========
  // Endpoint não existe na API - tratado silenciosamente no provider
  static Future<Map<String, dynamic>> getAvatar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/avatar'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 404) {
        return {'sucesso': false, 'mensagem': 'Endpoint não encontrado'};
      }
      return jsonDecode(response.body);
    } catch (e) {
      return {'sucesso': false, 'mensagem': e.toString()};
    }
  }

  // Usa o endpoint correto de evolução que já existe em evolveAvatar()
  static Future<Map<String, dynamic>> forceAvatarEvolution() async {
    // Usar o endpoint correto que já existe
    return await evolveAvatar();
  }

  static Future<List<dynamic>> getAvailableEquipment() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/avatar/equipamentos'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 404) {
        return [];
      }
      final data = jsonDecode(response.body);
      return data['equipamentos'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> equipItem(String itemId, String itemType) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/avatar/equipar'),
        headers: await _getHeaders(),
        body: jsonEncode({'itemId': itemId, 'tipo': itemType}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'sucesso': false, 'mensagem': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getAvatarHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/avatar/historico'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 404) {
        return {'sucesso': false, 'mensagem': 'Endpoint não encontrado'};
      }
      return jsonDecode(response.body);
    } catch (e) {
      return {'sucesso': false, 'mensagem': e.toString()};
    }
  }

  // ========== MULTIPLAYER ENDPOINTS ==========
  // Batalhas
  static Future<List<dynamic>> getBattles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/batalha'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['batalhas'] ?? [];
  }

  static Future<Map<String, dynamic>> createBattle(Map<String, dynamic> battleData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/batalha/criar'),
      headers: await _getHeaders(),
      body: jsonEncode(battleData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> acceptBattle(String battleId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/batalha/$battleId/aceitar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> finishBattle(String battleId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/batalha/$battleId/finalizar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Desafios
  static Future<List<dynamic>> getChallenges() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/desafio'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['desafios'] ?? [];
  }

  static Future<Map<String, dynamic>> createChallenge(Map<String, dynamic> challengeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/desafio'),
      headers: await _getHeaders(),
      body: jsonEncode(challengeData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> respondToChallenge(String challengeId, Map<String, dynamic> responseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/desafio/$challengeId/responder'),
      headers: await _getHeaders(),
      body: jsonEncode(responseData),
    );
    return jsonDecode(response.body);
  }

  // Mensagens
  static Future<Map<String, dynamic>> sendMessage(Map<String, dynamic> messageData) async {
    try {
      // Converter destinatarioId para destinatario se necessário (backend espera destinatarioId)
      final data = Map<String, dynamic>.from(messageData);
      if (data.containsKey('destinatarioId')) {
        // Mantém destinatarioId como está, pois o backend espera esse campo
      } else if (data.containsKey('destinatario')) {
        data['destinatarioId'] = data['destinatario'];
        data.remove('destinatario');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/multiplayer/mensagem'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMsg = decodedResponse['mensagem'] ?? 
                        decodedResponse['message'] ?? 
                        decodedResponse['erro'] ??
                        decodedResponse['error'] ??
                        'Erro ao enviar mensagem';
        throw Exception(errorMsg);
      }

      return jsonDecode(response.body);
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Erro ao processar resposta do servidor.');
      }
      rethrow;
    }
  }

  static Future<List<dynamic>> getConversation(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/mensagem/conversa/$userId'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['conversa'] ?? [];
  }

  static Future<List<dynamic>> getUnreadMessages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/multiplayer/mensagem/nao-lidas'),
        headers: await _getHeaders(),
      );
      final data = jsonDecode(response.body);
      return data['mensagens'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> markMessageAsRead(String messageId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/multiplayer/mensagem/$messageId/ler'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Amizades
  static Future<Map<String, dynamic>> sendFriendRequest(String usuarioId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/amizade/enviar'),
      headers: await _getHeaders(),
      body: jsonEncode({'usuarioId': usuarioId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> acceptFriendRequest(String amizadeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/amizade/aceitar'),
      headers: await _getHeaders(),
      body: jsonEncode({'amizadeId': amizadeId}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> rejectFriendRequest(String amizadeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/amizade/rejeitar'),
      headers: await _getHeaders(),
      body: jsonEncode({'amizadeId': amizadeId}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getFriends() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/amizade/amigos'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['amigos'] ?? [];
  }

  static Future<List<dynamic>> getPendingFriendRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/amizade/pendentes'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['solicitacoes'] ?? [];
  }

  static Future<List<dynamic>> getSentFriendRequests() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/amizade/enviadas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['solicitacoes'] ?? [];
  }

  static Future<Map<String, dynamic>> removeFriend(String amizadeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/multiplayer/amizade/remover'),
      headers: await _getHeaders(),
      body: jsonEncode({'amizadeId': amizadeId}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/multiplayer/buscar-usuarios?query=${Uri.encodeComponent(query)}'),
        headers: await _getHeaders(),
      );
      
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Erro ao buscar usuários: ${response.statusCode}');
      }
      
      final data = jsonDecode(response.body);
      if (data is Map && data.containsKey('usuarios')) {
        return List<dynamic>.from(data['usuarios'] ?? []);
      }
      return [];
    } catch (e) {
      // Retornar lista vazia em caso de erro para não quebrar a UI
      print('Erro ao buscar usuários: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getMessageStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/mensagem/estatisticas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Ranking e Estatísticas
  static Future<Map<String, dynamic>> getMultiplayerRanking() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/ranking'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data is Map ? Map<String, dynamic>.from(data) : {'ranking': [], 'usuarioAtual': null};
  }

  static Future<Map<String, dynamic>> getMultiplayerStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/estatisticas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ========== INTEGRATIONS ENDPOINTS ==========
  static Future<Map<String, dynamic>> getIntegrationStatus() async {
    final response = await http.get(
      Uri.parse('$baseUrl/integracao/status'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Google Calendar
  static Future<Map<String, dynamic>> initiateGoogleOAuth() async {
    final response = await http.get(
      Uri.parse('$baseUrl/integracao/google/oauth'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> syncGoogleCalendar(Map<String, dynamic> syncData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/integracao/google-calendar/sync'),
      headers: await _getHeaders(),
      body: jsonEncode(syncData),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getGoogleCalendarEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/integracao/google-calendar/eventos'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['eventos'] ?? [];
  }

  static Future<Map<String, dynamic>> disconnectGoogle() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/integracao/google/desconectar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // Google Fit / Saúde
  static Future<Map<String, dynamic>> syncHealthData(Map<String, dynamic> healthData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/integracao/health/sync'),
      headers: await _getHeaders(),
      body: jsonEncode(healthData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getHealthData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/integracao/health/dados'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ========== DATA EXPORT/IMPORT ENDPOINTS ==========
  static Future<Map<String, dynamic>> exportDataJson() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dados/exportar/json'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> exportDataXml() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dados/exportar/xml'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> exportDataZip() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dados/exportar/zip'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> importData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dados/importar'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createBackup() async {
    final response = await http.post(
      Uri.parse('$baseUrl/dados/backup'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> listBackups() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dados/backups'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['backups'] ?? [];
  }

  static Future<Map<String, dynamic>> getExportStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dados/estatisticas'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> validateData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dados/validar'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> clearOldData() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/dados/limpar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> syncData() async {
    final response = await http.post(
      Uri.parse('$baseUrl/dados/sincronizar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getDataConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dados/configuracoes'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateDataConfig(Map<String, dynamic> config) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dados/configuracoes'),
      headers: await _getHeaders(),
      body: jsonEncode(config),
    );
    return jsonDecode(response.body);
  }

  // ========== SHOP ENDPOINTS ==========
  static Future<List<dynamic>> getShopItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/loja'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['itens'] ?? [];
  }

  static Future<Map<String, dynamic>> buyItem(String itemId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loja/comprar'),
      headers: await _getHeaders(),
      body: jsonEncode({'itemId': itemId}),
    );
    return jsonDecode(response.body);
  }
}
