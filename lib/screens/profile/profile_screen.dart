import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
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
            ListTile(
              leading: const Icon(Icons.upload_file, color: Colors.orange),
              title: const Text('Upload Direto (sem edição)', style: TextStyle(color: Colors.orange)),
              subtitle: const Text('Use se o editor não abrir', style: TextStyle(color: Colors.grey, fontSize: 12)),
              onTap: () async {
                Navigator.pop(context);
                await _pickImageDirect(context, ImageSource.gallery);
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
        // Android 13+ usa photos, versões antigas usam storage
        if (Platform.isAndroid) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }
      }
      
      var status = await permission.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  source == ImageSource.camera
                      ? 'Permissão de câmera negada'
                      : 'Permissão de galeria negada'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Mostrar loading
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      // Fechar loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (image == null) {
        return;
      }
      
      // Verificar se o arquivo existe
      final file = File(image.path);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Arquivo de imagem não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Garante que contexto está montado antes de continuar
      if (!mounted) return;

      // Abrir cropper - usar this.context para garantir que está usando o contexto do State
      await _showCropDialog(this.context, image.path);
    } catch (e) {
      // Fechar loading se ainda estiver aberto
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Erro ao selecionar imagem: $e'); // Debug
    }
  }

  // Método alternativo: upload direto sem cropper (para debug/teste)
  Future<void> _pickImageDirect(BuildContext context, ImageSource source) async {
    try {
      late Permission permission;
      if (source == ImageSource.camera) {
        permission = Permission.camera;
      } else if (Platform.isIOS) {
        permission = Permission.photos;
      } else {
        if (Platform.isAndroid) {
          permission = Permission.photos;
        } else {
          permission = Permission.storage;
        }
      }
      
      var status = await permission.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  source == ImageSource.camera
                      ? 'Permissão de câmera negada'
                      : 'Permissão de galeria negada'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (image == null) {
        return;
      }
      
      final file = File(image.path);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Arquivo de imagem não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      
      // Upload direto sem cropper
      await _uploadFotoPerfil(context, image.path);
    } catch (e) {
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      print('Erro no upload direto: $e');
    }
  }

  Future<void> _showCropDialog(BuildContext context, String imagePath) async {
    try {
      print('=== INICIANDO CROP DIALOG ===');
      print('Caminho original: $imagePath');
      
      // Verificar se o arquivo existe
      final file = File(imagePath);
      if (!await file.exists()) {
        print('ERRO: Arquivo não existe!');
        if (mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Arquivo de imagem não encontrado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('Arquivo existe, tamanho: ${await file.length()} bytes');

      // Capturar valores do tema usando o contexto do widget (mounted) em vez do parâmetro
      // Isso garante que estamos usando o contexto correto
      Color primaryColor = Colors.blue; // Fallback
      
      if (mounted) {
        try {
          final theme = Theme.of(this.context);
          primaryColor = theme.colorScheme.primary;
          print('Cor primária capturada: $primaryColor');
        } catch (e) {
          print('Aviso: Não foi possível capturar tema, usando fallback: $e');
        }
      } else {
        print('Widget não está montado, usando cor padrão');
      }

      // Usar o caminho original diretamente - ImageCropper deve lidar com isso
      String finalImagePath = imagePath;
      print('Usando caminho: $finalImagePath');

      print('Chamando ImageCropper...');
      print('sourcePath será: $finalImagePath');
      
      // Verificar se o ImageCropper está disponível
      try {
        // Configuração do ImageCropper
        final cropped = await ImageCropper().cropImage(
          sourcePath: finalImagePath,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Editar Foto',
              toolbarColor: primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
            ),
            IOSUiSettings(
              title: 'Editar Foto',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
          compressQuality: 90,
          compressFormat: ImageCompressFormat.jpg,
        );
        
        print('ImageCropper retornou: ${cropped != null ? cropped.path : "null"}');

        if (cropped == null) {
          print('Usuário cancelou a edição');
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('Edição cancelada'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        // Verificar se o arquivo cropped existe
        final croppedFile = File(cropped.path);
        if (!await croppedFile.exists()) {
          print('ERRO: Arquivo editado não existe em: ${cropped.path}');
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(
                content: Text('Erro: Arquivo editado não encontrado'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        print('Imagem editada salva com sucesso em: ${cropped.path}');
        print('Tamanho do arquivo editado: ${await croppedFile.length()} bytes');

        if (!mounted) {
          print('ERRO: Widget não está montado antes do upload');
          return;
        }
        
        await _uploadFotoPerfil(this.context, cropped.path);
      } catch (cropError) {
        // Erro específico do ImageCropper
        print('ERRO no ImageCropper: $cropError');
        rethrow; // Re-lançar para ser capturado pelo catch externo
      }
    } catch (e, stackTrace) {
      print('=== ERRO NO CROP DIALOG ===');
      print('Tipo do erro: ${e.runtimeType}');
      print('Mensagem: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        String errorMessage = 'Erro ao abrir editor de imagem';
        
        if (e.toString().contains('TimeoutException') || e.toString().contains('timeout')) {
          errorMessage = 'O editor demorou muito para abrir. Tente novamente ou reinicie o app.';
        } else if (e.toString().contains('permission') || e.toString().contains('Permission')) {
          errorMessage = 'Permissão negada. Verifique as permissões do app.';
        } else if (e.toString().contains('FileNotFoundException') || e.toString().contains('not found')) {
          errorMessage = 'Arquivo não encontrado. Tente selecionar a imagem novamente.';
        } else {
          errorMessage = 'Erro: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
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
        final avatarProvider = context.read<AvatarProvider>();
        
        // Atualizar perfil do usuário para pegar a nova foto
        await authProvider.loadProfile();
        
        // Recarregar avatar para manter sincronização (embora não seja necessário para a foto)
        await avatarProvider.loadAvatar();

        if (context.mounted) {
          // Forçar rebuild do widget para atualizar a interface
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
        final avatarProvider = context.read<AvatarProvider>();
        
        // Atualizar perfil do usuário para remover a foto
        await authProvider.loadProfile();
        
        // Recarregar avatar para manter sincronização
        await avatarProvider.loadAvatar();

        if (context.mounted) {
          // Forçar rebuild do widget para atualizar a interface
          setState(() {});
          
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
