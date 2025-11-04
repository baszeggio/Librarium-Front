import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/custom_button.dart';
import '../../services/api_service.dart';

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
              Color(0xFF050709),
              Color(0xFF0A0E12),
              Color(0xFF14181C),
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
              // Avatar (foto baseada na cor escolhida na customização)
              Stack(
                children: [
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      final fotoPerfil = authProvider.user?['fotoPerfil'] as String?;
                      return AvatarWidget(
                        avatar: avatarProvider.avatar,
                        size: 100,
                        showLevel: true,
                        fotoPerfilUrl: fotoPerfil,
                      );
                    },
                  ),
                  // Botão para alterar foto
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: Colors.white,
                        onPressed: () => _showFotoPerfilDialog(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Nome do usuário com ID
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final nomeUsuario = authProvider.user?['nomeUsuario'] ?? 
                                    authProvider.user?['nome'] ?? 
                                    'Guerreiro';
                  final userId = authProvider.user?['_id']?.toString() ?? 
                               authProvider.user?['id']?.toString() ?? '';
                  final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;
                  
                  return Column(
                    children: [
                      Text(
                        nomeUsuario,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (shortId.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '#$shortId',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // Título do avatar (priorizar título do backend)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  // Prioridade: 1. Título do usuário (backend), 2. Título calculado do avatar
                  final tituloUsuario = authProvider.user?['titulo'];
                  final tituloAvatar = avatarProvider.avatar?.title;
                  final titulo = tituloUsuario?.toString().isNotEmpty == true
                      ? tituloUsuario.toString()
                      : (tituloAvatar ?? 'Aspirante');
                  return Text(
                    titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
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
                    backgroundColor: const Color(0xFF14181C),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              
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
            icon: Icons.palette,
            title: 'Tema',
            subtitle: 'Personalizar aparência',
            onTap: () {
              _showThemeDialog();
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
            icon: Icons.help,
            title: 'Ajuda',
            subtitle: 'Central de ajuda e suporte',
            onTap: () {
              _showHelpDialog();
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

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Tema',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'O tema escuro está ativo. Personalização de tema estará disponível em breve!',
          style: TextStyle(color: Colors.grey),
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

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Central de Ajuda',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                'Como criar hábitos?',
                'Vá para a seção de Hábitos e clique no botão "+" para criar um novo hábito.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Como completar hábitos?',
                'Clique no card do hábito no dashboard ou na lista de hábitos para marcá-lo como concluído.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'O que é sequência?',
                'A sequência é o número de dias consecutivos que você completou pelo menos um hábito.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Como ganhar XP?',
                'Você ganha XP ao completar hábitos. Cada hábito dá uma quantidade diferente de XP baseada na dificuldade.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Como customizar meu avatar?',
                'Vá em Configurações > Customizar Personagem para escolher a cor do seu personagem.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  void _showFotoPerfilDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Escolher da Galeria', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Tirar Foto', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final temFoto = authProvider.user?['fotoPerfil'] != null;
                if (temFoto) {
                  return ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remover Foto', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      _removerFotoPerfil(context);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );

      if (image != null) {
        // Mostrar dialog de crop/edit
        await _showCropDialog(context, image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCropDialog(BuildContext context, String imagePath) async {
    try {
      // Mostrar loading enquanto processa a imagem
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fazer crop da imagem
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Foto',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Editar Foto',
            aspectRatioLockEnabled: true,
          ),
        ],
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
      );

      // Fechar loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (croppedFile != null) {
        // Fazer upload da imagem cropada
        await _uploadFotoPerfil(context, croppedFile.path);
      } else {
        // Usuário cancelou o crop
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Edição cancelada'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao editar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadFotoPerfil(BuildContext context, String imagePath) async {
    try {
      // Mostrar loading com progresso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Enviando foto...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final response = await ApiService.uploadFotoPerfil(imagePath);

      // Fechar loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response['sucesso'] == true) {
        // Atualizar perfil do usuário
        final authProvider = context.read<AuthProvider>();
        await authProvider.loadProfile();

        // Forçar atualização do widget
        if (context.mounted) {
          setState(() {});
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Foto de perfil atualizada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(response['mensagem'] ?? response['erro'] ?? 'Erro ao fazer upload');
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Erro: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _removerFotoPerfil(BuildContext context) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await ApiService.removerFotoPerfil();

      // Fechar loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response['sucesso'] == true) {
        // Atualizar perfil do usuário
        final authProvider = context.read<AuthProvider>();
        await authProvider.loadProfile();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil removida com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response['mensagem'] ?? 'Erro ao remover foto');
      }
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
