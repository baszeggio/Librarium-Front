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
    return Message(
      id: json['_id'] ?? json['id'] ?? '',
      remetente: json['remetente']?['nomeUsuario'] ?? json['remetente'] ?? '',
      destinatario: json['destinatario']?['nomeUsuario'] ?? json['destinatario'] ?? '',
      texto: json['texto'] ?? '',
      tipo: json['tipo'] ?? 'geral',
      lida: json['lida'] ?? false,
      dataEnvio: json['dataEnvio'] != null 
          ? DateTime.parse(json['dataEnvio'])
          : null,
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
        'destinatario': destinatarioId,
        'texto': texto,
        if (tipo != null) 'tipo': tipo,
      });

      if (response['sucesso'] == true) {
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

  Future<void> markAsRead(String messageId) async {
    try {
      await ApiService.markMessageAsRead(messageId);
      await loadMessages();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

