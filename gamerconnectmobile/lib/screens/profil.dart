import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/auth_service.dart';
import 'welcome.dart';

class ProfilPage extends StatefulWidget {
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> with SingleTickerProviderStateMixin {
  String _pseudo = 'Legend';
  late TabController _tabController;

  final List<Map<String, dynamic>> _favoriteGames = [
    {'name': 'FIFA 23', 'image': 'assets/images/fifa.png', 'hours': '320h', 'color': AppColors.green},
    {'name': 'Dofus Touch', 'image': 'assets/images/dofus.png', 'hours': '210h', 'color': AppColors.orange},
    {'name': 'Monster H.', 'image': 'assets/images/monster.png', 'hours': '180h', 'color': AppColors.accent},
    {'name': 'Pokemon Go', 'image': 'assets/images/pokemon.png', 'hours': '95h', 'color': AppColors.secondary},
  ];

  final List<Map<String, dynamic>> _badges = [
    {'icon': Icons.emoji_events_rounded, 'name': 'Champion', 'color': AppColors.gold},
    {'icon': Icons.flash_on_rounded, 'name': 'Speed Run', 'color': AppColors.accent},
    {'icon': Icons.group_rounded, 'name': 'Social', 'color': AppColors.secondary},
    {'icon': Icons.star_rounded, 'name': 'Legend', 'color': AppColors.primary},
    {'icon': Icons.local_fire_department_rounded, 'name': 'Streak', 'color': AppColors.orange},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {'title': 'Maître des familiers', 'game': 'Dofus', 'description': 'Atteindre le niveau maximum d\'un familier.', 'rarity': 'EPIC', 'color': AppColors.accent},
    {'title': 'Dresseur Élite', 'game': 'Pokémon', 'description': 'Battre la Ligue Pokémon sans perdre un seul combat.', 'rarity': 'RARE', 'color': AppColors.primary},
    {'title': 'Chasseur de légende', 'game': 'Monster Hunter', 'description': 'Terrasser un dragon ancien en solo.', 'rarity': 'LEGENDARY', 'color': AppColors.gold},
    {'title': 'Champion FUT', 'game': 'FIFA', 'description': 'Gagner 5 matchs consécutifs en mode FUT.', 'rarity': 'RARE', 'color': AppColors.secondary},
    {'title': 'Collectionneur', 'game': 'Pokémon', 'description': 'Attraper 100 Pokémon différents.', 'rarity': 'UNCOMMON', 'color': AppColors.green},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final pseudo = await AuthService.getPseudo();
    if (mounted) setState(() => _pseudo = pseudo);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A0A3E), Color(0xFF080810)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Glow orb
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppColors.primary.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Profile content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar with rank ring
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
                                    _pseudo.isNotEmpty ? _pseudo[0].toUpperCase() : 'G',
                                    style: AppStyles.heading.copyWith(fontSize: 36),
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
                              child: const Icon(Icons.star, color: Colors.black, size: 12),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_pseudo, style: AppStyles.heading.copyWith(fontSize: 22)),
                              const SizedBox(height: 4),
                              Text('@${_pseudo.toLowerCase()}02', style: AppStyles.subHeading),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  AppWidgets.badge('DIAMOND', AppColors.secondary),
                                  const SizedBox(width: 8),
                                  AppWidgets.badge('LVL 28', AppColors.primary),
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
                        _headerStat('150', 'TROPHIES'),
                        _headerStat('42', 'FRIENDS'),
                        _headerStat('8', 'GROUPS'),
                        _headerStat('5', 'EVENTS'),
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

  Widget _headerStat(String v, String l) => Column(
    children: [
      Text(v, style: AppStyles.heading.copyWith(fontSize: 18, color: Colors.white)),
      Text(l, style: AppStyles.label.copyWith(fontSize: 9, color: Colors.grey)),
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
        unselectedLabelStyle: AppStyles.label.copyWith(fontSize: 12, color: Colors.grey),
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey,
        tabs: const [Tab(text: 'OVERVIEW'), Tab(text: 'GAMES'), Tab(text: 'TROPHIES')],
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
          // Badges
          AppWidgets.sectionHeader("MY BADGES"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _badges.map((b) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.cardGradient(b['color'] as Color),
                    border: Border.all(color: (b['color'] as Color).withOpacity(0.4)),
                  ),
                  child: Icon(b['icon'] as IconData, color: b['color'] as Color, size: 22),
                ),
                const SizedBox(height: 6),
                Text(b['name'] as String, style: AppStyles.label.copyWith(fontSize: 9, color: Colors.grey)),
              ],
            )).toList(),
          ).animate().fadeIn(delay: const Duration(milliseconds: 100)),

          const SizedBox(height: 28),
          AppWidgets.sectionHeader("LINKED ACCOUNTS"),
          const SizedBox(height: 16),
          Row(
            children: [
              _accountCard("PlayStation", Icons.gamepad_rounded, AppColors.primary, connected: true),
              const SizedBox(width: 12),
              _accountCard("Xbox", Icons.sports_esports, AppColors.green, connected: false),
              const SizedBox(width: 12),
              _accountCard("Steam", Icons.computer_rounded, AppColors.secondary, connected: true),
            ],
          ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

          const SizedBox(height: 28),
          AppWidgets.sectionHeader("GAMING STYLE"),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyles.cardDecoration,
            child: Column(
              children: [
                _gameplayBar("RPG / Adventure", 0.85, AppColors.primary),
                const SizedBox(height: 12),
                _gameplayBar("Competitive FPS", 0.60, AppColors.accent),
                const SizedBox(height: 12),
                _gameplayBar("Strategy", 0.45, AppColors.secondary),
                const SizedBox(height: 12),
                _gameplayBar("Sports / Racing", 0.30, AppColors.gold),
              ],
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => WelcomePage()),
                    (_) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text("SIGN OUT", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
        ],
      ),
    );
  }

  Widget _accountCard(String name, IconData icon, Color color, {bool connected = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: AppStyles.glowDecoration(connected ? color : Colors.grey),
        child: Column(
          children: [
            Icon(icon, color: connected ? color : Colors.grey, size: 26),
            const SizedBox(height: 8),
            Text(name, style: AppStyles.label.copyWith(fontSize: 9, color: connected ? color : Colors.grey)),
            const SizedBox(height: 6),
            AppWidgets.badge(connected ? 'LINKED' : 'CONNECT', connected ? color : Colors.grey),
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
            Text('${(value * 100).toInt()}%', style: AppStyles.label.copyWith(fontSize: 11, color: color)),
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
                  child: Image.asset(g['image'] as String, width: 70, height: 70, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.timer_outlined, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        Text(g['hours'] as String, style: AppStyles.subHeading.copyWith(fontSize: 12)),
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
                      child: Icon(Icons.star_rounded, color: g['color'] as Color, size: 18),
                    ),
                    const SizedBox(height: 4),
                    Text('#${i + 1}', style: AppStyles.label.copyWith(fontSize: 11, color: g['color'] as Color)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * i)).slideX(begin: 0.1);
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final colors = {'LEGENDARY': AppColors.gold, 'EPIC': AppColors.accent, 'RARE': AppColors.primary, 'UNCOMMON': AppColors.green};
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: _achievements.length,
      itemBuilder: (_, i) {
        final a = _achievements[i];
        final rarityColor = colors[a['rarity']] ?? AppColors.primary;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: AppStyles.glowDecoration(rarityColor),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [rarityColor.withOpacity(0.3), rarityColor.withOpacity(0.05)],
                  ),
                ),
                child: Icon(Icons.emoji_events_rounded, color: rarityColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(a['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                        AppWidgets.badge(a['rarity'] as String, rarityColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(a['game'] as String, style: TextStyle(color: rarityColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(a['description'] as String, style: AppStyles.subHeading.copyWith(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * i)).slideY(begin: 0.2);
      },
    );
  }
}
