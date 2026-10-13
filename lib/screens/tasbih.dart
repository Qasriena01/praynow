// FILE: lib/tasbih_page.dart
// Enhanced version with user-friendly features
// Optimized for Vivo 1901 (720x1520, 6.22" screen)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _dhikrList = [
    {
      'arabic': 'سُبْحَانَ اللّٰهِ',
      'transliteration': 'Subhanallah',
      'meaning': 'Glory be to Allah',
      'target': 33,
    },
    {
      'arabic': 'الْحَمْدُ لِلّٰهِ',
      'transliteration': 'Alhamdulillah',
      'meaning': 'All praise is due to Allah',
      'target': 33,
    },
    {
      'arabic': 'اللّٰهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'meaning': 'Allah is the Greatest',
      'target': 33,
    },
    {
      'arabic': 'لَا إِلٰهَ إِلَّا اللّٰهُ',
      'transliteration': 'La ilaha illallah',
      'meaning': 'There is no god but Allah',
      'target': 100,
    },
    {
      'arabic': 'أَسْتَغْفِرُ اللّٰهَ',
      'transliteration': 'Astaghfirullah',
      'meaning': 'I seek forgiveness from Allah',
      'target': 100,
    },
  ];

  int _selectedDhikrIndex = 0;
  bool _hasShownCompletionDialog = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Delay initial load to ensure widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCount();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCount() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Small delay to ensure preferences are ready (Android 8 workaround)
      await Future.delayed(const Duration(milliseconds: 50));
      
      if (!mounted) return;
      
      setState(() {
        _count = prefs.getInt('tasbih_count_$_selectedDhikrIndex') ?? 0;
        _hasShownCompletionDialog = prefs.getBool('completion_shown_$_selectedDhikrIndex') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERROR in _loadCount: $e');
      
      if (!mounted) return;
      
      setState(() {
        _count = 0;
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading count: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_count_$_selectedDhikrIndex', _count);
      await prefs.setBool('completion_shown_$_selectedDhikrIndex', _hasShownCompletionDialog);
    } catch (e) {
      print('❌ ERROR in _saveCount: $e');
    }
  }

  void _incrementCount() {
    _animationController.forward().then((_) => _animationController.reverse());
    
    setState(() {
      _count++;
      _saveCount();
      
      // Check if target is reached and show dialog
      if (_count >= _target && !_hasShownCompletionDialog) {
        _hasShownCompletionDialog = true;
        _saveCount();
        
        // Show completion dialog after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showCompletionDialog();
          }
        });
      }
    });
  }

  void _showCompletionDialog() {
    final currentDhikr = _dhikrList[_selectedDhikrIndex];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: Color(0xFF10B981),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Goal Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve completed your ${currentDhikr['transliteration']} target!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFF10B981).withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    currentDhikr['arabic'],
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🎉 $_target times',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You can continue or reset to start again',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCount();
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Alhamdulillah!'),
          ),
        ],
      ),
    );
  }

  void _resetCount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Counter'),
          ],
        ),
        content: Text(
          'Reset progress for "${_dhikrList[_selectedDhikrIndex]['transliteration']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _count = 0;
                _hasShownCompletionDialog = false;
                _saveCount();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Counter reset successfully'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _changeDhikr(int index) async {
    setState(() {
      _selectedDhikrIndex = index;
      _target = _dhikrList[index]['target'];
    });
    await _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    final currentDhikr = _dhikrList[_selectedDhikrIndex];
    final progress = (_count / _target).clamp(0.0, 1.0);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen
    final isSmallScreen = screenHeight < 700;
    final arabicFontSize = isSmallScreen ? 40.0 : 48.0;
    final transliterationSize = isSmallScreen ? 18.0 : 20.0;
    final progressRingSize = isSmallScreen ? 150.0 : 180.0;
    final tapButtonSize = isSmallScreen ? 140.0 : 160.0;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
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
          ),
          title: const Text(
            'Digital Tasbih',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF14B8A6),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
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
        ),
        title: const Text(
          'Digital Tasbih',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFF14B8A6)),
                      SizedBox(width: 8),
                      Text('How to Use'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('1', 'Select your dhikr from the top'),
                      _buildInfoItem('2', 'Tap the button to count'),
                      _buildInfoItem('3', 'Reach your target to complete'),
                      _buildInfoItem('4', 'Reset anytime to start over'),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                      ),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Dhikr Selector - Compact for small screens
          Container(
            height: isSmallScreen ? 85 : 100,
            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _dhikrList.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedDhikrIndex;
                return GestureDetector(
                  onTap: () => _changeDhikr(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(isSelected ? 1 : 0.3),
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _dhikrList[index]['transliteration'],
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFF0F766E) 
                                : Colors.white,
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_dhikrList[index]['target']}x',
                          style: TextStyle(
                            color: isSelected 
                                ? const Color(0xFF0F766E).withOpacity(0.7) 
                                : Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadCount,
              color: const Color(0xFF14B8A6),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - (isSmallScreen ? 185 : 200),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: isSmallScreen ? 12 : 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Arabic Text Card
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              gradient: progress >= 1.0
                                  ? LinearGradient(
                                      colors: [
                                        Colors.green.shade50,
                                        Colors.green.shade100,
                                      ],
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentDhikr['arabic'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: arabicFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 12),
                                Text(
                                  currentDhikr['transliteration'],
                                  style: TextStyle(
                                    fontSize: transliterationSize,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 4 : 8),
                                Text(
                                  currentDhikr['meaning'],
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // Progress Ring with enhanced styling
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: progressRingSize,
                              height: progressRingSize,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: isSmallScreen ? 10 : 12,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1.0
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF14B8A6),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _count.toString(),
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 48 : 56,
                                    fontWeight: FontWeight.bold,
                                    color: progress >= 1.0
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  'of $_target',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (progress >= 1.0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Completed!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 8 : 12),

                        // Progress percentage
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% Complete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: progress >= 1.0
                                ? const Color(0xFF10B981)
                                : const Color(0xFF0F766E),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 20 : 32),

                        // Tap Button with enhanced styling
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: GestureDetector(
                            onTap: _incrementCount,
                            child: Container(
                              width: tapButtonSize,
                              height: tapButtonSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: progress >= 1.0
                                      ? [
                                          const Color(0xFF10B981),
                                          const Color(0xFF059669),
                                        ]
                                      : [
                                          const Color(0xFF0F766E),
                                          const Color(0xFF14B8A6),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (progress >= 1.0
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF14B8A6))
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'TAP',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 24 : 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Icon(
                                      Icons.touch_app,
                                      color: Colors.white.withOpacity(0.8),
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // Reset Button with enhanced styling
                        OutlinedButton.icon(
                          onPressed: _resetCount,
                          icon: Icon(Icons.refresh, size: isSmallScreen ? 18 : 20),
                          label: Text(
                            'Reset Counter',
                            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0F766E),
                            side: const BorderSide(
                              color: Color(0xFF0F766E),
                              width: 2,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 24 : 32,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF14B8A6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}