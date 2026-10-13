import 'package:flutter/material.dart';

class HadithPage extends StatelessWidget {
  const HadithPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hadiths = [
      {
        'title': 'The Intention',
        'arabic': 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
        'hadith': 'Actions are judged by intentions, so each man will have what he intended.',
        'source': 'Sahih Bukhari',
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Best of People',
        'arabic': 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
        'hadith': 'The best of people are those who are most beneficial to people.',
        'source': 'Al-Mu\'jam al-Awsat',
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Paradise at Mother\'s Feet',
        'arabic': 'الْجَنَّةُ تَحْتَ أَقْدَامِ الأُمَّهَاتِ',
        'hadith': 'Paradise lies at the feet of your mother.',
        'source': 'Sunan An-Nasa\'i',
        'color': const Color(0xFFEC4899),
      },
      {
        'title': 'The Believer\'s Mirror',
        'arabic': 'الْمُؤْمِنُ مِرْآةُ الْمُؤْمِنِ',
        'hadith': 'The believer is the mirror of his brother. If he sees any fault in him, he corrects it.',
        'source': 'Abu Dawud',
        'color': const Color(0xFF0EA5E9),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF59E0B),
            automaticallyImplyLeading: true,
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true, // ✅ Added this to center the title
              title: const Text(
                'Hadith Collection',
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
                      const Color(0xFFF59E0B),
                      const Color(0xFFEF4444),
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
                      Icons.lightbulb_outline,
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
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withOpacity(0.1),
                      const Color(0xFFEF4444).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Color(0xFFF59E0B),
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Wisdom from Prophet Muhammad ﷺ',
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
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final hadith = hadiths[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (hadith['color'] as Color).withOpacity(0.3),
                        width: 1,
                      ),
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
                                    (hadith['color'] as Color).withOpacity(0.8),
                                    hadith['color'] as Color,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: (hadith['color'] as Color).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.format_quote,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hadith['title'].toString(),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: hadith['color'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),

                        Text(
                          hadith['arabic'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.8,
                          ),
                          textAlign: TextAlign.right,
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hadith['hadith'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(
                              Icons.source,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '— ${hadith['source'].toString()}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: hadiths.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}