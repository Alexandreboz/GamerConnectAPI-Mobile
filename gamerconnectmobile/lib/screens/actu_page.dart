import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/design_system.dart';
import '../services/api_service.dart';
import 'actu_detail_page.dart';

class ActuPage extends StatefulWidget {
  @override
  _ActuPageState createState() => _ActuPageState();
}

class _ActuPageState extends State<ActuPage> {
  late Future<List<dynamic>> _actusFuture;

  @override
  void initState() {
    super.initState();
    _actusFuture = ApiService.getActus();
  }

  Widget _buildImage(String image) {
    if (image.startsWith('http')) {
      return Image.network(image, width: 70, height: 70, fit: BoxFit.cover);
    }
    return Image.asset(image, width: 70, height: 70, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GAMING NEWS',
            style: AppStyles.heading.copyWith(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _actusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Impossible de charger les actus',
                    style: AppStyles.subHeading));
          }
          final actus = snapshot.data ?? [];
          if (actus.isEmpty) {
            return Center(
                child: Text('Aucune actualité disponible',
                    style: AppStyles.subHeading));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: actus.length,
            itemBuilder: (context, index) {
              final actu = actus[index] as Map<String, dynamic>;
              final image = actu['image']?.toString() ?? '';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ActuDetailPage(
                        jeu: actu['jeu']?.toString() ?? '',
                        titre: actu['titre']?.toString() ?? '',
                        contenu: actu['contenu']?.toString() ?? '',
                        image: image,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: AppStyles.cardDecoration,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(image),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              actu['jeu']?.toString().toUpperCase() ?? '',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              actu['titre']?.toString() ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.grey, size: 16),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideX(begin: 0.1),
              );
            },
          );
        },
      ),
    );
  }
}
