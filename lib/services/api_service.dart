import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://librarium-backend-production.up.railway.app/api';
  // Para desenvolvimento local: 'http://localhost:3000/api'
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );
    
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(String nomeUsuario, String email, String senha) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/registrar'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'nomeUsuario': nomeUsuario,
        'email': email,
        'senha': senha,
      }),
    );
    
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/perfil'),
      headers: await _getHeaders(),
    );
    
    return jsonDecode(response.body);
  }

  // Habits endpoints
  static Future<List<dynamic>> getHabits() async {
    final response = await http.get(
      Uri.parse('$baseUrl/habitos'),
      headers: await _getHeaders(),
    );
    
    final data = jsonDecode(response.body);
    return data['habitos'] ?? [];
  }

  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> habitData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habitos'),
      headers: await _getHeaders(),
      body: jsonEncode(habitData),
    );
    
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> completeHabit(String habitId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/habitos/$habitId/concluir'),
      headers: await _getHeaders(),
    );
    
    return jsonDecode(response.body);
  }

  // Avatar endpoints
  static Future<Map<String, dynamic>> getAvatar() async {
    final response = await http.get(
      Uri.parse('$baseUrl/avatar'),
      headers: await _getHeaders(),
    );
    
    return jsonDecode(response.body);
  }

  // Achievements endpoints
  static Future<List<dynamic>> getAchievements() async {
    final response = await http.get(
      Uri.parse('$baseUrl/conquistas'),
      headers: await _getHeaders(),
    );
    
    final data = jsonDecode(response.body);
    return data['conquistas'] ?? [];
  }

  // Stats endpoints
  static Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/estatisticas'),
      headers: await _getHeaders(),
    );
    
    return jsonDecode(response.body);
  }

  // Multiplayer endpoints
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
      Uri.parse('$baseUrl/multiplayer/batalha'),
      headers: await _getHeaders(),
      body: jsonEncode(battleData),
    );
    
    return jsonDecode(response.body);
  }
}
