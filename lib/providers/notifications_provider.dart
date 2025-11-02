import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Notification {
  final String id;
  final String tipo;
  final String titulo;
  final String mensagem;
  final bool lida;
  final DateTime? dataLeitura;
  final String prioridade;
  final DateTime? agendadaPara;
  final Map<String, dynamic>? dados;

  Notification({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensagem,
    required this.lida,
    this.dataLeitura,
    required this.prioridade,
    this.agendadaPara,
    this.dados,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'] ?? json['id'] ?? '',
      tipo: json['tipo'] ?? 'geral',
      titulo: json['titulo'] ?? '',
      mensagem: json['mensagem'] ?? '',
      lida: json['lida'] ?? false,
      dataLeitura: json['dataLeitura'] != null 
          ? DateTime.parse(json['dataLeitura'])
          : null,
      prioridade: json['prioridade'] ?? 'normal',
      agendadaPara: json['agendadaPara'] != null
          ? DateTime.parse(json['agendadaPara'])
          : null,
      dados: json['dados'],
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Notification> get unreadNotifications => 
      _notifications.where((n) => !n.lida).toList();
  
  List<Notification> get readNotifications => 
      _notifications.where((n) => n.lida).toList();

  int get unreadCount => unreadNotifications.length;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notificationsData = await ApiService.getNotifications();
      _notifications = notificationsData
          .map((notificationJson) => Notification.fromJson(notificationJson))
          .toList();
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadNotifications() async {
    try {
      // Endpoint pode não existir - tratar silenciosamente
      final notificationsData = await ApiService.getUnreadNotifications();
      final unread = notificationsData
          .map((notificationJson) => Notification.fromJson(notificationJson))
          .toList();
      
      // Adicionar notificações não lidas à lista completa
      bool hasNewNotifications = false;
      for (final notification in unread) {
        if (!_notifications.any((n) => n.id == notification.id)) {
          _notifications.add(notification);
          hasNewNotifications = true;
        }
      }
      
      if (hasNewNotifications || notificationsData.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      // Endpoint não existe - tratar silenciosamente, não mostrar erro
      // Tentar carregar todas as notificações como fallback
      try {
        await loadNotifications();
      } catch (loadError) {
        print('Erro ao carregar notificações: $loadError');
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = Notification(
          id: _notifications[index].id,
          tipo: _notifications[index].tipo,
          titulo: _notifications[index].titulo,
          mensagem: _notifications[index].mensagem,
          lida: true,
          dataLeitura: DateTime.now(),
          prioridade: _notifications[index].prioridade,
          agendadaPara: _notifications[index].agendadaPara,
          dados: _notifications[index].dados,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead();
      _notifications = _notifications.map((notification) {
        return Notification(
          id: notification.id,
          tipo: notification.tipo,
          titulo: notification.titulo,
          mensagem: notification.mensagem,
          lida: true,
          dataLeitura: DateTime.now(),
          prioridade: notification.prioridade,
          agendadaPara: notification.agendadaPara,
          dados: notification.dados,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await ApiService.deleteNotification(notificationId);
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearOldNotifications() async {
    try {
      await ApiService.clearOldNotifications();
      await loadNotifications();
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

