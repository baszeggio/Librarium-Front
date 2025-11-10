import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Friend {
  final String id;
  final String amizadeId;
  final String nomeUsuario;
  final int nivel;
  final int experiencia;
  final String titulo;
  final Map<String, dynamic>? avatar;
  final String? fotoPerfil;
  final DateTime? ultimaAtividade;
  final DateTime? dataAmizade;

  Friend({
    required this.id,
    required this.amizadeId,
    required this.nomeUsuario,
    required this.nivel,
    required this.experiencia,
    required this.titulo,
    this.avatar,
    this.fotoPerfil,
    this.ultimaAtividade,
    this.dataAmizade,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['_id'] ?? json['id'] ?? '',
      amizadeId: json['amizadeId'] ?? json['_id'] ?? '',
      nomeUsuario: json['nomeUsuario'] ?? '',
      nivel: json['nivel'] ?? 1,
      experiencia: json['experiencia'] ?? 0,
      titulo: json['titulo'] ?? 'Aspirante',
      avatar: json['avatar'] as Map<String, dynamic>?,
      fotoPerfil: json['fotoPerfil'] as String?,
      ultimaAtividade: json['ultimaAtividade'] != null 
          ? DateTime.parse(json['ultimaAtividade'].toString())
          : null,
      dataAmizade: json['dataAmizade'] != null
          ? DateTime.parse(json['dataAmizade'].toString())
          : null,
    );
  }
}

class FriendRequest {
  final String id;
  final String nomeUsuario;
  final int nivel;
  final Map<String, dynamic>? avatar;
  final String? fotoPerfil;
  final DateTime dataSolicitacao;
  final String solicitadoPor;

  FriendRequest({
    required this.id,
    required this.nomeUsuario,
    required this.nivel,
    this.avatar,
    this.fotoPerfil,
    required this.dataSolicitacao,
    required this.solicitadoPor,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    // Garantir que usuario seja um Map
    dynamic usuarioData = json['usuario1'] ?? json['usuario2'] ?? json['usuario'] ?? {};
    Map<String, dynamic> usuario;
    if (usuarioData is Map) {
      usuario = Map<String, dynamic>.from(usuarioData);
    } else {
      usuario = {};
    }
    
    // Converter nivel para int se necessário
    int nivelValue = 1;
    if (usuario['nivel'] != null) {
      if (usuario['nivel'] is int) {
        nivelValue = usuario['nivel'] as int;
      } else if (usuario['nivel'] is String) {
        nivelValue = int.tryParse(usuario['nivel'] as String) ?? 1;
      } else if (usuario['nivel'] is num) {
        nivelValue = (usuario['nivel'] as num).toInt();
      }
    }
    
    // Tratar solicitadoPor
    String solicitadoPorId = '';
    if (json['solicitadoPor'] != null) {
      if (json['solicitadoPor'] is Map) {
        solicitadoPorId = json['solicitadoPor']?['_id'] ?? json['solicitadoPor']?['id'] ?? '';
      } else if (json['solicitadoPor'] is String) {
        solicitadoPorId = json['solicitadoPor'] as String;
      }
    }
    
    return FriendRequest(
      id: json['_id'] ?? json['id'] ?? '',
      nomeUsuario: usuario['nomeUsuario'] ?? '',
      nivel: nivelValue,
      avatar: usuario['avatar'] is Map ? Map<String, dynamic>.from(usuario['avatar'] as Map) : null,
      fotoPerfil: usuario['fotoPerfil'] as String?,
      dataSolicitacao: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      solicitadoPor: solicitadoPorId,
    );
  }
}

class FriendsProvider extends ChangeNotifier {
  List<Friend> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  List<FriendRequest> _sentRequests = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  List<FriendRequest> get sentRequests => _sentRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get friendsCount => _friends.length;
  int get pendingRequestsCount => _pendingRequests.length;

  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final friendsData = await ApiService.getFriends();
      _friends = friendsData
          .map((friendJson) => Friend.fromJson(friendJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _friends = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPendingRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final requestsData = await ApiService.getPendingFriendRequests();
      _pendingRequests = requestsData
          .map((requestJson) => FriendRequest.fromJson(requestJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _pendingRequests = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSentRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final requestsData = await ApiService.getSentFriendRequests();
      _sentRequests = requestsData
          .map((requestJson) => FriendRequest.fromJson(requestJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _sentRequests = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadFriends(),
      loadPendingRequests(),
      loadSentRequests(),
    ]);
  }

  Future<void> sendFriendRequest(String usuarioId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.sendFriendRequest(usuarioId);
      await loadSentRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptFriendRequest(String amizadeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.acceptFriendRequest(amizadeId);
      await loadAll();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectFriendRequest(String amizadeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.rejectFriendRequest(amizadeId);
      await loadPendingRequests();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFriend(String amizadeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.removeFriend(amizadeId);
      await loadFriends();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      return await ApiService.searchUsers(query);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

