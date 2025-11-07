import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Message {
  final String id;
  final String remetente;
  final String destinatario;
  final String texto;
  final String tipo;
  final bool lida;
  final DateTime? dataEnvio;

  Message({
    required this.id,
    required this.remetente,
    required this.destinatario,
    required this.texto,
    required this.tipo,
    required this.lida,
    this.dataEnvio,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Suportar tanto objeto populado quanto ID simples
    final remetenteData = json['remetente'];
    final destinatarioData = json['destinatario'];
    
    String remetenteNome = '';
    if (remetenteData is Map) {
      remetenteNome = remetenteData['nomeUsuario'] ?? remetenteData['_id']?.toString() ?? '';
    } else {
      remetenteNome = remetenteData?.toString() ?? '';
    }
    
    String destinatarioNome = '';
    if (destinatarioData is Map) {
      destinatarioNome = destinatarioData['nomeUsuario'] ?? destinatarioData['_id']?.toString() ?? '';
    } else {
      destinatarioNome = destinatarioData?.toString() ?? '';
    }
    
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      remetente: remetenteNome,
      destinatario: destinatarioNome,
      texto: json['texto'] ?? '',
      tipo: json['tipo'] ?? 'privada',
      lida: json['lida'] ?? false,
      dataEnvio: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : (json['dataEnvio'] != null 
              ? DateTime.parse(json['dataEnvio'].toString())
              : null),
    );
  }
}

class MessagesProvider extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Message> get unreadMessages => 
      _messages.where((m) => !m.lida).toList();

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Carregar todas as conversas ou mensagens recebidas
      final messagesData = await ApiService.getUnreadMessages();
      _messages = messagesData
          .map((messageJson) => Message.fromJson(messageJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversation(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final messagesData = await ApiService.getConversation(userId);
      _messages = messagesData
          .map((messageJson) => Message.fromJson(messageJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String destinatarioId,
    required String texto,
    String? tipo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.sendMessage({
        'destinatarioId': destinatarioId,
        'texto': texto,
        if (tipo != null) 'tipo': tipo,
      });

      if (response['sucesso'] == true) {
        // Recarregar conversa após enviar mensagem
        await loadConversation(destinatarioId);
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao enviar mensagem');
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadConversationsList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final messagesData = await ApiService.getUnreadMessages();
      _messages = messagesData
          .map((messageJson) => Message.fromJson(messageJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await ApiService.markMessageAsRead(messageId);
      await loadMessages();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

