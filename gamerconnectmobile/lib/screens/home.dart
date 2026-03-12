import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_system.dart';
import 'profil.dart';
import 'evenement_page.dart';
import 'actu_page.dart';
import 'succes_page.dart';
import 'groupes_page.dart';
import 'welcome.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _searchActive = false;
  String _username = 'Gamer';
  late AnimationController _onlineController;

  final List<Map<String, dynamic>> _feedItems = [
    {
      'user': 'ZeldaMaster',
      'avatar': 'Z',
      'avatarColor': AppColors.primary,
      'time': '2m ago',
      'content': 'Just hit Diamond rank on Valorant 🎮🔥 Who wants to squad up?',
      'tags': ['#Valorant', '#Diamond'],
      'likes': 142,
      'comments': 38,
      'liked': false,
    },
    {
      'user': 'GokuSSB',
      'avatar': 'G',
      'avatarColor': AppColors.accent,
      'time': '15m ago',
      'content': 'Tournament starts in 3 hours. No mercy today. Training mode ON. 💪',
      'tags': ['#Tournament', '#FGC'],
      'likes': 87,
      'comments': 21,
      'liked': false,
    },
    {
      'user': 'NinjaFox99',
      'avatar': 'N',
      'avatarColor': AppColors.secondary,
      'time': '1h ago',
      'content': 'New Monster Hunter DLC drops tomorrow! Been waiting for this for months 🐉',
      'tags': ['#MonsterHunter', '#Gaming'],
      'likes': 312,
      'comments': 74,
      'liked': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _onlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('pseudo') ?? 'Legend';
      });
    }
  }

  @override
  void dispose() {
    _onlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            if (_searchActive) _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () async {
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildWelcomeCard(),
                        const SizedBox(height: 24),
                        _buildStatsRow(),
                        const SizedBox(height: 28),
                        AppWidgets.sectionHeader("NAVIGATE", onSeeAll: null),
                        const SizedBox(height: 16),
                        _buildBentoMenu(),
                        const SizedBox(height: 28),
                        AppWidgets.sectionHeader("COMMUNITY FEED", onSeeAll: () {}),
                        const SizedBox(height: 16),
                        _buildFeed(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Text("GamerConnect", style: AppStyles.heading.copyWith(fontSize: 18)),
          const Spacer(),
          // Online indicator
          AnimatedBuilder(
            animation: _onlineController,
            builder: (_, __) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.3 + _onlineController.value * 0.4),
                    blurRadius: 8 + _onlineController.value * 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(_searchActive ? Icons.close : Icons.search_rounded, color: Colors.white),
            onPressed: () => setState(() => _searchActive = !_searchActive),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilPage())),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                border: Border.all(color: AppColors.primaryLight, width: 2),
              ),
              child: Center(
                child: Text(
                  _username.isNotEmpty ? _username[0].toUpperCase() : 'G',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => _searchQuery = v),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search players, games, groups...',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 18 ? 'Good Afternoon' : 'Good Evening';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1550), Color(0xFF1A1030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AppStyles.subHeading.copyWith(color: AppColors.primaryLight)),
                const SizedBox(height: 4),
                Text("Welcome back, $_username!", style: AppStyles.heading.copyWith(fontSize: 18)),
                const SizedBox(height: 12),
                AppWidgets.badge("LEVEL 28 • DIAMOND", AppColors.secondary),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 36),
          ),
        ],
      ),
    ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideY(begin: 0.1);
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'WINS', 'value': '347', 'color': AppColors.green, 'icon': Icons.military_tech_rounded},
      {'label': 'RANK', 'value': '#142', 'color': AppColors.gold, 'icon': Icons.leaderboard_rounded},
      {'label': 'HOURS', 'value': '1.2K', 'color': AppColors.secondary, 'icon': Icons.timer_rounded},
    ];
    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(left: i == 0 ? 0 : 8, right: i == 2 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: AppStyles.glowDecoration(s['color'] as Color),
            child: Column(
              children: [
                Icon(s['icon'] as IconData, color: s['color'] as Color, size: 22),
                const SizedBox(height: 8),
                Text(s['value'] as String, style: AppStyles.heading.copyWith(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 2),
                Text(s['label'] as String, style: AppStyles.label.copyWith(color: Colors.grey, fontSize: 9)),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 150 + i * 80)).slideY(begin: 0.2),
        );
      }).toList(),
    );
  }

  Widget _buildBentoMenu() {
    final items = [
      {'label': 'NEWS', 'icon': Icons.newspaper_rounded, 'color': AppColors.primary, 'page': ActuPage()},
      {'label': 'EVENTS', 'icon': Icons.event_available_rounded, 'color': AppColors.secondary, 'page': EvenementPage()},
      {'label': 'TROPHIES', 'icon': Icons.emoji_events_rounded, 'color': AppColors.gold, 'page': SuccesPage()},
      {'label': 'GROUPS', 'icon': Icons.groups_rounded, 'color': AppColors.orange, 'page': GroupesPage()},
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: items.asMap().entries.map((e) {
        final i = e.key;
        final item = e.value;
        final color = item['color'] as Color;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item['page'] as Widget)),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient(color),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  item['label'] as String,
                  style: AppStyles.label.copyWith(color: color, fontSize: 12),
                ),
              ],
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 60)).scale(begin: const Offset(0.9, 0.9)),
        );
      }).toList(),
    );
  }

  Widget _buildFeed() {
    final filtered = _searchQuery.isEmpty
        ? _feedItems
        : _feedItems.where((f) => f['content'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, color: Colors.grey, size: 50),
              const SizedBox(height: 12),
              Text("No results found", style: AppStyles.subHeading),
            ],
          ),
        ),
      );
    }

    return Column(
      children: filtered.asMap().entries.map((e) {
        final i = e.key;
        return _feedCard(e.value, i);
      }).toList(),
    );
  }

  Widget _feedCard(Map<String, dynamic> item, int index) {
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (item['avatarColor'] as Color).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: item['avatarColor'] as Color, width: 2),
                ),
                child: Center(
                  child: Text(
                    item['avatar'] as String,
                    style: TextStyle(
                      color: item['avatarColor'] as Color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['user'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Row(
                      children: [
                        AppWidgets.onlineDot(online: index != 2),
                        const SizedBox(width: 5),
                        Text(item['time'] as String, style: AppStyles.subHeading.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 14),
          Text(item['content'] as String, style: AppStyles.body),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: (item['tags'] as List<String>).map((tag) =>
              AppWidgets.badge(tag, AppColors.primary)
            ).toList(),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    item['liked'] = !(item['liked'] as bool);
                    item['likes'] = item['liked'] ? (item['likes'] as int) + 1 : (item['likes'] as int) - 1;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      item['liked'] ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: item['liked'] ? AppColors.accent : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(item['likes'].toString(), style: TextStyle(color: item['liked'] ? AppColors.accent : Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: Colors.grey, size: 20),
                  const SizedBox(width: 6),
                  Text(item['comments'].toString(), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
              const SizedBox(width: 16),
              const Icon(Icons.bookmark_border_rounded, color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: AppColors.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home_filled, 0),
            _navItem(Icons.groups_rounded, 1),
            const SizedBox(width: 60),
            _navItem(Icons.event_available_rounded, 2),
            _navItem(Icons.person_outline_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => GroupesPage()));
        if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => EvenementPage()));
        if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilPage()));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: isActive ? AppColors.primary : Colors.grey, size: 26),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => _buildPostSheet(),
        );
      },
      backgroundColor: AppColors.primary,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  Widget _buildPostSheet() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("QUICK POST", style: AppStyles.heading.copyWith(fontSize: 16)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "What's happening in your game world?",
              hintStyle: AppStyles.subHeading,
              filled: true,
              fillColor: AppColors.cardBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.tag_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text("Add tags to reach the right players", style: AppStyles.subHeading),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("POST", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
