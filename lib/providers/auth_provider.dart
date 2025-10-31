import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
      
      if (response['sucesso'] == true && response['token'] != null) {
        _token = response['token'];
        // Backend DW pode não retornar 'usuario', apenas token
        _user = response['usuario'] ?? {'email': email};
        _isAuthenticated = true;
        
        // Salvar token no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user));
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao fazer login');
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
      
      // Backend DW apenas retorna mensagem de sucesso no registro, não token
      // O usuário precisa fazer login após registro
      if (response['sucesso'] == true) {
        // Não autentica automaticamente após registro (como no DW original)
        // Apenas mostra sucesso e redireciona para login
      } else {
        throw Exception(response['mensagem'] ?? response['message'] ?? 'Erro ao registrar');
      }
    } catch (e) {
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
      try {
        // Tentar deserializar o usuário salvo
        _user = jsonDecode(userString);
      } catch (e) {
        // Se falhar, tentar recarregar do servidor
      }
      
      // Verificar se o token ainda é válido
      try {
        final userData = await ApiService.getProfile();
        if (userData['sucesso'] == true || userData['usuario'] != null) {
          _user = userData['usuario'] ?? userData['user'];
          // Atualizar usuário salvo
          await prefs.setString('user', jsonEncode(_user));
        } else {
          await logout();
        }
      } catch (e) {
        // Se falhar, mantém autenticado mas usa dados locais
        if (_user == null) {
          await logout();
        }
      }
    }
    
    notifyListeners();
  }
}
