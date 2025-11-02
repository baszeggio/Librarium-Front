import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar avatar quando a tela é aberta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvatarProvider>().loadAvatar();
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
              Color(0xFF0D1117),
              Color(0xFF161B22),
              Color(0xFF21262D),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildProfileContent(),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        // Se não pode voltar, vai para dashboard
                        context.go('/dashboard');
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                  ),
              const SizedBox(width: 8),
              Text(
                'Perfil',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Avatar e informações do usuário
          _buildUserInfo(),

          const SizedBox(height: 24),

          // Estatísticas do avatar
          _buildAvatarStats(),

          const SizedBox(height: 24),

          // Configurações
          _buildSettingsSection(),

          const SizedBox(height: 24),

          // Botão de logout
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Consumer<AvatarProvider>(
      builder: (context, avatarProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              // Avatar (toque para escolher cabeça)
              GestureDetector(
                onTap: () => _showHeadPicker(context),
                child: AvatarWidget(
                  avatar: avatarProvider.avatar,
                  size: 100,
                  showLevel: true,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Nome do usuário
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final nomeUsuario = authProvider.user?['nomeUsuario'] ?? 
                                    authProvider.user?['nome'] ?? 
                                    'Guerreiro';
                  return Text(
                    nomeUsuario,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // Título do avatar
              if (avatarProvider.avatar != null)
                Text(
                  avatarProvider.avatar!.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Email
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final email = authProvider.user?['email'] ?? 'Não disponível';
                  return Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHeadPicker(BuildContext context) {
    final Map<String, String> headAssets = const {
      'red_head': 'assets/red_head.png',
      'blue_head': 'assets/blue_head.png',
      'purple_head': 'assets/purple_head.png',
      'brown_head': 'assets/brown_head.png',
      'green_head': 'assets/green_head.png',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escolha sua cabeça',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: headAssets.length,
                itemBuilder: (context, index) {
                  final String key = headAssets.keys.elementAt(index);
                  final String asset = headAssets[key]!;
                  return InkWell(
                    onTap: () async {
                      try {
                        final avatarProvider = context.read<AvatarProvider>();
                        await avatarProvider.setHead(key);
                        
                        // Aguardar um pouco para garantir que o estado foi atualizado
                        await Future.delayed(const Duration(milliseconds: 100));
                        
                        // Forçar recarregamento do avatar
                        await avatarProvider.loadAvatar();
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Foto de perfil atualizada!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao atualizar: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          asset,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarStats() {
    return Consumer<AvatarProvider>(
      builder: (context, avatarProvider, child) {
        if (avatarProvider.avatar == null) {
          return const SizedBox.shrink();
        }

        final avatar = avatarProvider.avatar!;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estatísticas do Avatar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Nível e XP
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Nível',
                      '${avatar.nivel}',
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'XP',
                      '${avatar.experiencia}',
                      Icons.trending_up,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Barra de progresso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso para o próximo nível',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        '${avatar.experiencia}/${avatar.experienciaProximoNivel}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: avatar.progressPercentage,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
              if (avatar.equipamentos.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Equipamentos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...avatar.equipamentos.entries.map((entry) {
                  // Limitar tamanho do texto para evitar overflow
                  String valueStr = entry.value.toString();
                  if (valueStr.length > 30) {
                    valueStr = '${valueStr.substring(0, 27)}...';
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          _getEquipmentIcon(entry.key),
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_getEquipmentName(entry.key)}: $valueStr',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[400],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Gerenciar notificações do app',
            onTap: () {
              _showComingSoonDialog('Notificações');
            },
          ),
          
          _buildSettingItem(
            icon: Icons.palette,
            title: 'Tema',
            subtitle: 'Personalizar aparência',
            onTap: () {
              _showComingSoonDialog('Tema');
            },
          ),
          
          _buildSettingItem(
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Alterar idioma do app',
            onTap: () {
              _showComingSoonDialog('Idioma');
            },
          ),
          
          _buildSettingItem(
            icon: Icons.palette,
            title: 'Customizar Personagem',
            subtitle: 'Personalize a aparência do seu avatar',
            onTap: () {
              context.go('/customization');
            },
          ),
          
          _buildSettingItem(
            icon: Icons.trending_up,
            title: 'Evoluir Avatar',
            subtitle: 'Forçar verificação de evolução',
            onTap: () async {
              try {
                await context.read<AvatarProvider>().evolveAvatar();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar verificado e evoluído!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Ajuda',
            subtitle: 'Central de ajuda e suporte',
            onTap: () {
              _showComingSoonDialog('Ajuda');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400]),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey[400],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[400],
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return CustomButton(
      text: 'Sair da Conta',
      onPressed: () {
        _showLogoutDialog();
      },
      backgroundColor: Colors.red,
      width: double.infinity,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Sair da Conta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          feature,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Esta funcionalidade estará disponível em breve!',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'arma':
        return Icons.sports_mma;
      case 'armadura':
        return Icons.shield;
      case 'acessorio':
        return Icons.star;
      default:
        return Icons.inventory;
    }
  }

  String _getEquipmentName(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'arma':
        return 'Arma';
      case 'armadura':
        return 'Armadura';
      case 'acessorio':
        return 'Acessório';
      default:
        return equipment;
    }
  }
}
