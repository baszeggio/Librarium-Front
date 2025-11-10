import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
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
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
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
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
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
          _buildUserInfo(),
          const SizedBox(height: 24),
          _buildAvatarStats(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Consumer2<AuthProvider, AvatarProvider>(
      builder: (context, authProvider, avatarProvider, child) {
        final fotoPerfil = authProvider.user?['fotoPerfil'] as String?;
        final nomeUsuario = authProvider.user?['nomeUsuario'] ??
            authProvider.user?['nome'] ??
            'Guerreiro';
        final userId = authProvider.user?['_id']?.toString() ??
            authProvider.user?['id']?.toString() ??
            '';
        final shortId = userId.length > 8 ? userId.substring(0, 8) : userId;
        final email = authProvider.user?['email'] ?? 'Não disponível';
        final tituloUsuario = authProvider.user?['titulo'] ?? 'Aspirante';

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
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AvatarWidget(
                      avatar: avatarProvider.avatar,
                      size: 100,
                      showLevel: true,
                      fotoPerfilUrl: fotoPerfil,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                nomeUsuario,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (shortId.isNotEmpty)
                Text(
                  '#$shortId',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[400],
                        fontFamily: 'monospace',
                      ),
                ),
              const SizedBox(height: 8),
              Text(
                tituloUsuario,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showFotoPerfilDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  label: const Text(
                    'Alterar Foto',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.white70),
            title: const Text(
              'Segurança da Conta',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Gerencie senha e autenticação',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            onTap: () {
              // exemplo: context.go('/seguranca');
            },
          ),
        ],
      ),
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
              onTap: () async {
                Navigator.pop(context); // fecha o bottomsheet antes de aguardar
                await _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Tirar Foto', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(context, ImageSource.camera);
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
      // Garantir permissões corretas e await de Navigator.pop()
      late Permission permission;
      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else if (Platform.isIOS) {
        permission = Permission.photos; // iOS uses "photos"
      } else {
        permission = Permission.storage; // Android 13+: use storage
      }
      var status = await permission.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                source == ImageSource.camera
                    ? 'Permissão de câmera negada'
                    : 'Permissão de galeria negada'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image == null) {
        return;
      }
      // Garante que contexto está montado antes de continuar
      if (!mounted) return;

      // Abrir cropper
      await _showCropDialog(context, image.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCropDialog(BuildContext context, String imagePath) async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Foto',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Editar Foto',
            aspectRatioLockEnabled: true,
          ),
        ],
        compressQuality: 90,
        compressFormat: ImageCompressFormat.jpg,
      );

      if (cropped == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Edição cancelada')),
          );
        }
        return;
      }

      if (!context.mounted) return;
      await _uploadFotoPerfil(context, cropped.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar imagem: $e')),
        );
      }
    }
  }

  Future<void> _uploadFotoPerfil(BuildContext context, String imagePath) async {
    if (_isUploading) return;
    _isUploading = true;
    try {
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

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response['sucesso'] == true) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.loadProfile();

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
    } finally {
      _isUploading = false;
    }
  }

  Future<void> _removerFotoPerfil(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final response = await ApiService.removerFotoPerfil();

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (response['sucesso'] == true) {
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
