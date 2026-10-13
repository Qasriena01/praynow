import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelSolatGuidePage extends StatelessWidget {
  const TravelSolatGuidePage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF0EA5E9),
            automaticallyImplyLeading: true,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // ✅ Added this to center the title
              title: const Text(
                'Travel Prayer Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0EA5E9),
                      const Color(0xFF06B6D4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flight_takeoff,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0EA5E9).withOpacity(0.1),
                          const Color(0xFF06B6D4).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF0EA5E9),
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Traveling for work, vacation, or visiting family? Islam makes it easier for travelers to maintain their prayers with special allowances called Qasr and Jamak!',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    '📺 Video Tutorials',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildVideoCard(
                    context,
                    title: 'Prayer While Traveling - Complete Guide',
                    description: 'Learn about Qasr and Jamak prayers for travelers',
                    thumbnail: Icons.play_circle_filled,
                    duration: '2.00',
                    youtubeUrl: 'https://www.youtube.com/shorts/axtUDprWYKc',
                    color: const Color(0xFFEF4444),
                  ),

                  const SizedBox(height: 12),

                  _buildVideoCard(
                    context,
                    title: 'How to Combine Prayers (Jamak)',
                    description: 'Step-by-step tutorial on combining prayers',
                    thumbnail: Icons.play_circle_filled,
                    duration: '0.30',
                    youtubeUrl: 'https://www.youtube.com/shorts/Cn-5eqxozkU',
                    color: const Color(0xFFF59E0B),
                  ),

                  const SizedBox(height: 12),

                  _buildVideoCard(
                    context,
                    title: 'Shortening Prayers (Qasr) Explained',
                    description: 'When and how to shorten your prayers while traveling',
                    thumbnail: Icons.play_circle_filled,
                    duration: '1.22',
                    youtubeUrl: 'https://www.youtube.com/shorts/9BjsdOk-ieo',
                    color: const Color(0xFF10B981),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    '📖 Step-by-Step Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildGuideSection(
                    '1️⃣ Who is a Musafir (Traveler)?',
                    'A musafir is someone who:\n\n'
                    '• Travels approximately 77 km (48 miles) or more from home\n'
                    '• Intends to stay at their destination for less than 15 days\n'
                    '• Has left their hometown/city of residence\n\n'
                    'Examples:\n'
                    '✓ Business trip from New York to Boston for 5 days\n'
                    '✓ Family vacation from London to Paris for a week\n'
                    '✓ Work assignment in another city for 10 days',
                    Icons.person_pin_circle,
                    const Color(0xFF0EA5E9),
                  ),

                  const SizedBox(height: 16),

                  _buildGuideSection(
                    '2️⃣ Qasr - Shortening Prayers',
                    'As a traveler, you can shorten 4-rakaat prayers to just 2 rakaats!\n\n'
                    'Prayers that can be shortened:\n'
                    '• Dhuhr: 4 rakaats → 2 rakaats\n'
                    '• Asr: 4 rakaats → 2 rakaats\n'
                    '• Isha: 4 rakaats → 2 rakaats\n\n'
                    'Prayers that remain the same:\n'
                    '✓ Fajr: 2 rakaats (no change)\n'
                    '✓ Maghrib: 3 rakaats (no change)\n\n'
                    '💡 This makes prayer easier when you\'re on the move!',
                    Icons.content_cut,
                    const Color(0xFF10B981),
                  ),

                  const SizedBox(height: 16),

                  _buildGuideSection(
                    '3️⃣ Jamak - Combining Prayers',
                    'You can combine two prayers at one time:\n\n'
                    '📌 Jamak Taqdim (Early Combination):\n'
                    'Pray the second prayer during the first prayer time\n\n'
                    '• Dhuhr + Asr together at Dhuhr time\n'
                    '• Maghrib + Isha together at Maghrib time\n\n'
                    '📌 Jamak Takhir (Late Combination):\n'
                    'Delay the first prayer to the second prayer time\n\n'
                    '• Dhuhr + Asr together at Asr time\n'
                    '• Maghrib + Isha together at Isha time\n\n'
                    '💡 Perfect when you\'re at the airport or on a long drive!',
                    Icons.link,
                    const Color(0xFFF59E0B),
                  ),

                  const SizedBox(height: 16),

                  _buildGuideSection(
                    '4️⃣ When Can I Use These?',
                    'You can use Qasr and Jamak when:\n\n'
                    '✅ During your journey (in car, plane, train, bus)\n'
                    '✅ At your destination if staying less than 15 days\n'
                    '✅ On your return journey home\n\n'
                    'You should NOT use them when:\n\n'
                    '❌ You have reached home\n'
                    '❌ You intend to stay 15 days or more at destination\n'
                    '❌ Your daily commute (even if far)',
                    Icons.event_available,
                    const Color(0xFF8B5CF6),
                  ),

                  const SizedBox(height: 16),

                  _buildGuideSection(
                    '💡 Important Tips',
                    '• Qasr and Jamak are CONCESSIONS, not obligations\n'
                    '  → You can choose to pray full prayers if you prefer\n\n'
                    '• Make the correct intention (niyyah) before starting prayer\n\n'
                    '• If praying behind a resident imam, complete full prayers\n\n'
                    '• Download a prayer time app for your travel location\n\n'
                    '• You cannot combine Fajr with any other prayer',
                    Icons.tips_and_updates,
                    const Color(0xFFEC4899),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0EA5E9).withOpacity(0.1),
                          const Color(0xFF06B6D4).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Color(0xFFEF4444),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'May Allah accept your prayers wherever you are! Travel safely and may your journey be blessed.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData thumbnail,
    required String duration,
    required String youtubeUrl,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _launchURL(youtubeUrl),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    thumbnail,
                    color: Colors.white,
                    size: 40,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Watch Tutorial',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.8),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}