import 'package:flutter/material.dart';
import '../providers/avatar_provider.dart';

class AvatarWidget extends StatelessWidget {
  final Avatar? avatar;
  final double size;
  final bool showLevel;
  final bool showProgress;

  const AvatarWidget({
    super.key,
    this.avatar,
    this.size = 60,
    this.showLevel = true,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: (avatar!.headAsset != null)
                      ? SizedBox(
                          width: (size - 8) * 0.7,
                          height: (size - 8) * 0.7,
                          child: Image.asset(
                            avatar!.headAsset!,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          _getAvatarIcon(avatar!.nivel),
                          size: size * 0.5,
                          color: Colors.white,
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
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[800],
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
