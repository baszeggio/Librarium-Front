import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/avatar_provider.dart';
import '../../widgets/custom_button.dart';

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen>
    with TickerProviderStateMixin {
  String _selectedColor = 'red';
  bool _isSaving = false;
  late AnimationController _animationController;
  late AnimationController _breathingController;
  late Animation<double> _animation;
  late Animation<double> _breathingAnimation;

  final Map<String, String> _colorAssets = {
    'red': 'assets/red_1.png',
    'blue': 'assets/blue_1.png',
    'purple': 'assets/purple_1.png',
    'brown': 'assets/brown_1.png',
    'green': 'assets/green_1.png',
  };

  final Map<String, String> _colorAssets2 = {
    'red': 'assets/red_2.png',
    'blue': 'assets/blue_2.png',
    'purple': 'assets/purple_2.png',
    'brown': 'assets/brown_2.png',
    'green': 'assets/green_2.png',
  };
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentCustomization();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _breathingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animações contínuas
    _breathingController.repeat(reverse: true);
    _animationController.repeat(reverse: true);
  }

  Future<void> _loadCurrentCustomization() async {
    final avatarProvider = context.read<AvatarProvider>();
    await avatarProvider.loadAvatar();
    
    if (avatarProvider.avatar != null) {
      setState(() {
        // Carregar cor do tema ou bodyColor
        final avatar = avatarProvider.avatar!;
        final tema = avatar.tema;
        final bodyColor = avatar.equipamentos['bodyColor'];
        _selectedColor = bodyColor ?? tema ?? 'red';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startAnimation() {}

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
          child: SingleChildScrollView(
            child: Column(
              children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.go('/dashboard');
                        }
                      },
                      child: const Text(
                        'Voltar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Customização do Personagem',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Área do personagem animado
              SizedBox(
                height: 300,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Seu Personagem',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Personagem animado
                      Expanded(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_animation, _breathingAnimation]),
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _breathingAnimation.value * 2), // Movimento sutil de respiração
                                child: Transform.scale(
                                  scale: 1.0 + (_animation.value * 0.1),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Corpo do personagem
                                      Builder(
                                        builder: (context) {
                                          final asset1 = _colorAssets[_selectedColor];
                                          final asset2 = _colorAssets2[_selectedColor];
                                          final currentAsset = (_animationController.value < 0.5)
                                              ? asset1
                                              : asset2;
                                          
                                          if (currentAsset == null) {
                                            return Container(
                                              width: 200,
                                              height: 200,
                                              color: const Color(0xFF14181C),
                                              child: Icon(Icons.error, color: Colors.grey[500], size: 40),
                                            );
                                          }
                                          
                                          return Image.asset(
                                            currentAsset,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                width: 200,
                                                height: 200,
                                                color: Colors.grey[800],
                                                child: Icon(Icons.error, color: Colors.grey[600], size: 40),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Apenas texto informativo (animação contínua)
                      const Text(
                        'Animação ativa',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

              // Seleção de cores
              Container(
                margin: const EdgeInsets.all(16),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Escolha a Cor do Seu Personagem',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Grid de cores - formato horizontal
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _colorAssets.length,
                        itemBuilder: (context, index) {
                          final colorKey = _colorAssets.keys.elementAt(index);
                          final isSelected = _selectedColor == colorKey;
                          final asset1 = _colorAssets[colorKey];
                          final asset2 = _colorAssets2[colorKey];
                          
                          if (asset1 == null || asset2 == null) {
                            return const SizedBox.shrink();
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = colorKey;
                                });
                              },
                              child: Container(
                                width: 70,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                      : const Color(0xFF14181C),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          asset1,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800],
                                              child: Icon(Icons.error, color: Colors.grey[600], size: 20),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getColorName(colorKey),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isSelected ? Colors.white : Colors.grey[400],
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botão de salvar
                    CustomButton(
                      text: _isSaving ? 'Salvando...' : 'Salvar Customização',
                      onPressed: _isSaving ? null : _saveCustomization,
                      isLoading: _isSaving,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomization() async {
    setState(() => _isSaving = true);
    
    try {
      final avatarProvider = context.read<AvatarProvider>();
      
      // Criar objeto de customização correto para a API
      final currentAvatar = avatarProvider.avatar;
      
      // Definir head baseado na cor escolhida (blue -> blue_head, green -> green_head, etc)
      final headKey = '${_selectedColor}_head';
      
      final customization = {
        'personalizacaoAvatar': {
          'tema': _selectedColor,
          'bodyColor': _selectedColor,
          'head': headKey, // Atualizar head baseado na cor escolhida
        }
      };
      
      await avatarProvider.customizeAvatar(customization);
      
      // Forçar recarregamento para garantir que está sincronizado
      await avatarProvider.loadAvatar();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customização salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _getColorName(String colorKey) {
    switch (colorKey) {
      case 'red':
        return 'Vermelho';
      case 'blue':
        return 'Azul';
      case 'purple':
        return 'Roxo';
      case 'brown':
        return 'Marrom';
      case 'green':
        return 'Verde';
      default:
        return colorKey;
    }
  }

}
