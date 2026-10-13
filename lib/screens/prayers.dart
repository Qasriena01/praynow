import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class PrayersPage extends StatefulWidget {
  const PrayersPage({super.key});

  @override
  State<PrayersPage> createState() => _PrayersPageState();
}

class _PrayersPageState extends State<PrayersPage> with WidgetsBindingObserver {
  bool isLoading = true;
  String currentLocation = "Getting location...";
  String errorMessage = "";
  
  // Prayer times data
  Map<String, String> prayerTimes = {
    'Fajr': '--:--',
    'Sunrise': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };

  String nextPrayer = "Calculating...";
  String nextPrayerTime = "--:--";
  String timeRemaining = "Calculating...";
  
  double? latitude;
  double? longitude;

  // ✅ FIXED: Audio player for adhan with better state management
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAdhan = false;
  
  // Notification plugin
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  // ✅ IMPROVED: More frequent checking (every 30 seconds instead of 1 minute)
  Timer? _prayerCheckTimer;
  final Set<String> _prayersNotified = {};
  String _lastCheckedDate = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _initializeAudioPlayer();
    _initializeLocation();
    _startPrayerTimeChecker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _prayerCheckTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ ADDED: Resume checking when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkAndNotifyPrayer();
    }
  }

  // ✅ NEW: Initialize audio player with proper settings
  Future<void> _initializeAudioPlayer() async {
    // Set audio mode to allow background playback
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    
    // Set volume to maximum
    await _audioPlayer.setVolume(1.0);
    
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlayingAdhan = state == PlayerState.playing;
        });
        print('🔊 Player state changed: $state');
      }
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlayingAdhan = false;
        });
        print('✅ Adhan playback completed');
      }
    });
  }

  Future<void> _initializeNotifications() async {
    // ✅ IMPROVED: Request all necessary permissions
    await Permission.notification.request();
    
    // For Android 13+ (API 33+), request POST_NOTIFICATIONS permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap - could navigate to prayer page or show details
        print('Notification tapped: ${details.payload}');
      },
    );

    // ✅ ADDED: Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'prayer_channel',
      'Prayer Times',
      description: 'Notifications for prayer times',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  void _startPrayerTimeChecker() {
    // ✅ IMPROVED: Check every 30 seconds for more reliable notifications
    _prayerCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAndNotifyPrayer();
      _calculateNextPrayer();
    });
    
    // Also check immediately
    Future.delayed(const Duration(seconds: 2), () {
      _checkAndNotifyPrayer();
    });
  }

  Future<void> _checkAndNotifyPrayer() async {
    if (prayerTimes['Fajr'] == '--:--') return;

    final now = DateTime.now();
    final currentDate = DateFormat('yyyy-MM-dd').format(now);
    
    // ✅ ADDED: Reset notifications at midnight
    if (_lastCheckedDate != currentDate) {
      _prayersNotified.clear();
      _lastCheckedDate = currentDate;
    }

    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    for (var entry in prayerTimes.entries) {
      final prayerName = entry.key;
      if (prayerName == 'Sunrise') continue; // Skip sunrise notification

      final prayerTime24 = _convertTo24Hour(entry.value);
      
      // ✅ IMPROVED: Check if we're within the prayer time minute
      if (currentTime == prayerTime24 && !_prayersNotified.contains(prayerName)) {
        print('🕌 Prayer time reached: $prayerName at ${entry.value}');
        _prayersNotified.add(prayerName);
        
        // Play adhan first, then show notification
        await _playAdhan(prayerName);
        await _showPrayerNotification(prayerName, entry.value);
        
        // Update UI
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  String _convertTo24Hour(String time12) {
    try {
      final cleanTime = time12.replaceAll(' AM', '').replaceAll(' PM', '');
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      if (time12.contains('PM') && hour != 12) hour += 12;
      if (time12.contains('AM') && hour == 12) hour = 0;
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // ✅ COMPLETELY REWRITTEN: Fixed adhan playback with multiple fallback options
  Future<void> _playAdhan(String prayerName) async {
    if (_isPlayingAdhan) {
      await _audioPlayer.stop();
    }

    try {
      print('🔊 Attempting to play adhan for $prayerName');
      
      // ✅ Try multiple reliable adhan sources
      final adhanUrls = [
        // Direct MP3 files from reliable Islamic audio sources
        'https://ia800307.us.archive.org/14/items/IslamicCallToPrayer/Adhan1.mp3',
        'https://archive.org/download/IslamicCallToPrayer/Adhan1.mp3',
        'https://ia902305.us.archive.org/5/items/adhan_20201231/adhan.mp3',
      ];

      bool played = false;
      
      // First, try to play from local asset if available
      try {
        print('🔊 Trying local asset: sounds/adhan.mp3');
        await _audioPlayer.play(AssetSource('sounds/adhan.mp3'));
        played = true;
        print('✅ Successfully playing adhan from local asset');
      } catch (e) {
        print('⚠️ Local asset not found, trying online sources: $e');
        
        // If local asset fails, try online URLs
        for (String url in adhanUrls) {
          try {
            print('🔊 Trying adhan URL: $url');
            await _audioPlayer.play(UrlSource(url));
            played = true;
            print('✅ Successfully playing adhan from: $url');
            break;
          } catch (e) {
            print('❌ Failed to play from $url: $e');
            await _audioPlayer.stop();
            continue;
          }
        }
      }

      if (!played && mounted) {
        print('⚠️ All adhan sources failed');
        // If all fails, just show notification without sound
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🕌 Prayer time: $prayerName'),
            backgroundColor: const Color(0xFF14B8A6),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isPlayingAdhan = played;
        });
      }
    } catch (e) {
      print('❌ Error playing adhan: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to play adhan for $prayerName'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // ✅ IMPROVED: Better notification with actions
  Future<void> _showPrayerNotification(String prayerName, String time) async {
    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: const Color(0xFF14B8A6),
      // ✅ ADDED: Custom notification icon and actions
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        'It\'s time to pray $prayerName. May Allah accept your prayers.',
        contentTitle: 'Time for $prayerName Prayer',
        summaryText: 'Islamic Prayer Times',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        prayerName.hashCode,
        '🕌 Time for $prayerName Prayer',
        'Prayer time: $time • Iqamah: ${_addMinutes(time, 15)}',
        notificationDetails,
        payload: '$prayerName:$time',
      );
      print('✅ Notification shown for $prayerName');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            errorMessage = "Location permission is required to show accurate prayer times";
            isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          errorMessage = "Please enable location permission in your device settings";
          isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentLocation = "${place.locality ?? place.subAdministrativeArea}, ${place.country}";
        });
      }

      // Fetch prayer times
      await _fetchPrayerTimes(position.latitude, position.longitude);

    } catch (e) {
      setState(() {
        errorMessage = "Unable to get your location. Please check your settings.";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPrayerTimes(double lat, double lon) async {
    try {
      final now = DateTime.now();
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/${now.day}-${now.month}-${now.year}?latitude=$lat&longitude=$lon&method=11'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        setState(() {
          prayerTimes = {
            'Fajr': _formatTime(timings['Fajr']),
            'Sunrise': _formatTime(timings['Sunrise']),
            'Dhuhr': _formatTime(timings['Dhuhr']),
            'Asr': _formatTime(timings['Asr']),
            'Maghrib': _formatTime(timings['Maghrib']),
            'Isha': _formatTime(timings['Isha']),
          };
          isLoading = false;
          _lastCheckedDate = DateFormat('yyyy-MM-dd').format(now);
        });

        _calculateNextPrayer();
        
        // ✅ ADDED: Log prayer times for debugging
        print('📅 Prayer times loaded for ${DateFormat('yyyy-MM-dd').format(now)}:');
        prayerTimes.forEach((key, value) {
          print('   $key: $value (24h: ${_convertTo24Hour(value)})');
        });
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      setState(() {
        errorMessage = "Unable to fetch prayer times. Please try again.";
        isLoading = false;
      });
    }
  }

  String _formatTime(String time) {
    try {
      final cleanTime = time.split(' ')[0];
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  void _calculateNextPrayer() {
    // ✅ ADDED: Safety check - don't calculate if prayer times aren't loaded yet
    if (prayerTimes['Fajr'] == '--:--' || prayerTimes['Fajr'] == null) {
      print('⚠️ Prayer times not loaded yet, skipping calculation');
      return;
    }

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    Map<String, int> prayerMinutes = {};
    prayerTimes.forEach((prayer, time) {
      if (prayer != 'Sunrise') {
        try {
          final cleanTime = time.replaceAll(' AM', '').replaceAll(' PM', '');
          final parts = cleanTime.split(':');
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          
          if (time.contains('PM') && hour != 12) hour += 12;
          if (time.contains('AM') && hour == 12) hour = 0;
          
          prayerMinutes[prayer] = hour * 60 + minute;
        } catch (e) {
          print('⚠️ Error parsing time for $prayer: $e');
        }
      }
    });

    String? foundPrayer;
    int? foundTime;

    for (var entry in prayerMinutes.entries) {
      if (entry.value > currentMinutes) {
        if (foundTime == null || entry.value < foundTime) {
          foundPrayer = entry.key;
          foundTime = entry.value;
        }
      }
    }

    // ✅ FIXED: Handle case when no upcoming prayer found (wrap to next day)
    if (foundPrayer == null) {
      // All prayers have passed, next is Fajr tomorrow
      foundPrayer = 'Fajr';
      if (prayerMinutes.containsKey('Fajr') && prayerMinutes['Fajr'] != null) {
        foundTime = prayerMinutes['Fajr']! + (24 * 60);
      } else {
        // Fallback if Fajr time is not available
        foundTime = currentMinutes + 60; // Default to 1 hour from now
      }
    }

    // ✅ FIXED: Only update state if we have valid data
    if (foundTime != null && prayerTimes.containsKey(foundPrayer)) {
      setState(() {
        nextPrayer = foundPrayer!;
        nextPrayerTime = prayerTimes[foundPrayer]!;
        
        int diffMinutes = foundTime! - currentMinutes;
        if (diffMinutes < 0) diffMinutes += 24 * 60;
        
        int hours = diffMinutes ~/ 60;
        int minutes = diffMinutes % 60;
        
        if (hours > 0) {
          timeRemaining = '${hours}h ${minutes}m';
        } else {
          timeRemaining = '${minutes}m';
        }
      });
    } else {
      // ✅ ADDED: Fallback state if prayer times are not loaded yet
      setState(() {
        nextPrayer = 'Loading...';
        nextPrayerTime = '--:--';
        timeRemaining = 'Calculating...';
      });
    }
  }

  Future<void> _refreshPrayerTimes() async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });
    await _initializeLocation();
  }

  // ✅ NEW: Manual test adhan function
  Future<void> _testAdhan() async {
    await _playAdhan('Test');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing adhan playback...'),
          backgroundColor: Color(0xFF14B8A6),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // ✅ NEW: Stop adhan function
  Future<void> _stopAdhan() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlayingAdhan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingScreen();
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshPrayerTimes,
          color: const Color(0xFF14B8A6),
          child: CustomScrollView(
            slivers: [
              // Modern Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
                      // Header row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prayer Times',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  DateFormat('EEEE, MMM d').format(DateTime.now()),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ✅ ADDED: Test adhan button
                          InkWell(
                            onTap: _isPlayingAdhan ? _stopAdhan : _testAdhan,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _isPlayingAdhan ? Icons.stop : Icons.volume_up,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _refreshPrayerTimes,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      
                      // Location card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                currentLocation,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.gps_fixed,
                                    color: Colors.white,
                                    size: 9,
                                  ),
                                  SizedBox(width: 3),
                                  Text(
                                    'Live',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ✅ ADDED: Adhan status indicator
                      if (_isPlayingAdhan) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Playing Adhan...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Next Prayer Card - Elevated
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            const Color(0xFF14B8A6).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF14B8A6).withOpacity(0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF14B8A6),
                                  Color(0xFF0D9488),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF14B8A6).withOpacity(0.3),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Next Prayer',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  nextPrayer,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                nextPrayerTime,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF14B8A6),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.orange.shade600,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(7),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.25),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      timeRemaining,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Section Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today\'s Schedule',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        '${prayerTimes.length} Times',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Prayer Times List with better spacing
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final prayers = prayerTimes.entries.toList();
                      final prayer = prayers[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == prayers.length - 1 ? 0 : 10,
                        ),
                        child: _buildPrayerCard(
                          prayer.key,
                          prayer.value,
                          index,
                        ),
                      );
                    },
                    childCount: prayerTimes.length,
                  ),
                ),
              ),

              // Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF14B8A6).withOpacity(0.1),
                          const Color(0xFF14B8A6).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF14B8A6).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14B8A6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'About Prayer Times & Notifications',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 9),
                        Text(
                          'Calculated using JAKIM (Jabatan Kemajuan Islam Malaysia) method for accurate Malaysian prayer times.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle,
                                size: 13,
                                color: Color(0xFF14B8A6),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Adhan will play automatically at each prayer time',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle,
                                size: 13,
                                color: Color(0xFF14B8A6),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Iqamah time is approximately 15 minutes after Adhan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(String name, String time, int index) {
    final isNext = name == nextPrayer;
    final isSpecial = name == 'Sunrise';
    final isPast = _isPrayerPast(time) && !isNext;
    final isNotified = _prayersNotified.contains(name);

    final icons = {
      'Fajr': Icons.wb_twilight,
      'Sunrise': Icons.wb_sunny_outlined,
      'Dhuhr': Icons.wb_sunny,
      'Asr': Icons.cloud,
      'Maghrib': Icons.nights_stay,
      'Isha': Icons.nightlight_round,
    };

    final colors = {
      'Fajr': const Color(0xFF6366F1),
      'Sunrise': const Color(0xFFFB923C),
      'Dhuhr': const Color(0xFFF59E0B),
      'Asr': const Color(0xFF14B8A6),
      'Maghrib': const Color(0xFF8B5CF6),
      'Isha': const Color(0xFF6366F1),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isNext
            ? Border.all(
                color: const Color(0xFF14B8A6),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isNext
                ? const Color(0xFF14B8A6).withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: isNext ? 10 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPast
                    ? [Colors.grey.shade300, Colors.grey.shade200]
                    : [
                        colors[name]!.withOpacity(0.8),
                        colors[name]!,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
              boxShadow: isPast
                  ? []
                  : [
                      BoxShadow(
                        color: colors[name]!.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Icon(
              icons[name],
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          
          // Prayer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isPast
                              ? Colors.grey.shade400
                              : const Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14B8A6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                    if (isNotified && !isSpecial) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '🔔',
                          style: TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!isSpecial) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 10,
                        color: isPast ? Colors.grey.shade400 : Colors.grey[500],
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Iqamah: ${_addMinutes(time, 15)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isPast ? Colors.grey.shade400 : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Time and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPast
                      ? Colors.grey.shade400
                      : isNext
                          ? const Color(0xFF14B8A6)
                          : const Color(0xFF1F2937),
                ),
              ),
              if (isPast && !isSpecial) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.grey.shade300,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Prayed',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _isPrayerPast(String time) {
    try {
      final now = DateTime.now();
      final cleanTime = time.replaceAll(' AM', '').replaceAll(' PM', '');
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      if (time.contains('PM') && hour != 12) hour += 12;
      if (time.contains('AM') && hour == 12) hour = 0;
      
      final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      return now.isAfter(prayerTime);
    } catch (e) {
      return false;
    }
  }

  String _addMinutes(String time, int minutesToAdd) {
    try {
      final cleanTime = time.replaceAll(' AM', '').replaceAll(' PM', '');
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      bool isPM = time.contains('PM');
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      
      minute += minutesToAdd;
      if (minute >= 60) {
        hour += minute ~/ 60;
        minute = minute % 60;
      }
      
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF14B8A6),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Finding your location...',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Getting accurate prayer times for you',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  size: 45,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Location Not Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _refreshPrayerTimes,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: () {
                  // Open app settings
                },
                icon: Icon(
                  Icons.settings,
                  size: 16,
                  color: Colors.grey[600],
                ),
                label: Text(
                  'Open Settings',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}