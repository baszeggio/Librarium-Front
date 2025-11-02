import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifications_provider.dart' hide Notification;
import '../../providers/notifications_provider.dart' as notifications;
import '../../widgets/custom_button.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050709),
              Color(0xFF0A0E12),
              Color(0xFF14181C),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, child) {
              if (notificationsProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (notificationsProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar notificações',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Tentar Novamente',
                        onPressed: () {
                          notificationsProvider.loadNotifications();
                        },
                      ),
                    ],
                  ),
                );
              }

              return _buildNotificationsList(notificationsProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(NotificationsProvider provider) {
    final unread = provider.unreadNotifications;
    final read = provider.readNotifications;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Notificações',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (provider.unreadCount > 0)
                TextButton.icon(
                  onPressed: () async {
                    await provider.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Todas as notificações foram marcadas como lidas'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Marcar todas como lidas'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),

        // Lista
        Expanded(
          child: provider.notifications.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (unread.isNotEmpty) ...[
                      _buildSectionTitle('Não Lidas (${unread.length})'),
                      const SizedBox(height: 8),
                      ...unread.map((notification) => 
                        _buildNotificationCard(notification, provider, isUnread: true)
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (read.isNotEmpty) ...[
                      _buildSectionTitle('Lidas'),
                      const SizedBox(height: 8),
                      ...read.map((notification) => 
                        _buildNotificationCard(notification, provider, isUnread: false)
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.grey[400],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    notifications.Notification notification,
    NotificationsProvider provider, {
    required bool isUnread,
  }) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        provider.deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            width: isUnread ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getNotificationIcon(notification.tipo),
              color: isUnread 
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.mensagem,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[300],
                    ),
                  ),
                  if (notification.agendadaPara != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(notification.agendadaPara!),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread)
              IconButton(
                icon: const Icon(Icons.circle, size: 12),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  provider.markAsRead(notification.id);
                },
                tooltip: 'Marcar como lida',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma notificação',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você está em dia! Não há notificações no momento.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'conquista':
      case 'achievement':
        return Icons.emoji_events;
      case 'habito':
      case 'habit':
        return Icons.check_circle;
      case 'batalha':
      case 'battle':
        return Icons.sports_esports;
      case 'mensagem':
      case 'message':
        return Icons.message;
      case 'nivel':
      case 'level':
        return Icons.trending_up;
      default:
        return Icons.notifications;
    }
  }
}

