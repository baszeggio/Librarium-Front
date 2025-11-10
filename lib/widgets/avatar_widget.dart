import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/avatar_provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AvatarWidget extends StatelessWidget {
  final Avatar? avatar;
  final double size;
  final bool showLevel;
  final bool showProgress;
  final String? fotoPerfilUrl; // URL da foto de perfil

  const AvatarWidget({
    super.key,
    this.avatar,
    this.size = 60,
    this.showLevel = true,
    this.showProgress = false,
    this.fotoPerfilUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Usar Consumer para escutar mudanças do AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Obter foto de perfil do AuthProvider se não fornecida
        final fotoPerfil = fotoPerfilUrl ?? 
            (authProvider.user?['fotoPerfil'] as String?);
        
        // Se tiver foto de perfil, mostrar ela (prioridade sobre avatar)
        if (fotoPerfil != null && fotoPerfil.isNotEmpty) {
          // Construir URL completa - pode vir já completa ou apenas o path
          String fotoUrl = fotoPerfil;
          if (!fotoPerfil.startsWith('http://') && !fotoPerfil.startsWith('https://')) {
            // Se não começar com http, adicionar o baseUrl (removendo /api)
            final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
            fotoUrl = '$baseUrl$fotoPerfil';
          }
          
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                // Adicionar query parameter para cache busting (usa timestamp completo para garantir atualização imediata)
                '$fotoUrl?t=${DateTime.now().millisecondsSinceEpoch}',
                width: size,
                height: size,
                fit: BoxFit.cover,
                cacheWidth: size.toInt(),
                cacheHeight: size.toInt(),
                errorBuilder: (context, error, stackTrace) {
                  // Se erro ao carregar, mostrar avatar padrão
                  return _buildDefaultAvatar(context);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: size,
                    height: size,
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        
        // Se não tiver foto de perfil, mostrar avatar padrão
        if (avatar == null) {
          return _buildPlaceholder(context);
        }

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Avatar principal (imagem de cabeça se disponível, senão ícone)
              Center(
                child: Container(
                  width: size - 8,
                  height: size - 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: ClipOval(
                      child: Builder(
                        builder: (context) {
                          final headAsset = avatar!.headAsset;
                          if (headAsset != null) {
                            return SizedBox(
                              width: (size - 8) * 0.7,
                              height: (size - 8) * 0.7,
                              child: Image.asset(
                                headAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    _getAvatarIcon(avatar!.nivel),
                                    size: size * 0.5,
                                    color: Colors.white,
                                  );
                                },
                              ),
                            );
                          }
                          return Icon(
                            _getAvatarIcon(avatar!.nivel),
                            size: size * 0.5,
                            color: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Nível do avatar
              if (showLevel)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${avatar!.nivel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              // Efeitos especiais
              if (avatar!.efeitos.isNotEmpty)
                ...avatar!.efeitos.map((efeito) => _buildEffect(efeito)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    if (avatar == null) {
      return _buildPlaceholder(context);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Icon(
        _getAvatarIcon(avatar!.nivel),
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF14181C),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildEffect(String efeito) {
    // Aqui você pode implementar efeitos visuais específicos
    // baseados no tipo de efeito
    return Container();
  }

  IconData _getAvatarIcon(int nivel) {
    if (nivel <= 10) return Icons.person;
    if (nivel <= 20) return Icons.auto_awesome;
    if (nivel <= 30) return Icons.star;
    if (nivel <= 40) return Icons.workspace_premium;
    return Icons.emoji_events;
  }
}
