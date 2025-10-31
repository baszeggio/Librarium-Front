import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL padrão; pode ser sobrescrita por --dart-define e/ou SharedPreferences
  static String _baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );
  // Para desenvolvimento local: 'http://localhost:3000/api'

  static Future<String> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_base_url') ?? _baseUrl;
  }

  static Future<void> setApiBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Tratamento robusto de respostas HTTP
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['mensagem'] ?? errorBody['message'] ?? 'Erro HTTP ${response.statusCode}');
      } catch (e) {
        throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
      }
    }
    
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Resposta inválida do servidor: ${e.toString()}');
    }
  }

  // Wrapper para tratar erros de conexão (handshake, SSL, etc)
  static Future<T> _safeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Exception catch (e) {
      final errorMsg = e.toString().toLowerCase();
      
      // Erros de handshake/SSL geralmente indicam tentativa de HTTPS em servidor HTTP
      if (errorMsg.contains('handshake') || 
          errorMsg.contains('ssl') || 
          errorMsg.contains('certificate') ||
          errorMsg.contains('tls') ||
          errorMsg.contains('connection refused')) {
        throw Exception(
          'Erro de conexão. Verifique se o backend está rodando em http://localhost:3000. '
          'Se estiver usando HTTPS, configure o certificado SSL adequadamente.'
        );
      }
      rethrow;
    } catch (e) {
      // Qualquer outro erro de rede
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception(
          'Não foi possível conectar ao servidor. '
          'Verifique se o backend está rodando em http://localhost:3000/api'
        );
      }
      rethrow;
    }
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      // Remove Authorization header para login (não precisa de token ainda)
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': senha, // Backend DW usa 'password', não 'senha'
        }),
      );
      
      // Backend DW retorna { token } diretamente, sem wrapper 'sucesso'
      if (response.statusCode >= 400) {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['message'] ?? errorBody['mensagem'] ?? 'Erro HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
        }
      }
      
      try {
        final data = jsonDecode(response.body);
        // Normalizar resposta: se retornar apenas { token }, adicionar sucesso: true
        if (data['token'] != null && data['sucesso'] == null) {
          return {'sucesso': true, 'token': data['token']};
        }
        return data;
      } catch (e) {
        throw Exception('Resposta inválida do servidor: ${e.toString()}');
      }
    });
  }

  static Future<Map<String, dynamic>> register(String nomeUsuario, String email, String senha) async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      // Remove Authorization header para registro (não precisa de token ainda)
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': senha, // Backend DW usa 'password', não precisa de nomeUsuario
        }),
      );
      
      // Backend DW retorna { message } para registro
      if (response.statusCode >= 400) {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['message'] ?? errorBody['mensagem'] ?? 'Erro HTTP ${response.statusCode}');
        } catch (e) {
          throw Exception('Erro HTTP ${response.statusCode}: ${response.body}');
        }
      }
      
      try {
        final data = jsonDecode(response.body);
        // Backend DW retorna { message } para registro bem-sucedido
        return {'sucesso': true, 'message': data['message'] ?? 'Usuário registrado com sucesso'};
      } catch (e) {
        throw Exception('Resposta inválida do servidor: ${e.toString()}');
      }
    });
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/perfil'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    });
  }

  // Habits endpoints
  static Future<List<dynamic>> getHabits() async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/habitos'),
        headers: await _getHeaders(),
      );
      
      final data = _handleResponse(response);
      return data['habitos'] ?? data['data'] ?? [];
    });
  }

  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> habitData) async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/habitos'),
        headers: await _getHeaders(),
        body: jsonEncode(habitData),
      );
      
      return _handleResponse(response);
    });
  }

  static Future<Map<String, dynamic>> completeHabit(String habitId) async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/habitos/$habitId/concluir'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    });
  }

  // Avatar endpoints
  static Future<Map<String, dynamic>> getAvatar() async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/avatar'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    });
  }

  static Future<Map<String, dynamic>> updateAvatarEquipament(String tipo, String item) async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/avatar/equipar'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'tipo': tipo,
          'item': item,
        }),
      );
      
      return _handleResponse(response);
    });
  }

  // Achievements endpoints
  static Future<List<dynamic>> getAchievements() async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/conquistas'),
        headers: await _getHeaders(),
      );
      
      final data = _handleResponse(response);
      return data['conquistas'] ?? data['data'] ?? [];
    });
  }

  // Stats endpoints
  static Future<Map<String, dynamic>> getStats() async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/estatisticas'),
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    });
  }

  // Multiplayer endpoints
  static Future<List<dynamic>> getBattles() async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/multiplayer/batalha'),
        headers: await _getHeaders(),
      );
      
      final data = _handleResponse(response);
      return data['batalhas'] ?? data['data'] ?? [];
    });
  }

  static Future<Map<String, dynamic>> createBattle(Map<String, dynamic> battleData) async {
    return await _safeRequest(() async {
      final baseUrl = await _getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/multiplayer/batalha'),
        headers: await _getHeaders(),
        body: jsonEncode(battleData),
      );
      
      return _handleResponse(response);
    });
  }
}
