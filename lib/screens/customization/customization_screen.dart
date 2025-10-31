import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Seleção de cabeça foi movida para a tela de perfil

class CustomizationScreen extends StatefulWidget {
  const CustomizationScreen({super.key});

  @override
  State<CustomizationScreen> createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen>
    with TickerProviderStateMixin {
  String _selectedColor = 'red';
  // Cabeça não é mais selecionada nesta tela
  late AnimationController _animationController;
  late AnimationController _breathingController;
  late Animation<double> _animation;
  late Animation<double> _breathingAnimation;
  // Alternância contínua entre sprites _1 e _2

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

  // Sem mapas de cabeças aqui

  @override
  void initState() {
    super.initState();
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
              Color(0xFF0D1117),
              Color(0xFF161B22),
              Color(0xFF21262D),
            ],
          ),
        ),
        child: SafeArea(
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
              Expanded(
                flex: 3,
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
                                      Image.asset(
                                        (_animationController.value < 0.5)
                                            ? _colorAssets[_selectedColor]!
                                            : (_colorAssets2[_selectedColor] ?? _colorAssets[_selectedColor]!),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.contain,
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
              Expanded(
                flex: 1,
                child: Container(
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
                    children: [
                      Text(
                        'Escolha a Cor do Seu Personagem',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Grid de cores
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _colorAssets.length,
                          itemBuilder: (context, index) {
                            final colorKey = _colorAssets.keys.elementAt(index);
                            final isSelected = _selectedColor == colorKey;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = colorKey;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                                      : Colors.grey[800],
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
                                    // Preview do personagem
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
                                          _colorAssets[colorKey]!,
                                          fit: BoxFit.cover,
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
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Seleção de cabeças removida desta tela
                    ],
                  ),
                ),
              ),
      // Removido FAB; usamos o botão de texto no cabeçalho
    );
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

  // Sem nomes de cabeça nesta tela
}
