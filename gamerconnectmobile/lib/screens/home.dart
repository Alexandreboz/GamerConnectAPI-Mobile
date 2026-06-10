import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'profil.dart';
import 'player_profile_page.dart';
import 'evenement_page.dart';
import 'forum_page.dart';
import 'actu_page.dart';
import 'trophies_page.dart';
import 'groupes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = '';
  bool _searchActive = false;
  String _username = 'Gamer';
  late AnimationController _onlineController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allPlayers = [];
  List<dynamic> _filteredPlayers = [];
  int? _currentUserId;

  final List<Map<String, dynamic>> _sampleFeedItems = [
    {
      'user': 'ZeldaMaster',
      'avatar': 'Z',
      'avatarColor': AppColors.primary,
      'time': '2m ago',
      'content':
          'Just hit Diamond rank on Valorant 🎮🔥 Who wants to squad up?',
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
      'content':
          'Tournament starts in 3 hours. No mercy today. Training mode ON. 💪',
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
      'content':
          'New Monster Hunter DLC drops tomorrow! Been waiting for this for months 🐉',
      'tags': ['#MonsterHunter', '#Gaming'],
      'likes': 312,
      'comments': 74,
      'liked': true,
    },
  ];

  List<dynamic> _feedItems = [];
  bool _feedLoading = true;
  late TextEditingController _postController;

  @override
  void initState() {
    super.initState();
    _onlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _searchController.addListener(_onSearchChanged);
    _postController = TextEditingController();
    _loadPlayers();
    _loadUser();
    _loadFeed();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _applySearch();
    });
  }

  void _applySearch() {
    final query = _searchQuery.toLowerCase();
    _filteredPlayers = query.isEmpty
        ? _allPlayers
        : _allPlayers.where((u) {
            final pseudo = (u['pseudo'] ?? '').toString().toLowerCase();
            return pseudo.contains(query);
          }).toList();
  }

  Future<void> _loadPlayers() async {
    _currentUserId = await AuthService.getUserId();
    try {
      final users = await ApiService.getUsers();
      if (!mounted) return;
      setState(() {
        _allPlayers =
            users.where((u) => u['id_utilisateur'] != _currentUserId).toList();
        _applySearch();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _allPlayers = [];
      });
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _username = prefs.getString('pseudo') ?? 'Legend';
      });
    }
  }

  Future<void> _loadFeed() async {
    setState(() => _feedLoading = true);
    try {
      final data = await ApiService.getPosts();
      if (!mounted) return;
      setState(() {
        _feedItems = data;
        _feedLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _feedItems = [];
        _feedLoading = false;
      });
    }
  }

  String _relativeTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'Just now';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return 'Just now';
    }
  }

  Future<void> _submitPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Le post ne peut pas être vide.'),
        backgroundColor: AppColors.accent,
      ));
      return;
    }

    final userId = await AuthService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vous devez être connecté pour poster.'),
        backgroundColor: AppColors.accent,
      ));
      return;
    }

    final tags = RegExp(r'#[A-Za-z0-9_]+')
        .allMatches(content)
        .map((match) => match.group(0)!)
        .toList();

    final postResult = await ApiService.createPost(userId, content, tags: tags);
    if (postResult['success'] == true) {
      _postController.clear();
      Navigator.pop(context);
      await _loadFeed();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Post publié avec succès'),
        backgroundColor: AppColors.green,
      ));
    } else {
      final errorMessage =
          postResult['error']?.toString() ?? 'Impossible de publier le post';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Impossible de publier le post : $errorMessage'),
        backgroundColor: AppColors.accent,
      ));
    }
  }

  @override
  void dispose() {
    _onlineController.dispose();
    _searchController.dispose();
    _postController.dispose();
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
                  await _loadFeed();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
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
                        AppWidgets.sectionHeader("COMMUNITY FEED",
                            onSeeAll: () {}),
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
            child: const Icon(Icons.sports_esports_rounded,
                color: Colors.white, size: 22),
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
                    color: AppColors.green
                        .withOpacity(0.3 + _onlineController.value * 0.4),
                    blurRadius: 8 + _onlineController.value * 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(_searchActive ? Icons.close : Icons.search_rounded,
                color: Colors.white),
            onPressed: () => setState(() {
              if (_searchActive) {
                _searchController.clear();
                _searchQuery = '';
              }
              _searchActive = !_searchActive;
            }),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => ProfilPage())),
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
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
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
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Recherche par pseudo...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSearchSuggestions(),
          ],
        ],
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }

  Widget _buildSearchSuggestions() {
    if (_filteredPlayers.isEmpty) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        padding: const EdgeInsets.all(16),
        child: Text('Aucun joueur trouvé', style: AppStyles.subHeading),
      );
    }

    final suggestions = _filteredPlayers.take(5).toList();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final pseudo = player['pseudo'] ?? 'Joueur';
              final prenom = player['prenom'] ?? '';
              final nom = player['nom'] ?? '';
              return Column(
                children: [
                  if (index > 0)
                    Divider(color: Colors.white.withOpacity(0.08), height: 1),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(pseudo,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      [prenom, nom]
                          .where((s) => s?.isNotEmpty ?? false)
                          .join(' '),
                      style: AppStyles.subHeading.copyWith(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.grey, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerProfilePage(player: player),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 18
            ? 'Good Afternoon'
            : 'Good Evening';
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
                Text(greeting,
                    style: AppStyles.subHeading
                        .copyWith(color: AppColors.primaryLight)),
                const SizedBox(height: 4),
                Text("Welcome back, $_username!",
                    style: AppStyles.heading.copyWith(fontSize: 18)),
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
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.gold, size: 36),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: const Duration(milliseconds: 100))
        .slideY(begin: 0.1);
  }

  Widget _buildStatsRow() {
    final stats = [
      {
        'label': 'WINS',
        'value': '347',
        'color': AppColors.green,
        'icon': Icons.military_tech_rounded
      },
      {
        'label': 'RANK',
        'value': '#142',
        'color': AppColors.gold,
        'icon': Icons.leaderboard_rounded
      },
      {
        'label': 'HOURS',
        'value': '1.2K',
        'color': AppColors.secondary,
        'icon': Icons.timer_rounded
      },
    ];
    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Container(
            margin:
                EdgeInsets.only(left: i == 0 ? 0 : 8, right: i == 2 ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: AppStyles.glowDecoration(s['color'] as Color),
            child: Column(
              children: [
                Icon(s['icon'] as IconData,
                    color: s['color'] as Color, size: 22),
                const SizedBox(height: 8),
                Text(s['value'] as String,
                    style: AppStyles.heading
                        .copyWith(fontSize: 18, color: Colors.white)),
                const SizedBox(height: 2),
                Text(s['label'] as String,
                    style: AppStyles.label
                        .copyWith(color: Colors.grey, fontSize: 9)),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 150 + i * 80))
              .slideY(begin: 0.2),
        );
      }).toList(),
    );
  }

  Widget _buildBentoMenu() {
    final items = [
      {
        'label': 'NEWS',
        'icon': Icons.newspaper_rounded,
        'color': AppColors.primary,
        'page': ActuPage()
      },
      {
        'label': 'EVENTS',
        'icon': Icons.event_available_rounded,
        'color': AppColors.secondary,
        'page': EvenementPage()
      },
      {
        'label': 'FORUM',
        'icon': Icons.forum_rounded,
        'color': AppColors.primary,
        'page': const ForumPage()
      },
      {
        'label': 'TROPHIES',
        'icon': Icons.emoji_events_rounded,
        'color': AppColors.gold,
        'page': const TrophiesPage()
      },
      {
        'label': 'GROUPS',
        'icon': Icons.groups_rounded,
        'color': AppColors.orange,
        'page': GroupesPage()
      },
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
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => item['page'] as Widget)),
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
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 200 + i * 60))
              .scale(begin: const Offset(0.9, 0.9)),
        );
      }).toList(),
    );
  }

  Widget _buildFeed() {
    if (_feedLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final items = _feedItems.isNotEmpty ? _feedItems : _sampleFeedItems;
    final filtered = _searchQuery.isEmpty
        ? items
        : items.where((f) {
            final query = _searchQuery.toLowerCase();
            final content = f['content']?.toString().toLowerCase() ??
                f['contenu']?.toString().toLowerCase() ??
                '';
            final user = f['pseudo']?.toString().toLowerCase() ??
                f['user']?.toString().toLowerCase() ??
                '';
            final tags = (f['tags'] is List)
                ? (f['tags'] as List<dynamic>).join(' ').toLowerCase()
                : f['tags']?.toString().toLowerCase() ?? '';
            return content.contains(query) ||
                user.contains(query) ||
                tags.contains(query);
          }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded,
                  color: Colors.grey, size: 50),
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
        return _feedCard(e.value as Map<String, dynamic>, i);
      }).toList(),
    );
  }

  Widget _feedCard(Map<String, dynamic> item, int index) {
    final user =
        item['pseudo']?.toString() ?? item['user']?.toString() ?? 'Gamer';
    final avatarColor = item['avatarColor'] is Color
        ? item['avatarColor'] as Color
        : AppColors.primary;
    final avatar = user.isNotEmpty ? user[0].toUpperCase() : 'G';
    final time = item['date_creation'] != null
        ? _relativeTime(item['date_creation']?.toString())
        : item['time']?.toString() ?? 'Just now';
    final content =
        item['content']?.toString() ?? item['contenu']?.toString() ?? '';
    final tags = item['tags'] is List
        ? List<String>.from(item['tags'] as List<dynamic>)
        : item['tags']
                ?.toString()
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList() ??
            [];
    final likes = item['likes'] is int ? item['likes'] as int : 0;
    final comments = item['comments'] is int ? item['comments'] as int : 0;
    final liked = item['liked'] is bool ? item['liked'] as bool : false;

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
                  color: avatarColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: avatarColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: TextStyle(
                      color: avatarColor,
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
                    Text(user,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    Row(
                      children: [
                        AppWidgets.onlineDot(online: index % 2 == 0),
                        const SizedBox(width: 5),
                        Text(time,
                            style: AppStyles.subHeading.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 14),
          Text(content, style: AppStyles.body),
          const SizedBox(height: 12),
          if (tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: tags
                  .map((tag) => AppWidgets.badge(tag, AppColors.primary))
                  .toList(),
            ),
          if (tags.isNotEmpty) const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    item['liked'] = !liked;
                    item['likes'] = liked ? likes - 1 : likes + 1;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: liked ? AppColors.accent : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(likes.toString(),
                        style: TextStyle(
                            color: liked ? AppColors.accent : Colors.grey,
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      color: Colors.grey, size: 20),
                  const SizedBox(width: 6),
                  Text(comments.toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              const Spacer(),
              const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
              const SizedBox(width: 16),
              const Icon(Icons.bookmark_border_rounded,
                  color: Colors.grey, size: 20),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 100 * index))
        .slideY(begin: 0.1);
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
            _navItem(Icons.forum_rounded, 1),
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
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ForumPage()));
        }
        if (index == 2) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => EvenementPage()));
        }
        if (index == 3) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ProfilPage()));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: isActive ? AppColors.primary : Colors.grey, size: 26),
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
              Text("QUICK POST",
                  style: AppStyles.heading.copyWith(fontSize: 16)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _postController,
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
              const Icon(Icons.tag_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text("Add tags to reach the right players",
                  style: AppStyles.subHeading),
              const Spacer(),
              ElevatedButton(
                onPressed: _submitPost,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("POST",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
