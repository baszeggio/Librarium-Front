import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: await _getHeaders(requiresAuth: false),
        body: jsonEncode({'email': email, 'senha': senha}),
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
                        'Erro ao fazer login (Status: ${response.statusCode})';
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
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['conquistas'] ?? [];
  }

  static Future<Map<String, dynamic>> verifyAchievements() async {
    final response = await http.post(
      Uri.parse('$baseUrl/conquistas/verificar'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
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
    final response = await http.post(
      Uri.parse('$baseUrl/multiplayer/mensagem'),
      headers: await _getHeaders(),
      body: jsonEncode(messageData),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getConversation(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/mensagem/conversa/$userId'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['mensagens'] ?? [];
  }

  static Future<Map<String, dynamic>> markMessageAsRead(String messageId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/multiplayer/mensagem/$messageId/ler'),
      headers: await _getHeaders(),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getUnreadMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/multiplayer/mensagem/nao-lidas'),
      headers: await _getHeaders(),
    );
    final data = jsonDecode(response.body);
    return data['mensagens'] ?? [];
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
