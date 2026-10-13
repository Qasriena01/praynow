import 'package:flutter/material.dart';
import 'package:praynow/screens/surah_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  // ✅ ADD: State variables for Continue Reading
  String lastReadSurahName = "Al-Fatihah";
  int lastReadSurahNumber = 1;
  int lastReadVerse = 1;
  int lastReadTotalVerses = 7;
  bool isLoadingLastRead = true;

  final List<Map<String, dynamic>> surahs = [
    {
      'number': 1,
      'name': 'Al-Fatihah',
      'arabic': 'الفاتحة',
      'translation': 'The Opening',
      'verses': 7,
      'revelation': 'Meccan',
      'color': const Color(0xFF0F766E), // Teal
    },
    {
      'number': 2,
      'name': 'Al-Baqarah',
      'arabic': 'البقرة',
      'translation': 'The Cow',
      'verses': 286,
      'revelation': 'Medinan',
      'color': const Color(0xFF14B8A6), // Cyan
    },
    {
      'number': 3,
      'name': 'Ali \'Imran',
      'arabic': 'آل عمران',
      'translation': 'Family of Imran',
      'verses': 200,
      'revelation': 'Medinan',
      'color': const Color(0xFF0F766E),
    },
    {
      'number': 4,
      'name': 'An-Nisa',
      'arabic': 'النساء',
      'translation': 'The Women',
      'verses': 176,
      'revelation': 'Medinan',
      'color': const Color(0xFF14B8A6),
    },
    {
      'number': 5,
      'name': 'Al-Ma\'idah',
      'arabic': 'المائدة',
      'translation': 'The Table Spread',
      'verses': 120,
      'revelation': 'Medinan',
      'color': const Color(0xFF0F766E),
    },
  ];

  // ✅ ADD: Load last read on init
  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  // ✅ ADD: Load last read from SharedPreferences
  Future<void> _loadLastRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (mounted) {
        setState(() {
          lastReadSurahName = prefs.getString('last_read_surah_name') ?? 'Al-Fatihah';
          lastReadSurahNumber = prefs.getInt('last_read_surah_number') ?? 1;
          lastReadVerse = prefs.getInt('last_read_verse') ?? 1;
          lastReadTotalVerses = prefs.getInt('last_read_total_verses') ?? 7;
          isLoadingLastRead = false;
        });
      }
    } catch (e) {
      print('Error loading last read: $e');
      if (mounted) {
        setState(() {
          isLoadingLastRead = false;
        });
      }
    }
  }

  // ✅ ADD: Save and open surah
  Future<void> _openSurah(Map<String, dynamic> surah) async {
    try {
      // Save as last read
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_read_surah_name', surah['name']);
      await prefs.setInt('last_read_surah_number', surah['number']);
      await prefs.setInt('last_read_verse', 1);
      await prefs.setInt('last_read_total_verses', surah['verses']);
      
      // Update UI
      if (mounted) {
        setState(() {
          lastReadSurahName = surah['name'];
          lastReadSurahNumber = surah['number'];
          lastReadVerse = 1;
          lastReadTotalVerses = surah['verses'];
        });
      }
      
      // Navigate to detail
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahDetailPage(surah: surah),
          ),
        ).then((_) {
          // Reload when coming back
          _loadLastRead();
        });
      }
    } catch (e) {
      print('Error opening surah: $e');
    }
  }

  // ✅ ADD: Continue reading function
  void _continueReading() {
    final surah = surahs.firstWhere(
      (s) => s['number'] == lastReadSurahNumber,
      orElse: () => surahs[0],
    );
    _openSurah(surah);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total verses from the 5 surahs
    int totalVerses = surahs.fold(0, (sum, surah) => sum + (surah['verses'] as int));
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Simple App Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF14B8A6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'القرآن الكريم',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The Holy Quran',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats Row - Updated with correct counts
                    Row(
                      children: [
                        _buildStatBox('5', 'Surahs'),
                        const SizedBox(width: 12),
                        _buildStatBox('$totalVerses', 'Verses'),
                        const SizedBox(width: 12),
                        _buildStatBox('3', 'Juz'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ✅ UPDATED: Dynamic Last Read Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: _continueReading, // ✅ Make it tappable
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F766E).withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: Color(0xFF0F766E),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Continue Reading',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lastReadSurahName, // ✅ Dynamic
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Verse $lastReadVerse of $lastReadTotalVerses', // ✅ Dynamic
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Surahs List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Surahs',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '5 Loaded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Surahs List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final surah = surahs[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == surahs.length - 1 ? 0 : 12,
                      ),
                      child: _buildSurahCard(surah),
                    );
                  },
                  childCount: surahs.length,
                ),
              ),
            ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahCard(Map<String, dynamic> surah) {
    return InkWell(
      onTap: () => _openSurah(surah), // ✅ UPDATED: Use new function
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Surah Number Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: surah['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${surah['number']}',
                  style: TextStyle(
                    color: surah['color'],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Surah Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          surah['translation'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${surah['verses']} verses',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: surah['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      surah['revelation'],
                      style: TextStyle(
                        fontSize: 10,
                        color: surah['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Arabic Name & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah['arabic'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: surah['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: surah['color'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}