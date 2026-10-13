import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HijriCalendarPage extends StatefulWidget {
  const HijriCalendarPage({super.key});

  @override
  State<HijriCalendarPage> createState() => _HijriCalendarPageState();
}

class _HijriCalendarPageState extends State<HijriCalendarPage> {
  late Future<Map<String, dynamic>> _hijriDateFuture;

  @override
  void initState() {
    super.initState();
    _hijriDateFuture = _fetchHijriDate();
  }

  Future<Map<String, dynamic>> _fetchHijriDate() async {
    try {
      final now = DateTime.now();
      final url = Uri.parse(
        'http://api.aladhan.com/v1/gToH/${now.day}-${now.month}-${now.year}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        throw Exception('Failed to load Hijri date');
      }
    } catch (e) {
      // Return default data if API fails
      return {
        'hijri': {
          'date': '23-06-1446',
          'format': '23 Dhul-Hijjah 1446',
          'day': '23',
          'month': {'number': 12, 'en': 'Dhul-Hijjah', 'ar': 'ذُو الحِجَّة'},
          'year': '1446',
        },
        'gregorian': {
          'date': '23-01-2025',
          'format': '23 January 2025',
          'day': '23',
          'month': {'number': 1, 'en': 'January'},
          'year': '2025',
        },
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _hijriDateFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF8B5CF6),
              ),
            );
          }

          final hijriData = snapshot.data ?? {};
          final hijri = hijriData['hijri'] ?? {};
          final gregorian = hijriData['gregorian'] ?? {};

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF8B5CF6),
                automaticallyImplyLeading: true,
                actions: const [],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true, // ✅ Added this to center the title
                  title: const Text(
                    'Islamic Calendar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFF7C3AED),
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
                          Icons.calendar_month,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Current Date Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                          const Color(0xFF7C3AED).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          hijri['month']?['ar'] ?? 'شَعْبَان',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFF8B5CF6),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${hijri['day']} ${hijri['month']?['en'] ?? 'Sha\'ban'} ${hijri['year']} AH',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8B5CF6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // All 12 Islamic Months
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'The 12 Islamic Months',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on the lunar calendar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildAllIslamicMonths(
                        int.tryParse(hijri['month']?['number']?.toString() ?? '1') ?? 1,
                      ),
                    ],
                  ),
                ),
              ),

              // Important Islamic Dates
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Important Islamic Dates',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Significant events throughout the year',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildImportantDates(),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildAllIslamicMonths(int currentMonth) {
    final months = [
      {
        'number': 1,
        'arabic': 'مُحَرَّم',
        'english': 'Muharram',
        'transliteration': 'Muḥarram',
        'description': 'Sacred month, Ashura on 10th',
        'days': 29,
      },
      {
        'number': 2,
        'arabic': 'صَفَر',
        'english': 'Safar',
        'transliteration': 'Ṣafar',
        'description': 'Month of travel and journeys',
        'days': 30,
      },
      {
        'number': 3,
        'arabic': 'رَبِيع الأول',
        'english': 'Rabi\' al-Awwal',
        'transliteration': 'Rabīʿ al-Awwal',
        'description': 'Prophet Muhammad\'s birth (12th)',
        'days': 30,
      },
      {
        'number': 4,
        'arabic': 'رَبِيع الثاني',
        'english': 'Rabi\' al-Thani',
        'transliteration': 'Rabīʿ ath-Thānī',
        'description': 'Second spring month',
        'days': 29,
      },
      {
        'number': 5,
        'arabic': 'جُمَادَى الأولى',
        'english': 'Jumada al-Ula',
        'transliteration': 'Jumādá al-Ūlá',
        'description': 'First month of dryness',
        'days': 30,
      },
      {
        'number': 6,
        'arabic': 'جُمَادَى الآخرة',
        'english': 'Jumada al-Akhirah',
        'transliteration': 'Jumādá al-Ākhirah',
        'description': 'Second month of dryness',
        'days': 29,
      },
      {
        'number': 7,
        'arabic': 'رَجَب',
        'english': 'Rajab',
        'transliteration': 'Rajab',
        'description': 'Sacred month, Isra & Mi\'raj (27th)',
        'days': 30,
      },
      {
        'number': 8,
        'arabic': 'شَعْبَان',
        'english': 'Sha\'ban',
        'transliteration': 'Shaʿbān',
        'description': 'Month before Ramadan',
        'days': 29,
      },
      {
        'number': 9,
        'arabic': 'رَمَضَان',
        'english': 'Ramadan',
        'transliteration': 'Ramaḍān',
        'description': 'Month of fasting, Laylat al-Qadr',
        'days': 30,
      },
      {
        'number': 10,
        'arabic': 'شَوّال',
        'english': 'Shawwal',
        'transliteration': 'Shawwāl',
        'description': 'Eid al-Fitr on 1st',
        'days': 29,
      },
      {
        'number': 11,
        'arabic': 'ذُو القَعْدَة',
        'english': 'Dhu al-Qi\'dah',
        'transliteration': 'Dhū al-Qaʿdah',
        'description': 'Sacred month of truce',
        'days': 30,
      },
      {
        'number': 12,
        'arabic': 'ذُو الحِجَّة',
        'english': 'Dhu al-Hijjah',
        'transliteration': 'Dhū al-Ḥijjah',
        'description': 'Month of Hajj, Eid al-Adha (10th)',
        'days': 29,
      },
    ];

    return months.map((month) {
      final isCurrentMonth = month['number'] == currentMonth;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentMonth
              ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
              : Border.all(color: Colors.grey.shade200, width: 1),
          gradient: isCurrentMonth
              ? LinearGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.1),
                    const Color(0xFF7C3AED).withOpacity(0.05),
                  ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isCurrentMonth ? 0.08 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Number Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrentMonth
                      ? [
                          const Color(0xFF8B5CF6),
                          const Color(0xFF7C3AED),
                        ]
                      : [
                          const Color(0xFF8B5CF6).withOpacity(0.7),
                          const Color(0xFF7C3AED).withOpacity(0.7),
                        ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: isCurrentMonth
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  month['number'].toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Month Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          month['english'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentMonth
                                ? const Color(0xFF8B5CF6)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (isCurrentMonth)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    month['arabic'].toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    month['description'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${month['days']} days',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
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
    }).toList();
  }

  List<Widget> _buildImportantDates() {
    final dates = [
      {
        'date': '10 Muharram',
        'event': 'Day of Ashura',
        'description': 'Recommended fasting, day Moses was saved',
        'icon': Icons.favorite,
        'color': const Color(0xFFEF4444),
        'category': 'Sacred',
      },
      {
        'date': '12 Rabi\' al-Awwal',
        'event': 'Mawlid al-Nabi',
        'description': 'Birth of Prophet Muhammad ﷺ',
        'icon': Icons.cake,
        'color': const Color(0xFF10B981),
        'category': 'Celebration',
      },
      {
        'date': '27 Rajab',
        'event': 'Isra and Mi\'raj',
        'description': 'Night Journey and Ascension',
        'icon': Icons.nights_stay,
        'color': const Color(0xFF0EA5E9),
        'category': 'Sacred',
      },
      {
        'date': '15 Sha\'ban',
        'event': 'Laylat al-Bara\'ah',
        'description': 'Night of Forgiveness',
        'icon': Icons.auto_awesome,
        'color': const Color(0xFF8B5CF6),
        'category': 'Sacred',
      },
      {
        'date': '1 Ramadan',
        'event': 'Start of Ramadan',
        'description': 'Beginning of the fasting month',
        'icon': Icons.restaurant,
        'color': const Color(0xFFF59E0B),
        'category': 'Fasting',
      },
      {
        'date': '27 Ramadan',
        'event': 'Laylat al-Qadr',
        'description': 'Night of Power, better than 1000 months',
        'icon': Icons.star,
        'color': const Color(0xFFFBBF24),
        'category': 'Sacred',
      },
      {
        'date': '1 Shawwal',
        'event': 'Eid al-Fitr',
        'description': 'Festival of Breaking the Fast',
        'icon': Icons.celebration,
        'color': const Color(0xFF06B6D4),
        'category': 'Celebration',
      },
      {
        'date': '8 Dhu al-Hijjah',
        'event': 'Day of Tarwiyah',
        'description': 'Pilgrims proceed to Mina',
        'icon': Icons.directions_walk,
        'color': const Color(0xFF8B5CF6),
        'category': 'Hajj',
      },
      {
        'date': '9 Dhu al-Hijjah',
        'event': 'Day of Arafah',
        'description': 'Most important day for pilgrims',
        'icon': Icons.landscape,
        'color': const Color(0xFF059669),
        'category': 'Hajj',
      },
      {
        'date': '10 Dhu al-Hijjah',
        'event': 'Eid al-Adha',
        'description': 'Festival of Sacrifice',
        'icon': Icons.card_giftcard,
        'color': const Color(0xFFEF4444),
        'category': 'Celebration',
      },
      {
        'date': '11-13 Dhu al-Hijjah',
        'event': 'Days of Tashriq',
        'description': 'Days of celebration and remembrance',
        'icon': Icons.sunny,
        'color': const Color(0xFFF59E0B),
        'category': 'Hajj',
      },
    ];

    return dates.map((item) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
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
                        (item['color'] as Color).withOpacity(0.8),
                        item['color'] as Color,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (item['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['event'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['category'].toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: item['color'] as Color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['date'].toString(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['description'].toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}