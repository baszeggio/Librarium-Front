import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/achievements_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedFrequency = 'diario';
  String _selectedCategory = 'pessoal';
  String _selectedDifficulty = 'medio';
  String _selectedIcon = 'espada';
  String _selectedColor = '#8B5CF6';

  // from backend enum ['diario', 'semanal', 'mensal']
  final List<String> _frequencies = ['diario', 'semanal', 'mensal'];
  // from backend enum ['saude', 'estudo', 'trabalho', 'pessoal', 'social', 'criativo']
  final List<String> _categories = ['saude', 'estudo', 'trabalho', 'pessoal', 'social', 'criativo'];
  // from backend enum ['facil', 'medio', 'dificil', 'lendario']
  final List<String> _difficulties = ['facil', 'medio', 'dificil', 'lendario'];
  final List<String> _icons = [
    'espada', // padrão do backend
    'livro',
    'coracao',
    'cerebro',
    'trabalho',
    'casa',
    'dinheiro',
    'tempo'
  ];
  // Default backend color and more
  final List<String> _colors = [
    '#8B5CF6',
    '#9A031E',
    '#F77F00',
    '#238636',
    '#DA3633',
    '#0969DA',
    '#8250DF',
    '#FF6B6B',
    '#4ECDC4',
    '#45B7D1'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final habitsProvider = context.read<HabitsProvider>();
      await habitsProvider.createHabit(
        titulo: _titleController.text.trim(),
        descricao: _descriptionController.text.trim(),
        frequencia: _selectedFrequency,
        categoria: _selectedCategory,
        dificuldade: _selectedDifficulty,
        icone: _selectedIcon,
        cor: _selectedColor,
      );

      if (mounted) {
        if (habitsProvider.error != null) {
          // Fallback: criar exemplo local para demonstrar na lista
          habitsProvider.addLocalHabitExample(
            titulo: _titleController.text.trim(),
            descricao: _descriptionController.text.trim(),
            frequencia: _selectedFrequency,
            categoria: _selectedCategory,
            dificuldade: _selectedDifficulty,
            icone: _selectedIcon,
            cor: _selectedColor,
          );
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sem conexão com a API. Exemplo local criado.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          // Verificar e recarregar conquistas após criar hábito com sucesso
          try {
            final achievementsProvider = context.read<AchievementsProvider>();
            await achievementsProvider.verifyAchievements();
          } catch (e) {
            print('Erro ao verificar conquistas após criar hábito: $e');
          }

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Hábito "${_titleController.text.trim()}" criado com sucesso!'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar hábito: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
          child: Consumer<HabitsProvider>(
            builder: (context, habitsProvider, child) {
              return Column(
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
                        // Botão de voltar destacado
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            color: Colors.white,
                            tooltip: 'Voltar',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Criar Hábito',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Formulário
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            CustomTextField(
                              controller: _titleController,
                              label: 'Título do Hábito',
                              hint: 'Ex: Exercitar-se diariamente',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Título é obrigatório';
                                }
                                if (value.length > 100) {
                                  return 'Título deve ter no máximo 100 caracteres';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Descrição
                            CustomTextField(
                              controller: _descriptionController,
                              label: 'Descrição',
                              hint: 'Descreva seu hábito...',
                              maxLines: 3,
                              validator: (value) {
                                if (value != null && value.length > 500) {
                                  return 'Descrição deve ter no máximo 500 caracteres';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Frequência
                            _buildSectionTitle('Frequência'),
                            const SizedBox(height: 8),
                            _buildSelectionChips(
                              _frequencies,
                              _selectedFrequency,
                              (value) => setState(() => _selectedFrequency = value),
                              (freq) => _getFrequencyText(freq),
                            ),

                            const SizedBox(height: 24),

                            // Categoria
                            _buildSectionTitle('Categoria'),
                            const SizedBox(height: 8),
                            _buildSelectionChips(
                              _categories,
                              _selectedCategory,
                              (value) => setState(() => _selectedCategory = value),
                              (cat) => _getCategoryText(cat),
                            ),

                            const SizedBox(height: 24),

                            // Dificuldade
                            _buildSectionTitle('Dificuldade'),
                            const SizedBox(height: 8),
                            _buildSelectionChips(
                              _difficulties,
                              _selectedDifficulty,
                              (value) => setState(() => _selectedDifficulty = value),
                              (diff) => _getDifficultyText(diff),
                            ),

                            const SizedBox(height: 24),

                            // Ícone
                            _buildSectionTitle('Ícone'),
                            const SizedBox(height: 8),
                            _buildIconSelection(),

                            const SizedBox(height: 24),

                            // Cor
                            _buildSectionTitle('Cor'),
                            const SizedBox(height: 8),
                            _buildColorSelection(),

                            const SizedBox(height: 32),

                            // Botão criar
                            SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                text: 'Criar Hábito',
                                onPressed: habitsProvider.isLoading ? null : _createHabit,
                                isLoading: habitsProvider.isLoading,
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.arrow_back, color: Colors.white),
        tooltip: 'Voltar',
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSelectionChips(
    List<String> options,
    String selected,
    Function(String) onChanged,
    String Function(String) getDisplayText,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Text(
              getDisplayText(option),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _icons.map((icon) {
        final isSelected = _selectedIcon == icon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getHabitIcon(icon),
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  IconData _getHabitIcon(String icone) {
    switch (icone.toLowerCase()) {
      case 'espada':
        return Icons.fitness_center;
      case 'livro':
        return Icons.menu_book;
      case 'coracao':
        return Icons.favorite;
      case 'cerebro':
        return Icons.psychology;
      case 'trabalho':
        return Icons.work;
      case 'casa':
        return Icons.home;
      case 'dinheiro':
        return Icons.attach_money;
      case 'tempo':
        return Icons.schedule;
      default:
        return Icons.task;
    }
  }

  String _getFrequencyText(String frequencia) {
    switch (frequencia.toLowerCase()) {
      case 'diario':
        return 'Diário';
      case 'semanal':
        return 'Semanal';
      case 'mensal':
        return 'Mensal';
      default:
        return frequencia;
    }
  }

  String _getCategoryText(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'saude':
        return 'Saúde';
      case 'estudo':
        return 'Estudo';
      case 'trabalho':
        return 'Trabalho';
      case 'pessoal':
        return 'Pessoal';
      case 'social':
        return 'Social';
      case 'criativo':
        return 'Criativo';
      default:
        return categoria;
    }
  }

  String _getDifficultyText(String dificuldade) {
    switch (dificuldade.toLowerCase()) {
      case 'facil':
        return 'Fácil';
      case 'medio':
        return 'Médio';
      case 'dificil':
        return 'Difícil';
      case 'lendario':
        return 'Lendário';
      default:
        return dificuldade;
    }
  }
}
