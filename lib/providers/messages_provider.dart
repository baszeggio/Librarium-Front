import 'dart:async';
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
  Timer? _pollingTimer;
  String? _currentConversationUserId;
  bool _isPollingActive = false;

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
      
      // Iniciar polling para esta conversa
      _currentConversationUserId = userId;
      _startPolling(userId);
    } catch (e) {
      _error = e.toString();
      _messages = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling(String userId) {
    // Parar polling anterior se existir
    _stopPolling();
    
    _isPollingActive = true;
    _currentConversationUserId = userId;
    
    // Verificar novas mensagens a cada 2 segundos
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!_isPollingActive || _currentConversationUserId != userId) {
        timer.cancel();
        return;
      }
      
      try {
        final messagesData = await ApiService.getConversation(userId);
        final newMessages = messagesData
            .map((messageJson) => Message.fromJson(messageJson))
            .toList();
        
        // Verificar se há novas mensagens comparando IDs e quantidade
        final currentMessageIds = _messages.map((m) => m.id).toSet();
        final newMessageIds = newMessages.map((m) => m.id).toSet();
        
        // Se houver diferença na quantidade ou nos IDs, atualizar a lista
        bool hasChanges = false;
        if (currentMessageIds.length != newMessageIds.length) {
          hasChanges = true;
        } else {
          // Verificar se há IDs novos
          for (final newId in newMessageIds) {
            if (!currentMessageIds.contains(newId)) {
              hasChanges = true;
              break;
            }
          }
        }
        
        if (hasChanges) {
          _messages = newMessages;
          notifyListeners();
        }
      } catch (e) {
        // Silenciosamente ignorar erros de polling para não interromper a experiência
        // Apenas logar em debug se necessário
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPollingActive = false;
    _currentConversationUserId = null;
  }

  void stopPolling() {
    _stopPolling();
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
    _stopPolling();
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}

