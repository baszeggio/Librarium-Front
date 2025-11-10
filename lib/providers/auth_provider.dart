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
      // Limpar dados antigos antes de tentar login
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      
      final response = await ApiService.login(email, senha);
      
      // Verificar tanto 'sucesso' quanto 'success'
      final sucesso = response['sucesso'] == true || response['success'] == true;
      
      if (sucesso) {
        _token = response['token'];
        _user = response['usuario'] ?? response['user'];
        _isAuthenticated = true;
        
        // Salvar token no SharedPreferences
        if (_token != null) {
          await prefs.setString('token', _token!);
        }
        if (_user != null) {
          await prefs.setString('user', jsonEncode(_user));
        }
      } else {
        final errorMsg = response['mensagem'] ?? 
                        response['message'] ?? 
                        response['erro'] ??
                        response['error'] ??
                        'Erro ao fazer login';
        throw Exception(errorMsg);
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      
      // Garantir que dados estão limpos
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user');
      } catch (_) {}
      
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
      // Limpar dados antigos antes de tentar registrar
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      
      final response = await ApiService.register(nomeUsuario, email, senha);
      
      // Verificar tanto 'sucesso' quanto 'success'
      final sucesso = response['sucesso'] == true || response['success'] == true;
      
      if (sucesso) {
        _token = response['token'];
        _user = response['usuario'] ?? response['user'];
        _isAuthenticated = true;
        
        // Salvar token no SharedPreferences
        if (_token != null) {
          await prefs.setString('token', _token!);
        }
        if (_user != null) {
          await prefs.setString('user', jsonEncode(_user));
        }
      } else {
        final errorMsg = response['mensagem'] ?? 
                        response['message'] ?? 
                        response['erro'] ??
                        response['error'] ??
                        'Erro ao registrar';
        throw Exception(errorMsg);
      }
    } catch (e) {
      _isAuthenticated = false;
      _user = null;
      _token = null;
      
      // Garantir que dados estão limpos
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        await prefs.remove('user');
      } catch (_) {}
      
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
          final sucesso = userData['sucesso'] == true || userData['success'] == true;
          final usuario = userData['usuario'] ?? userData['user'];
          
          if (sucesso && usuario != null) {
            _user = usuario;
            _isAuthenticated = true;
            
            // Atualizar dados do usuário no SharedPreferences
            await prefs.setString('user', jsonEncode(usuario));
          } else {
            // Token inválido, limpar dados
            await logout();
          }
        } catch (e) {
          // Verificar se é erro de autenticação (401/403) ou apenas erro de validação (400)
          bool isAuthError = false;
          
          // Verificar se é ApiHttpException com status code de autenticação
          if (e is ApiHttpException) {
            isAuthError = e.isAuthError; // 401 ou 403
          } else {
            // Verificar pela mensagem de erro
            final errorString = e.toString().toLowerCase();
            isAuthError = errorString.contains('401') || 
                         errorString.contains('403') ||
                         errorString.contains('unauthorized') ||
                         errorString.contains('forbidden') ||
                         errorString.contains('token inválido') ||
                         errorString.contains('token expirado') ||
                         errorString.contains('invalid token');
          }
          
          // Só fazer logout se for erro de autenticação
          // Erros 400 (Bad Request) não devem desconectar o usuário
          if (isAuthError) {
            print('Erro de autenticação detectado (401/403), fazendo logout: $e');
            await logout();
          } else {
            // Erro 400 ou outro erro não relacionado à autenticação
            // Manter usuário logado, apenas carregar dados do storage se existirem
            print('Erro não relacionado à autenticação (400 ou outro), mantendo sessão: $e');
            try {
              final userJson = prefs.getString('user');
              if (userJson != null) {
                _user = jsonDecode(userJson);
                _isAuthenticated = true;
              } else {
                // Se não tem dados salvos, mas tem token, manter autenticado
                _isAuthenticated = true;
              }
            } catch (_) {
              // Se não conseguir carregar do storage, manter token mas sem dados do usuário
              _isAuthenticated = true; // Token existe, então está autenticado
            }
          }
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

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.getProfile();
      
      if (response['sucesso'] == true && response['usuario'] != null) {
        _user = response['usuario'];
        
        // Salvar usuário atualizado no storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user));
        
        _isAuthenticated = true;
      }
    } catch (e) {
      // Se erro, não alterar estado
      print('Erro ao carregar perfil: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
