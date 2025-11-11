import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/achievements_provider.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/achievement_badge.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../services/api_service.dart';
import '../ranking/ranking_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> _topRanking = [];
  Map<String, dynamic>? _userRanking;
  bool _loadingRanking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadRanking();
    });
  }

  Future<void> _loadRanking() async {
    setState(() => _loadingRanking = true);
    try {
      final response = await ApiService.getMultiplayerRanking();
      print('Resposta do ranking: $response');
      
      final rankingData = response['ranking'] ?? [];
      final usuarioAtual = response['usuarioAtual'];
      
      print('Ranking data: $rankingData (tipo: ${rankingData.runtimeType})');
      print('Usuário atual: $usuarioAtual');
      
      setState(() {
        // Pegar apenas os top 5 para o dashboard
        if (rankingData is List && rankingData.isNotEmpty) {
          _topRanking = rankingData.take(5).toList();
          print('Top ranking carregado: ${_topRanking.length} jogadores');
        } else {
          _topRanking = [];
          print('Ranking vazio ou inválido');
        }
        
        if (usuarioAtual is Map && usuarioAtual.isNotEmpty) {
          _userRanking = Map<String, dynamic>.from(usuarioAtual);
          print('Ranking do usuário carregado: posição ${_userRanking!['posicao']}');
        } else {
          _userRanking = null;
          print('Ranking do usuário não disponível');
        }
        _loadingRanking = false;
      });
    } catch (e, stackTrace) {
      setState(() => _loadingRanking = false);
      print('Erro ao carregar ranking: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<AvatarProvider>().loadAvatar(),
      context.read<HabitsProvider>().loadHabits(),
      context.read<StatsProvider>().loadStats(),
    ]);

    // Carregar e verificar conquistas separadamente
    await context.read<AchievementsProvider>().loadAchievements();
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
          child: _buildDashboard(),
        ),
      ),
      bottomNavigationBar: _buildScrollableFooter(context),
    );
  }

  /// Tornar o footer (CustomBottomNav) scrollável horizontalmente.
  Widget _buildScrollableFooter(BuildContext context) {
    // O CustomBottomNav é o widget de footer, por padrão não é scrollable.
    // Aqui o envolvemos em um SingleChildScrollView horizontal e um IntrinsicHeight para manter visual idêntico.
    return Material(
      // Garante elevation/padding igual ao BottomNavigationBar
      color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
          Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 0.0,
            // Remove limite de largura fixa
          ),
          child: IntrinsicHeight(
            child: CustomBottomNav(
              selectedIndex: 0, // Sempre dashboard
              onTap: (index) {
                switch (index) {
                  case 0:
                    // Dashboard - já estamos aqui
                    break;
                  case 1:
                    context.go('/habits');
                    break;
                  case 2:
                    context.go('/achievements');
                    break;
                  case 3:
                    context.go('/stats');
                    break;
                  case 4:
                    context.go('/multiplayer');
                    break;
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com avatar e informações do usuário
          _buildHeader(),
          const SizedBox(height: 24),
          // Cards de estatísticas
          _buildStatsSection(),
          const SizedBox(height: 24),
          // Hábitos do dia
          _buildHabitsSection(),
          const SizedBox(height: 24),
          // Conquistas recentes
          _buildAchievementsSection(),
          const SizedBox(height: 24),
          // Ranking
          _buildRankingSection(),
        ],
      ),
    );
  }

  /// Exemplo "dummy" para transformar uma imagem em um headKey.
  ///
  /// Na prática, deve abrir um seletor para o usuário escolher a chave de avatar,
  /// ou implementar um mapeamento dos arquivos/paths para chaves válidas.
  /// Aqui só retorna null; personalize a lógica conforme suas opções reais de avatar.
  String? convertImageFileToHeadKey(String imagePath) {
    // Simule conversão ou devolva sempre uma chave, ou crie um seletor real
    // Por exemplo: se imagem for X, retorna "wizard_head", etc.
    // Aqui você decide ou implementa a UI para seleção de avatar, não upload real.
    // Para testes, pode retornar uma headKey fixa (exemplo "wizard_head"),
    // ou, melhor ainda, abrir um modal para o usuário escolher.
    // Retorne null para não fazer nada.
    // Exemplo simples:
    // return 'wizard_head';
    return null;
  }

  Widget _buildHeader() {
    return Consumer<AvatarProvider>(
      builder: (context, avatarProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              // Avatar com click - abrir seletor ao tocar
              GestureDetector(
                onTap: () async {
                  // Abre modal para o usuário escolher um tipo de avatar.
                  // Se quiser ImagePicker de fotos reais (não suportado nativamente), use daqui,
                  // senão, abra um seletor para a "headKey".
                  await _showAvatarHeadSelectionDialog(context, avatarProvider);
                },
                child: AvatarWidget(
                  avatar: avatarProvider.avatar,
                  size: 80,
                ),
              ),
              const SizedBox(width: 16),
              // Informações do usuário
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final nomeUsuario = authProvider.user?['nomeUsuario'] ??
                            authProvider.user?['nome'] ??
                            'Guerreiro';
                        final userId = authProvider.user?['_id']?.toString() ??
                            authProvider.user?['id']?.toString() ??
                            '';
                        final shortId =
                            userId.length > 8 ? userId.substring(0, 8) : userId;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-vindo, $nomeUsuario!',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (shortId.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '#$shortId',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[400],
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        // Obter dados reais do usuário
                        final nivelNum = authProvider.user?['nivel'];
                        final experienciaNum = authProvider.user?['experiencia'];
                        final nivel = (nivelNum is int)
                            ? nivelNum
                            : (nivelNum is num)
                                ? nivelNum.toInt()
                                : 1;
                        final experiencia = (experienciaNum is int)
                            ? experienciaNum
                            : (experienciaNum is num)
                                ? experienciaNum.toInt()
                                : 0;
                        final titulo =
                            authProvider.user?['titulo'] ?? 'Aspirante';

                        // Calcular XP necessário para o próximo nível
                        // Fórmula: 100 XP por nível até 10, depois aumenta
                        int xpProximoNivel;
                        if (nivel <= 10) {
                          xpProximoNivel = nivel * 100;
                        } else if (nivel <= 20) {
                          xpProximoNivel = 1000 + ((nivel - 10) * 200);
                        } else if (nivel <= 30) {
                          xpProximoNivel = 3000 + ((nivel - 20) * 300);
                        } else {
                          xpProximoNivel = 6000 + ((nivel - 30) * 400);
                        }

                        // XP atual relativo ao nível atual
                        int xpNivelAnterior;
                        if (nivel <= 10) {
                          xpNivelAnterior = (nivel - 1) * 100;
                        } else if (nivel <= 20) {
                          xpNivelAnterior = 1000 + ((nivel - 11) * 200);
                        } else if (nivel <= 30) {
                          xpNivelAnterior = 3000 + ((nivel - 21) * 300);
                        } else {
                          xpNivelAnterior = 6000 + ((nivel - 31) * 400);
                        }

                        final xpRestante = xpProximoNivel - xpNivelAnterior;
                        final xpAtualNivel = experiencia - xpNivelAnterior;
                        final progresso =
                            xpRestante > 0 ? xpAtualNivel / xpRestante : 0.0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título do avatar (priorizar título do usuário do backend)
                            Builder(
                              builder: (context) {
                                // Prioridade: 1. Título do usuário (backend), 2. Título calculado do avatar
                                final tituloExibido = titulo.isNotEmpty 
                                    ? titulo 
                                    : (avatarProvider.avatar?.title ?? 'Aspirante');
                                return Text(
                                  tituloExibido,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            // Barra de progresso
                            LinearProgressIndicator(
                              value: avatarProvider.avatar?.progressPercentage ??
                                  progresso.clamp(0.0, 1.0),
                              backgroundColor: const Color(0xFF14181C),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Texto de nível e XP
                            Text(
                              'Nível ${avatarProvider.avatar?.nivel ?? nivel} - ${avatarProvider.avatar?.experiencia ?? experiencia} XP',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[300],
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Botões de ação
              IconButton(
                onPressed: () => context.go('/profile'),
                icon: const Icon(Icons.settings),
                color: Colors.white,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Modal simples para o usuário escolher o avatar (os "heads")
  /// Aqui simulamos com algumas chaves ("wizard_head", "knight_head", etc)
  Future<void> _showAvatarHeadSelectionDialog(
      BuildContext context, AvatarProvider avatarProvider) async {
    // Lista de opções de avatar disponíveis (deve ser igual as chaves/animações do backend)
    final List<Map<String, String>> avatarOptions = [
      {'key': 'wizard_head', 'label': 'Mago'},
      {'key': 'knight_head', 'label': 'Cavaleiro'},
      {'key': 'elf_head', 'label': 'Elfo'},
      {'key': 'default', 'label': 'Padrão'},
      // Adicione mais opções conforme regras do seu backend
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Escolha seu avatar'),
        children: avatarOptions
            .map(
              (map) => SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, map['key']);
                },
                child: Text(map['label']!),
              ),
            )
            .toList(),
      ),
    );

    if (selected != null) {
      try {
        await context.read<AvatarProvider>().setHead(selected);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Avatar atualizado com sucesso!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar avatar: $e')),
          );
        }
      }
    }
  }

  Widget _buildStatsSection() {
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.stats == null) {
          return const SizedBox.shrink();
        }

        final stats = statsProvider.stats!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas Estatísticas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Sequência Atual',
                    value: '${stats.currentStreak}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Taxa de Conclusão',
                    value: '${(stats.completionRate * 100).toInt()}%',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total de Hábitos',
                    value: '${stats.totalHabits}',
                    icon: Icons.checklist,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'XP Total',
                    value: '${stats.totalXP}',
                    icon: Icons.star,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildHabitsSection() {
    return Consumer<HabitsProvider>(
      builder: (context, habitsProvider, child) {
        final activeHabits = habitsProvider.activeHabits.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hábitos de Hoje',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/habits'),
                  child: Text(
                    'Ver Todos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (activeHabits.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_task,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum hábito ativo',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie seu primeiro hábito para começar sua jornada!',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/habits'),
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Hábito'),
                    ),
                  ],
                ),
              )
            else
              ...activeHabits.map(
                (habit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HabitCard(
                    habit: habit,
                    // Nova lógica: trava a conclusão se já completado hoje
                    onComplete: (habit.completado ?? false)
                        ? null
                        : () async {
                            try {
                              final result = await habitsProvider.completeHabit(habit.id);
                              
                              // Processar conquistas desbloqueadas se houver
                              final conquistasDesbloqueadas = result['conquistasDesbloqueadas'] as List<dynamic>?;
                              final achievementsProvider = context.read<AchievementsProvider>();
                              
                              if (conquistasDesbloqueadas != null && conquistasDesbloqueadas.isNotEmpty) {
                                // Processar conquistas desbloqueadas
                                final novasConquistas = achievementsProvider.processUnlockedAchievements(conquistasDesbloqueadas);
                                
                                // Recarregar conquistas
                                await achievementsProvider.loadAchievements();
                                
                                // Mostrar notificação de conquistas desbloqueadas
                                if (context.mounted && novasConquistas.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        novasConquistas.length == 1
                                            ? '🏆 Conquista desbloqueada: ${novasConquistas.first.titulo}!'
                                            : '🏆 ${novasConquistas.length} conquistas desbloqueadas!',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.amber[700],
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                // Verificar conquistas mesmo se não vieram na resposta
                                await achievementsProvider.verifyAchievements();
                              }
                              
                              // Recarrega estatísticas e avatar após completar hábito
                              await context.read<StatsProvider>().loadStats();
                              await context.read<AvatarProvider>().loadAvatar();
                              
                              // Mostrar mensagem de sucesso
                              if (context.mounted) {
                                final experienciaGanha = result['experienciaGanha'] ?? 0;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Hábito concluído! +$experienciaGanha XP',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Trata erro específico de já ter completado hoje pelo backend
                              final message = e.toString();
                              if (message.contains('statusCode: 404') ||
                                  message.contains('Caminho não encontrado') ||
                                  message.contains('já completou este hábito hoje')) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Você já completou este hábito hoje!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.deepPurple,
                                    ),
                                  );
                                }
                              } else {
                                print('Erro ao concluir hábito: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                    onDelete: () {
                      _showDeleteDialog(
                          context, habit.id, habit.titulo, habitsProvider);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }


  Widget _buildAchievementsSection() {
    return Consumer<AchievementsProvider>(
      builder: (context, achievementsProvider, child) {
        final recentAchievements =
            achievementsProvider.unlockedAchievements.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conquistas Recentes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/achievements'),
                  child: Text(
                    'Ver Todas',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentAchievements.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma conquista ainda',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[400],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete hábitos para desbloquear conquistas!',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...recentAchievements.map((achievement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AchievementBadge(
                      achievement: achievement,
                    ),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildRankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ranking Global',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RankingScreen(),
                ),
              ),
              child: Text(
                'Ver Completo',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_loadingRanking)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_topRanking.isEmpty && _userRanking == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum jogador no ranking ainda',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              // Top 3 com destaque
              if (_topRanking.length >= 3)
                Row(
                  children: [
                    Expanded(
                      child: _buildTopRankingCard(_topRanking[1], 2, Colors.grey[400]!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTopRankingCard(_topRanking[0], 1, Colors.amber),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTopRankingCard(_topRanking[2], 3, Colors.brown[400]!),
                    ),
                  ],
                ),
              if (_topRanking.length >= 3) const SizedBox(height: 12),
              // Resto do top 5
              ..._topRanking.skip(3).map((player) {
                final position = _topRanking.indexOf(player) + 1;
                return _buildRankingCard(player, position);
              }),
              // Posição do usuário (sempre mostrar se disponível)
              if (_userRanking != null)
                Padding(
                  padding: EdgeInsets.only(top: _topRanking.isNotEmpty ? 12 : 0),
                  child: _buildUserRankingCard(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildTopRankingCard(dynamic player, int position, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            position == 1 ? '🥇' : position == 2 ? '🥈' : '🥉',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          AvatarWidget(
            avatar: null,
            size: 40,
            fotoPerfilUrl: player['fotoPerfil'],
          ),
          const SizedBox(height: 8),
          Text(
            player['nomeUsuario'] ?? 'Jogador',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Nível ${player['nivel'] ?? 0}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(dynamic player, int position) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '$position',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AvatarWidget(
            avatar: null,
            size: 40,
            fotoPerfilUrl: player['fotoPerfil'],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['nomeUsuario'] ?? 'Jogador',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Nível ${player['nivel'] ?? 0}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.trending_up, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${player['experiencia'] ?? 0} XP',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRankingCard() {
    if (_userRanking == null) return const SizedBox.shrink();
    
    final position = _userRanking!['posicao'] ?? '?';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
            Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '#$position',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return AvatarWidget(
                avatar: null,
                size: 40,
                fotoPerfilUrl: authProvider.user?['fotoPerfil'],
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Nível ${_userRanking!['nivel'] ?? 0}',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.trending_up, size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${_userRanking!['experiencia'] ?? 0} XP',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String habitId, String habitTitle,
      HabitsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text(
          'Deletar Hábito',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja deletar o hábito "$habitTitle"?\n\nEsta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await provider.deleteHabit(habitId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Hábito "$habitTitle" deletado com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Erro ao deletar hábito: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}
