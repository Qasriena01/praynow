import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart'; // Add this to pubspec.yaml

class SurahDetailPage extends StatefulWidget {
  final Map<String, dynamic> surah;

  const SurahDetailPage({
    super.key,
    required this.surah,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  bool showTranslation = true;
  bool showTransliteration = false;
  double arabicFontSize = 26.0;
  double translationFontSize = 15.0;
  
  List<Map<String, dynamic>> ayatList = [];
  bool isLoading = true;
  String errorMessage = "";
  
  // Audio player
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlayingFullSurah = false;
  int? currentPlayingVerse;
  bool isLoadingAudio = false;

  // Bookmark state
  bool isBookmarked = false;
  int lastReadVerse = 1;

  // ✅ Consistent teal colors matching homepage
  final Color primaryColor = const Color(0xFF14B8A6);
  final Color darkTeal = const Color(0xFF0F766E);

  @override
  void initState() {
    super.initState();
    _loadReadingSettings(); // ✅ Load settings first
    _loadBookmarkStatus();
    _loadLastReadVerse();
    _fetchSurahData();
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF8F9FA),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            isPlayingFullSurah = false;
            currentPlayingVerse = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    audioPlayer.pause();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    audioPlayer.pause();
    super.deactivate();
  }

  // ✅ NEW: Load reading settings from SharedPreferences
  Future<void> _loadReadingSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          arabicFontSize = prefs.getDouble('arabic_font_size') ?? 26.0;
          translationFontSize = prefs.getDouble('translation_font_size') ?? 15.0;
          showTranslation = prefs.getBool('show_translation') ?? true;
          showTransliteration = prefs.getBool('show_transliteration') ?? false;
        });
      }
    } catch (e) {
      print('Error loading reading settings: $e');
    }
  }

  // ✅ NEW: Save reading settings
  Future<void> _saveReadingSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('arabic_font_size', arabicFontSize);
      await prefs.setDouble('translation_font_size', translationFontSize);
      await prefs.setBool('show_translation', showTranslation);
      await prefs.setBool('show_transliteration', showTransliteration);
    } catch (e) {
      print('Error saving reading settings: $e');
    }
  }

  // ✅ Load bookmark status
  Future<void> _loadBookmarkStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarked = prefs.getBool('bookmark_surah_${widget.surah['number']}') ?? false;
      if (mounted) {
        setState(() {
          isBookmarked = bookmarked;
        });
      }
    } catch (e) {
      print('Error loading bookmark: $e');
    }
  }

  // ✅ UPDATED: Toggle bookmark with proper save to bookmarks list
  Future<void> _toggleBookmark() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newStatus = !isBookmarked;
      
      // Save individual bookmark status
      await prefs.setBool('bookmark_surah_${widget.surah['number']}', newStatus);
      
      // ✅ Save to bookmarks list for the Quran page
      List<String> bookmarks = prefs.getStringList('bookmarked_surahs') ?? [];
      
      if (newStatus) {
        // Add to bookmarks
        final bookmarkData = jsonEncode({
          'number': widget.surah['number'],
          'name': widget.surah['name'],
          'arabic': widget.surah['arabic'],
          'translation': widget.surah['translation'],
          'verses': widget.surah['verses'],
          'revelation': widget.surah['revelation'],
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        
        if (!bookmarks.contains(bookmarkData)) {
          bookmarks.add(bookmarkData);
        }
      } else {
        // Remove from bookmarks
        bookmarks.removeWhere((item) {
          final data = jsonDecode(item);
          return data['number'] == widget.surah['number'];
        });
      }
      
      await prefs.setStringList('bookmarked_surahs', bookmarks);
      
      if (mounted) {
        setState(() {
          isBookmarked = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  newStatus ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(newStatus ? 'Bookmark added' : 'Bookmark removed'),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Load last read verse
  Future<void> _loadLastReadVerse() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verse = prefs.getInt('last_read_verse_surah_${widget.surah['number']}') ?? 1;
      if (mounted) {
        setState(() {
          lastReadVerse = verse;
        });
      }
    } catch (e) {
      print('Error loading last read verse: $e');
    }
  }

  // ✅ Save reading progress
  Future<void> _saveReadingProgress(int verseNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_read_verse_surah_${widget.surah['number']}', verseNumber);
      
      // Also save as the global last read surah
      await prefs.setString('last_read_surah_name', widget.surah['name']);
      await prefs.setInt('last_read_surah_number', widget.surah['number']);
      await prefs.setInt('last_read_verse', verseNumber);
      await prefs.setInt('last_read_total_verses', widget.surah['verses']);
      
      if (mounted) {
        setState(() {
          lastReadVerse = verseNumber;
        });
      }
    } catch (e) {
      print('Error saving reading progress: $e');
    }
  }

  // ✅ NEW: Share full surah
  Future<void> _shareSurah() async {
    try {
      final surahInfo = '''
${widget.surah['arabic']} - ${widget.surah['name']}
${widget.surah['translation']}
${widget.surah['revelation']} • ${widget.surah['verses']} Verses

Read the full Surah on PrayNow app.
''';
      
      await Share.share(
        surahInfo,
        subject: 'Surah ${widget.surah['name']}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ NEW: Share individual verse
  Future<void> _shareVerse(Map<String, dynamic> ayah) async {
    try {
      final verseText = '''
${ayah['arabic']}

${ayah['translation']}

Surah ${widget.surah['name']}, Verse ${ayah['number']}
''';
      
      await Share.share(
        verseText,
        subject: 'Surah ${widget.surah['name']}, Verse ${ayah['number']}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _fetchSurahData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = "";
      });

      final surahNumber = widget.surah['number'];
      
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,en.sahih,en.transliteration'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final surahData = data['data'];

        final arabicEdition = surahData[0]['ayahs'];
        final translationEdition = surahData[1]['ayahs'];
        final transliterationEdition = surahData[2]['ayahs'];

        List<Map<String, dynamic>> verses = [];

        for (int i = 0; i < arabicEdition.length; i++) {
          verses.add({
            'number': arabicEdition[i]['numberInSurah'],
            'numberInQuran': arabicEdition[i]['number'],
            'arabic': arabicEdition[i]['text'],
            'translation': translationEdition[i]['text'],
            'transliteration': transliterationEdition[i]['text'],
          });
        }

        if (mounted) {
          setState(() {
            ayatList = verses;
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load surah data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading verses: $e';
          isLoading = false;
        });
      }
    }
  }

  // Play full surah
  Future<void> _playFullSurah() async {
    try {
      if (isPlayingFullSurah) {
        await audioPlayer.stop();
        if (mounted) {
          setState(() {
            isPlayingFullSurah = false;
            currentPlayingVerse = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          isLoadingAudio = true;
        });
      }

      final surahNumber = widget.surah['number'].toString().padLeft(3, '0');
      
      final audioUrls = [
        'https://server8.mp3quran.net/afs/$surahNumber.mp3',
        'https://server11.mp3quran.net/sds/$surahNumber.mp3',
        'https://server6.mp3quran.net/s_gmd/$surahNumber.mp3',
      ];

      bool audioLoaded = false;
      
      for (String audioUrl in audioUrls) {
        try {
          print('Trying to load surah: $audioUrl');
          await audioPlayer.setUrl(audioUrl);
          audioLoaded = true;
          print('Successfully loaded surah: $audioUrl');
          break;
        } catch (e) {
          print('Failed to load surah from $audioUrl: $e');
          continue;
        }
      }

      if (!audioLoaded) {
        throw Exception('Could not load surah audio. Please check your internet connection.');
      }

      await audioPlayer.play();
      
      if (mounted) {
        setState(() {
          isPlayingFullSurah = true;
          isLoadingAudio = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.play_circle_filled, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Playing Surah ${widget.surah['name']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingAudio = false;
          isPlayingFullSurah = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Play individual verse
  Future<void> _playVerse(int verseNumber, int verseNumberInQuran) async {
    try {
      if (currentPlayingVerse == verseNumber) {
        await audioPlayer.stop();
        if (mounted) {
          setState(() {
            currentPlayingVerse = null;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          isLoadingAudio = true;
        });
      }

      if (isPlayingFullSurah) {
        await audioPlayer.stop();
        if (mounted) {
          setState(() {
            isPlayingFullSurah = false;
          });
        }
      }

      final surahNum = widget.surah['number'].toString().padLeft(3, '0');
      final verseNum = verseNumber.toString().padLeft(3, '0');
      
      final audioUrls = [
        'https://everyayah.com/data/Alafasy_128kbps/$surahNum$verseNum.mp3',
        'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/$surahNum$verseNum.mp3',
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$surahNum$verseNum.mp3',
      ];

      bool audioLoaded = false;
      
      for (String audioUrl in audioUrls) {
        try {
          print('Trying to load: $audioUrl');
          await audioPlayer.setUrl(audioUrl);
          audioLoaded = true;
          print('Successfully loaded: $audioUrl');
          break;
        } catch (e) {
          print('Failed to load from $audioUrl: $e');
          continue;
        }
      }

      if (!audioLoaded) {
        throw Exception('Could not load audio. Please check your internet connection.');
      }

      await audioPlayer.play();
      
      await _saveReadingProgress(verseNumber);
      
      if (mounted) {
        setState(() {
          currentPlayingVerse = verseNumber;
          isLoadingAudio = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingAudio = false;
          currentPlayingVerse = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with teal gradient
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: primaryColor,
            leading: Container(
              margin: const EdgeInsets.only(left: 4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.all(8),
              ),
            ),
            actions: [
              // ✅ Functional bookmark button
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _toggleBookmark,
                padding: const EdgeInsets.all(8),
              ),
              // ✅ Functional share button
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 22),
                onPressed: _shareSurah,
                padding: const EdgeInsets.all(8),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                padding: const EdgeInsets.all(8),
                onSelected: (value) {
                  if (value == 'settings') {
                    _showReadingSettings();
                  } else if (value == 'refresh') {
                    _fetchSurahData();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, size: 20),
                        SizedBox(width: 12),
                        Text('Reading Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 12),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      darkTeal,
                      primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Text(
                        widget.surah['arabic'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.surah['name'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.surah['translation'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.surah['revelation']} • ${widget.surah['verses']} Verses',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading or Content
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading verses...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (errorMessage.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchSurahData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            // Bismillah
            if (widget.surah['number'] != 9)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
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
                  child: const Center(
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                        height: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: isPlayingFullSurah 
                            ? Icons.stop_circle_outlined 
                            : Icons.play_circle_outline,
                        label: isPlayingFullSurah 
                            ? 'Stop' 
                            : 'Play Surah',
                        color: primaryColor,
                        onTap: _playFullSurah,
                        isLoading: isLoadingAudio && isPlayingFullSurah,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildQuickActionButton(
                        icon: showTranslation
                            ? Icons.visibility_off
                            : Icons.visibility,
                        label: showTranslation
                            ? 'Hide Trans.'
                            : 'Show Trans.',
                        color: primaryColor,
                        onTap: () async {
                          setState(() {
                            showTranslation = !showTranslation;
                          });
                          await _saveReadingSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Verse Count Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Loaded ${ayatList.length} verses • Last read: Verse $lastReadVerse',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Ayat List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ayah = ayatList[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == ayatList.length - 1 ? 0 : 14,
                      ),
                      child: _buildAyahCard(ayah),
                    );
                  },
                  childCount: ayatList.length,
                ),
              ),
            ),

            // End of Surah
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.check_circle_outline,
                      color: primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'End of Surah ${widget.surah['name']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'صَدَقَ اللهُ الْعَظِيمْ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Allah Almighty has spoken the truth',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 60 + bottomPadding),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahCard(Map<String, dynamic> ayah) {
    final isLastRead = ayah['number'] == lastReadVerse;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLastRead 
            ? Border.all(color: primaryColor, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Last read indicator
          if (isLastRead)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark, color: primaryColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Continue from here',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          
          // Verse Number Header
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.8),
                      primaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${ayah['number']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.bookmark_border,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () {
                  _saveReadingProgress(ayah['number']);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked verse ${ayah['number']} as last read'),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              // ✅ Functional share button
              IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: () => _shareVerse(ayah),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  currentPlayingVerse == ayah['number']
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  color: primaryColor,
                  size: 24,
                ),
                onPressed: () {
                  _playVerse(ayah['number'], ayah['numberInQuran']);
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Arabic Text
          Text(
            ayah['arabic'],
            style: TextStyle(
              fontSize: arabicFontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
              height: 2,
            ),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 14),

          // Transliteration (optional)
          if (showTransliteration) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ayah['transliteration'],
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber.shade900,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Translation
          if (showTranslation) ...[
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 14),
            Text(
              ayah['translation'],
              style: TextStyle(
                fontSize: translationFontSize,
                color: Colors.grey[800],
                height: 1.7,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showReadingSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const Text(
                      'Reading Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Arabic Font Size
                    const Text(
                      'Arabic Font Size',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: arabicFontSize,
                      min: 20,
                      max: 40,
                      divisions: 10,
                      label: arabicFontSize.round().toString(),
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          arabicFontSize = value;
                        });
                        _saveReadingSettings(); // ✅ Save immediately
                      },
                    ),
                    const SizedBox(height: 12),

                    // Translation Font Size
                    const Text(
                      'Translation Font Size',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Slider(
                      value: translationFontSize,
                      min: 12,
                      max: 20,
                      divisions: 8,
                      label: translationFontSize.round().toString(),
                      activeColor: primaryColor,
                      onChanged: (value) {
                        setState(() {
                          translationFontSize = value;
                        });
                        _saveReadingSettings(); // ✅ Save immediately
                      },
                    ),
                    const SizedBox(height: 12),

                    // Show Translation Toggle
                    SwitchListTile(
                      title: const Text('Show Translation'),
                      value: showTranslation,
                      activeThumbColor: primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      onChanged: (value) {
                        setState(() {
                          showTranslation = value;
                        });
                        _saveReadingSettings(); // ✅ Save immediately
                      },
                    ),

                    // Show Transliteration Toggle
                    SwitchListTile(
                      title: const Text('Show Transliteration'),
                      value: showTransliteration,
                      activeThumbColor: primaryColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                      onChanged: (value) {
                        setState(() {
                          showTransliteration = value;
                        });
                        _saveReadingSettings(); // ✅ Save immediately
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}