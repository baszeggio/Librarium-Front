import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get token => _token;

  Future<void> login(String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, senha);
      
      if (response['sucesso'] == true) {
        _token = response['token'];
        _user = response['usuario'];
        _isAuthenticated = true;
        
        // Salvar token no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', response['usuario'].toString());
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao fazer login');
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String nomeUsuario, String email, String senha) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(nomeUsuario, email, senha);
      
      if (response['sucesso'] == true) {
        _token = response['token'];
        _user = response['usuario'];
        _isAuthenticated = true;
        
        // Salvar token no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', response['usuario'].toString());
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao registrar');
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    _token = null;
    
    // Remover token do SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userString = prefs.getString('user');
    
    if (token != null && userString != null) {
      _token = token;
      _isAuthenticated = true;
      // Aqui você pode fazer uma chamada para verificar se o token ainda é válido
      try {
        final userData = await ApiService.getProfile();
        if (userData['sucesso'] == true) {
          _user = userData['usuario'];
        } else {
          await logout();
        }
      } catch (e) {
        await logout();
      }
    }
    
    notifyListeners();
  }
}
