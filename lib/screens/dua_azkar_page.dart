import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DuaAzkarPage extends StatefulWidget {
  const DuaAzkarPage({super.key});

  @override
  State<DuaAzkarPage> createState() => _DuaAzkarPageState();
}

class _DuaAzkarPageState extends State<DuaAzkarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF6366F1),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF4F46E5),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Dua & Azkar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daily supplications & remembrance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: const Color(0xFF6366F1),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    tabs: const [
                      Tab(text: 'Morning'),
                      Tab(text: 'Evening'),
                      Tab(text: 'Prayers'),
                      Tab(text: 'Daily'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMorningAzkar(),
            _buildEveningAzkar(),
            _buildPrayerDuas(),
            _buildDailyDuas(),
          ],
        ),
      ),
    );
  }

  Widget _buildMorningAzkar() {
    final morningAzkar = [
      {
        'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'transliteration': 'Bismillah ar-Rahman ar-Rahim',
        'meaning': 'In the name of Allah, the Most Compassionate, the Most Merciful',
        'benefits': 'Blessing and purification of all deeds',
      },
      {
        'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'transliteration': 'Alhamdulillahi Rabbi al-Alameen',
        'meaning': 'All praise is due to Allah, Lord of the worlds',
        'benefits': 'Gratitude and contentment',
      },
    ];

    return _buildAzkarList(morningAzkar);
  }

  Widget _buildEveningAzkar() {
    final eveningAzkar = [
      {
        'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        'transliteration': 'Amsayna wa amsaal-mulk lillah',
        'meaning': 'We have reached the evening and with it the dominion of Allah',
        'benefits': 'Protection during the night',
      },
      {
        'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
        'transliteration': "Subhan'Allahi wa bihamdihi",
        'meaning': 'Glory be to Allah and His is the praise',
        'benefits': 'Forgiveness of sins',
      },
    ];

    return _buildAzkarList(eveningAzkar);
  }

  Widget _buildPrayerDuas() {
    final prayerDuas = [
      {
        'title': 'Before Prayer',
        'arabic': 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ',
        'transliteration': "Allahumma a'inni 'ala dhikrika wa shukrika",
        'meaning': 'O Allah, help me to remember You and thank You',
        'time': 'Before prayer',
      },
      {
        'title': 'After Prayer',
        'arabic': 'أَسْتَغْفِرُ اللَّهَ',
        'transliteration': 'Astaghfir-u-Allah',
        'meaning': 'I seek the forgiveness of Allah',
        'time': 'After prayer',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prayerDuas.length,
      itemBuilder: (context, index) {
        final dua = prayerDuas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dua['title'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dua['time'].toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _arabicBox(dua['arabic'].toString()),
                const SizedBox(height: 12),
                _label('Transliteration:'),
                _italic(dua['transliteration'].toString()),
                const SizedBox(height: 12),
                _label('Meaning:'),
                _body(dua['meaning'].toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyDuas() {
    final dailyDuas = [
      {
        'arabic': 'رَبِّ اشْرَحْ لِي صَدْرِي',
        'transliteration': 'Rabbi ishrah li sadri',
        'meaning': 'My Lord, expand for me my breast',
        'category': 'For Ease',
      },
      {
        'arabic': 'اللَّهُمَّ اجْعَلْنِي مِنَ الصَّابِرِينَ',
        'transliteration': "Allahumma ij'alni min as-sabireen",
        'meaning': 'O Allah, make me among the patient ones',
        'category': 'For Patience',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dailyDuas.length,
      itemBuilder: (context, index) {
        final dua = dailyDuas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dua['category'].toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _arabicBox(dua['arabic'].toString()),
                const SizedBox(height: 12),
                _italic(dua['transliteration'].toString()),
                const SizedBox(height: 8),
                _body(dua['meaning'].toString()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAzkarList(List<Map<String, String>> azkarList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: azkarList.length,
      itemBuilder: (context, index) {
        final azkar = azkarList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Azkar #${index + 1}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _arabicBox(azkar['arabic'].toString()),
                const SizedBox(height: 12),
                _label('Transliteration:'),
                _italic(azkar['transliteration'].toString()),
                const SizedBox(height: 12),
                _label('Meaning:'),
                _body(azkar['meaning'].toString()),
                if (azkar.containsKey('benefits')) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: Colors.amber[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          azkar['benefits'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Shared small widgets ─────────────────────────────────────────────────

  Widget _arabicBox(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF6366F1).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF1F2937),
            height: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
      );

  Widget _italic(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 13, color: Colors.grey[700], fontStyle: FontStyle.italic),
      );

  Widget _body(String text) => Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
      );
}