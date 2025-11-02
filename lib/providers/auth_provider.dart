import 'dart:convert';
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
        if (response['usuario'] != null) {
          await prefs.setString('user', jsonEncode(response['usuario']));
        }
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
        if (response['usuario'] != null) {
          await prefs.setString('user', jsonEncode(response['usuario']));
        }
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

  Future<void> initialize() async {
    await loadUserFromStorage();
  }

  Future<void> loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token != null) {
        _token = token;
        // Verificar se o token ainda é válido fazendo uma chamada ao servidor
        try {
          final userData = await ApiService.getProfile();
          if (userData['sucesso'] == true && userData['usuario'] != null) {
            _user = userData['usuario'];
            _isAuthenticated = true;
            
            // Atualizar dados do usuário no SharedPreferences
            if (userData['usuario'] != null) {
              await prefs.setString('user', jsonEncode(userData['usuario']));
            }
          } else {
            // Token inválido, limpar dados
            await logout();
          }
        } catch (e) {
          // Erro ao verificar token, limpar dados
          await logout();
        }
      } else {
        _isAuthenticated = false;
        _token = null;
        _user = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
