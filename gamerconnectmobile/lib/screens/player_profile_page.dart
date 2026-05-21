import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';

class PlayerProfilePage extends StatefulWidget {
  final Map<String, dynamic> player;

  const PlayerProfilePage({super.key, required this.player});

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _favoriteGames = [
    {
      'name': 'FIFA 23',
      'image': 'assets/images/fifa.png',
      'hours': '320h',
      'color': AppColors.green
    },
    {
      'name': 'Dofus Touch',
      'image': 'assets/images/dofus.png',
      'hours': '210h',
      'color': AppColors.orange
    },
    {
      'name': 'Monster H.',
      'image': 'assets/images/monster.png',
      'hours': '180h',
      'color': AppColors.accent
    },
    {
      'name': 'Pokemon Go',
      'image': 'assets/images/pokemon.png',
      'hours': '95h',
      'color': AppColors.secondary
    },
  ];

  final List<Map<String, dynamic>> _badges = [
    {
      'icon': Icons.emoji_events_rounded,
      'name': 'Champion',
      'color': AppColors.gold
    },
    {
      'icon': Icons.flash_on_rounded,
      'name': 'Speed Run',
      'color': AppColors.accent
    },
    {
      'icon': Icons.group_rounded,
      'name': 'Social',
      'color': AppColors.secondary
    },
    {'icon': Icons.star_rounded, 'name': 'Legend', 'color': AppColors.primary},
    {
      'icon': Icons.local_fire_department_rounded,
      'name': 'Streak',
      'color': AppColors.orange
    },
  ];

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'Maître des familiers',
      'game': 'Dofus',
      'description': 'Atteindre le niveau maximum d\'un familier.',
      'rarity': 'EPIC',
      'color': AppColors.accent
    },
    {
      'title': 'Dresseur Élite',
      'game': 'Pokémon',
      'description': 'Battre la Ligue Pokémon sans perdre un seul combat.',
      'rarity': 'RARE',
      'color': AppColors.primary
    },
    {
      'title': 'Chasseur de légende',
      'game': 'Monster Hunter',
      'description': 'Terrasser un dragon ancien en solo.',
      'rarity': 'LEGENDARY',
      'color': AppColors.gold
    },
    {
      'title': 'Champion FUT',
      'game': 'FIFA',
      'description': 'Gagner 5 matchs consécutifs en mode FUT.',
      'rarity': 'RARE',
      'color': AppColors.secondary
    },
    {
      'title': 'Collectionneur',
      'game': 'Pokémon',
      'description': 'Attraper 100 Pokémon différents.',
      'rarity': 'UNCOMMON',
      'color': AppColors.green
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get pseudo => widget.player['pseudo']?.toString() ?? 'Joueur';
  String get prenom => widget.player['prenom']?.toString() ?? '';
  String get nom => widget.player['nom']?.toString() ?? '';
  String get email => widget.player['email']?.toString() ?? 'Non renseigné';
  String get matches => widget.player['matchs']?.toString() ?? '254';
  String get level => widget.player['niveau']?.toString() ?? '28';
  String get friends => widget.player['amis']?.toString() ?? '42';
  String get groups => widget.player['groupes']?.toString() ?? '8';
  String get events => widget.player['evenements']?.toString() ?? '5';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [_buildSliverHeader()],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildGamesTab(),
                  _buildAchievementsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: const BackButton(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0A3E), Color(0xFF080810)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                              ),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                                child: Center(
                                  child: Text(
                                    pseudo.isNotEmpty
                                        ? pseudo[0].toUpperCase()
                                        : 'J',
                                    style: AppStyles.heading
                                        .copyWith(fontSize: 36),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.star,
                                  color: Colors.black, size: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(pseudo,
                                  style:
                                      AppStyles.heading.copyWith(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text('@${pseudo.toLowerCase()}',
                                  style: AppStyles.subHeading),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  AppWidgets.badge(
                                      'DIAMOND', AppColors.secondary),
                                  const SizedBox(width: 8),
                                  AppWidgets.badge(
                                      'LVL $level', AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppWidgets.xpBar(0.72, label: 'XP: 7,200 / 10,000'),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _headerStat(matches, 'MATCHS'),
                        _headerStat(friends, 'AMIS'),
                        _headerStat(groups, 'GROUPES'),
                        _headerStat(events, 'ÉVÉNEMENTS'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String value, String label) => Column(
        children: [
          Text(value,
              style: AppStyles.heading
                  .copyWith(fontSize: 18, color: Colors.white)),
          Text(label,
              style: AppStyles.label.copyWith(fontSize: 9, color: Colors.grey)),
        ],
      );

  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: AppStyles.label.copyWith(fontSize: 12),
        unselectedLabelStyle:
            AppStyles.label.copyWith(fontSize: 12, color: Colors.grey),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: 'OVERVIEW'),
          Tab(text: 'GAMES'),
          Tab(text: 'TROPHIES')
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppWidgets.sectionHeader('MY BADGES'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _badges
                .map((b) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                AppColors.cardGradient(b['color'] as Color),
                            border: Border.all(
                                color: (b['color'] as Color).withOpacity(0.4)),
                          ),
                          child: Icon(b['icon'] as IconData,
                              color: b['color'] as Color, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(b['name'] as String,
                            style: AppStyles.label
                                .copyWith(fontSize: 9, color: Colors.grey)),
                      ],
                    ))
                .toList(),
          ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
          const SizedBox(height: 28),
          AppWidgets.sectionHeader('LINKED ACCOUNTS'),
          const SizedBox(height: 16),
          Row(
            children: [
              _accountCard(
                  'PlayStation', Icons.gamepad_rounded, AppColors.primary,
                  connected: true),
              const SizedBox(width: 12),
              _accountCard('Xbox', Icons.sports_esports, AppColors.green,
                  connected: false),
              const SizedBox(width: 12),
              _accountCard('Steam', Icons.computer_rounded, AppColors.secondary,
                  connected: true),
            ],
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
          const SizedBox(height: 28),
          AppWidgets.sectionHeader('GAMING STYLE'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration,
            child: Column(
              children: [
                _gameplayBar('RPG / Adventure', 0.85, AppColors.primary),
                const SizedBox(height: 12),
                _gameplayBar('Competitive FPS', 0.60, AppColors.accent),
                const SizedBox(height: 12),
                _gameplayBar('Strategy', 0.45, AppColors.secondary),
                const SizedBox(height: 12),
                _gameplayBar('Sports / Racing', 0.30, AppColors.gold),
              ],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
        ],
      ),
    );
  }

  Widget _accountCard(String name, IconData icon, Color color,
      {bool connected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: AppStyles.glowDecoration(connected ? color : Colors.grey),
        child: Column(
          children: [
            Icon(icon, color: connected ? color : Colors.grey, size: 26),
            const SizedBox(height: 8),
            Text(name,
                style: AppStyles.label.copyWith(
                    fontSize: 9, color: connected ? color : Colors.grey)),
            const SizedBox(height: 6),
            AppWidgets.badge(connected ? 'LINKED' : 'CONNECT',
                connected ? color : Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _gameplayBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppStyles.subHeading.copyWith(fontSize: 12)),
            Text('${(value * 100).toInt()}%',
                style: AppStyles.label.copyWith(fontSize: 11, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        AppWidgets.xpBar(value),
      ],
    );
  }

  Widget _buildGamesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: _favoriteGames.asMap().entries.map((e) {
          final i = e.key;
          final g = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: AppStyles.glowDecoration(g['color'] as Color),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(g['image'] as String,
                      width: 70, height: 70, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g['name'] as String,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.timer_outlined,
                            color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(g['hours'] as String,
                            style: AppStyles.subHeading.copyWith(fontSize: 12)),
                      ]),
                      const SizedBox(height: 12),
                      AppWidgets.xpBar([0.85, 0.70, 0.60, 0.40][i].toDouble()),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (g['color'] as Color).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.star_rounded,
                          color: g['color'] as Color, size: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${(0.85 - i * 0.15).toInt() * 10}%'
                            .replaceAll('90%', '85%'),
                        style: AppStyles.label
                            .copyWith(fontSize: 11, color: Colors.grey)),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: _achievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: AppStyles.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.cardGradient(
                            achievement['color'] as Color),
                      ),
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(achievement['title'] as String,
                          style: AppStyles.heading.copyWith(fontSize: 16)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(achievement['description'] as String,
                    style: AppStyles.subHeading.copyWith(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    AppWidgets.badge(achievement['rarity'] as String,
                        achievement['color'] as Color),
                    const SizedBox(width: 8),
                    Text(achievement['game'] as String,
                        style: AppStyles.label.copyWith(color: Colors.grey)),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
