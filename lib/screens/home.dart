import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:praynow/screens/mosque.dart';
import 'package:praynow/screens/qibla.dart';
import 'package:praynow/screens/surah.dart';
import 'package:praynow/screens/tasbih.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:praynow/services/notification_service.dart';

// Notification Model
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final DateTime timestamp;
  bool isRead;
  final String type; // 'prayer', 'quran', 'dhikr', 'general'

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'type': type,
  };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      icon: _getIconFromType(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      type: json['type'],
    );
  }

  static IconData _getIconFromType(String type) {
    switch (type) {
      case 'prayer':
        return Icons.access_time;
      case 'quran':
        return Icons.menu_book;
      case 'dhikr':
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentTime = "";
  String hijriDate = "Loading...";
  String currentLocation = "Getting location...";
  String userName = "";
  double? currentLatitude;
  double? currentLongitude;

  // ⚠️ SECURITY: Move this to environment variables
  final String googleApiKey = 'AIzaSyBoZ83Xrsw0vo8U1JHSYhaTB4AAnpnZBY4';

  // Prayer times
  Map<String, String> prayerTimes = {
    'Fajr': '--:--',
    'Dhuhr': '--:--',
    'Asr': '--:--',
    'Maghrib': '--:--',
    'Isha': '--:--',
  };

  String nextPrayer = "Calculating...";
  String nextPrayerTime = "--:--";
  String timeRemaining = "--";
  bool isLoadingPrayers = true;

  // Prayer tracker state
  Map<String, bool> prayerTracker = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  // Notification state
  List<NotificationItem> notifications = [];
  int unreadCount = 0;

  final Set<String> _scheduledNotifications = {};

  // Image carousel
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Timer? _carouselTimer;

  // Islamic-themed inspirational content
  final List<Map<String, String>> inspirationalContent = [
    {
      'image': 'https://images.unsplash.com/photo-1564769132-cb3aea458c5e?w=800&q=80',
      'quote': 'And He found you lost and guided [you]',
      'reference': 'Quran 93:7',
      'icon': '🕌',
    },
    {
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
      'quote': 'Indeed, with hardship comes ease',
      'reference': 'Quran 94:6',
      'icon': '✨',
    },
    {
      'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      'quote': 'So remember Me; I will remember you',
      'reference': 'Quran 2:152',
      'icon': '📿',
    },
    {
      'image': 'https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=800&q=80',
      'quote': 'The best of you are those who are best to their families',
      'reference': 'Hadith',
      'icon': '👨‍👩‍👧‍👦',
    },
    {
      'image': 'https://images.unsplash.com/photo-1507842812343-583f20270319?w=800&q=80',
      'quote': 'Verily, the best deeds are done regularly, even if they are small',
      'reference': 'Sahih Muslim',
      'icon': '🌅',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUserData();
    _loadPrayerTracker();
    _loadNotifications();
    _updateTime();
    _fetchHijriDate();
    _initializePrayerTimes();
    _startCarousel();
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
        if (!isLoadingPrayers) {
          _calculateNextPrayer();
          _checkPrayerTimeNotifications();
        }
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
  }

  void _startCarousel() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        if (_currentImageIndex < inspirationalContent.length - 1) {
          _currentImageIndex++;
        } else {
          _currentImageIndex = 0;
        }
        
        _pageController.animateToPage(
          _currentImageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
      
      final notificationsJson = prefs.getStringList('notifications_list') ?? [];
      
      if (mounted) {
        setState(() {
          notifications = notificationsJson
              .map((json) => NotificationItem.fromJson(jsonDecode(json)))
              .toList();
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          unreadCount = notifications.where((n) => !n.isRead).length;
        });
      }

      if (notifications.isEmpty) {
        await _addInitialNotifications();
      }
    } catch (e) {
      print('Error loading notifications: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
      await prefs.remove('notifications_list');
      await _addInitialNotifications();
    }
  }

  Future<void> _addInitialNotifications() async {
    final initialNotifications = [
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Welcome to PrayNow',
        message: 'Start tracking your daily prayers',
        icon: Icons.notifications,
        timestamp: DateTime.now(),
        type: 'general',
      ),
      NotificationItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Daily Quran',
        message: 'Read your daily Quran portion',
        icon: Icons.menu_book,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'quran',
      ),
    ];

    if (mounted) {
      setState(() {
        notifications = initialNotifications;
        unreadCount = notifications.where((n) => !n.isRead).length;
      });
    }

    await _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = notifications
          .map((n) => jsonEncode(n.toJson()))
          .toList();
      await prefs.setStringList('notifications_list', notificationsJson);
    } catch (e) {
      print('Error saving notifications: $e');
    }
  }

  Future<void> _addNotification(NotificationItem notification) async {
    if (mounted) {
      setState(() {
        notifications.insert(0, notification);
        if (!notification.isRead) {
          unreadCount++;
        }
      });
    }
    await _saveNotifications();
  }

  Future<void> _markAsRead(String notificationId) async {
    if (mounted) {
      setState(() {
        final notification = notifications.firstWhere((n) => n.id == notificationId);
        if (!notification.isRead) {
          notification.isRead = true;
          unreadCount = (unreadCount - 1).clamp(0, notifications.length);
        }
      });
    }
    await _saveNotifications();
  }

  Future<void> _markAllAsRead() async {
    if (mounted) {
      setState(() {
        for (var notification in notifications) {
          notification.isRead = true;
        }
        unreadCount = 0;
      });
    }
    await _saveNotifications();
  }

  Future<void> _deleteNotification(String notificationId) async {
    if (mounted) {
      setState(() {
        final notification = notifications.firstWhere((n) => n.id == notificationId);
        if (!notification.isRead) {
          unreadCount = (unreadCount - 1).clamp(0, notifications.length);
        }
        notifications.removeWhere((n) => n.id == notificationId);
      });
    }
    await _saveNotifications();
  }

  Future<void> _clearAllNotifications() async {
    if (mounted) {
      setState(() {
        notifications.clear();
        unreadCount = 0;
      });
    }
    await _saveNotifications();
  }

  void _checkPrayerTimeNotifications() {
    final now = DateTime.now();
    
    for (var prayer in prayerTimes.keys) {
      final prayerTime = _parsePrayerTime(prayerTimes[prayer]!);
      if (prayerTime != null) {
        final diff = prayerTime.difference(now);
        
        if (diff.inMinutes == 5 && diff.inSeconds >= 0 && diff.inSeconds < 5) {
          final notificationKey = '${prayer}_${DateFormat('yyyy-MM-dd').format(now)}';
          
          if (!_scheduledNotifications.contains(notificationKey)) {
            _scheduledNotifications.add(notificationKey);
            
            NotificationService.showNotification(
              id: prayer.hashCode,
              title: '🕌 Prayer Reminder',
              body: 'Time for $prayer prayer in 5 minutes',
            );
            
            _addNotification(
              NotificationItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Prayer Reminder',
                message: 'Time for $prayer prayer in 5 minutes',
                icon: Icons.access_time,
                timestamp: DateTime.now(),
                type: 'prayer',
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _scheduleDailyPrayerNotifications() async {
    try {
      for (var entry in prayerTimes.entries) {
        final prayerTime = _parsePrayerTime(entry.value);
        if (prayerTime != null && prayerTime.isAfter(DateTime.now())) {
          await NotificationService.schedulePrayerReminder(
            id: entry.key.hashCode,
            prayerName: entry.key,
            prayerTime: prayerTime,
          );
          
          print('✅ Scheduled notification for ${entry.key} at ${entry.value}');
        }
      }
    } catch (e) {
      print('Error scheduling prayer notifications: $e');
    }
  }

  DateTime? _parsePrayerTime(String time) {
    try {
      final now = DateTime.now();
      final cleanTime = time.replaceAll(' AM', '').replaceAll(' PM', '');
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (time.contains('PM') && hour != 12) hour += 12;
      if (time.contains('AM') && hour == 12) hour = 0;

      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      if (name != null && name.isNotEmpty && mounted) {
        setState(() {
          userName = name;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadPrayerTracker() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final savedDate = prefs.getString('prayer_tracker_date');
      
      if (savedDate != today) {
        await _resetPrayerTracker();
        return;
      }
      
      if (mounted) {
        setState(() {
          prayerTracker = {
            'Fajr': prefs.getBool('prayer_Fajr') ?? false,
            'Dhuhr': prefs.getBool('prayer_Dhuhr') ?? false,
            'Asr': prefs.getBool('prayer_Asr') ?? false,
            'Maghrib': prefs.getBool('prayer_Maghrib') ?? false,
            'Isha': prefs.getBool('prayer_Isha') ?? false,
          };
        });
      }
    } catch (e) {
      print('Error loading prayer tracker: $e');
    }
  }

  Future<void> _resetPrayerTracker() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      await prefs.setString('prayer_tracker_date', today);
      await prefs.setBool('prayer_Fajr', false);
      await prefs.setBool('prayer_Dhuhr', false);
      await prefs.setBool('prayer_Asr', false);
      await prefs.setBool('prayer_Maghrib', false);
      await prefs.setBool('prayer_Isha', false);
      
      if (mounted) {
        setState(() {
          prayerTracker = {
            'Fajr': false,
            'Dhuhr': false,
            'Asr': false,
            'Maghrib': false,
            'Isha': false,
          };
        });
      }
    } catch (e) {
      print('Error resetting prayer tracker: $e');
    }
  }

  Future<void> _togglePrayer(String prayer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newValue = !prayerTracker[prayer]!;
      
      await prefs.setBool('prayer_$prayer', newValue);
      
      if (mounted) {
        setState(() {
          prayerTracker[prayer] = newValue;
        });
      
        if (newValue) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('$prayer prayer marked as completed'),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );

          NotificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch,
            title: '✅ Prayer Completed',
            body: 'You completed $prayer prayer. May Allah accept it!',
          );

          await _addNotification(
            NotificationItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Prayer Completed',
              message: 'You completed $prayer prayer. May Allah accept it!',
              icon: Icons.check_circle,
              timestamp: DateTime.now(),
              type: 'prayer',
            ),
          );
        }
      }
    } catch (e) {
      print('Error toggling prayer: $e');
    }
  }

  // ✅ FIXED: Better location initialization with debugging
  Future<void> _initializePrayerTimes() async {
    try {
      print('🔍 Starting location initialization...');
      
      // Set loading state
      if (mounted) {
        setState(() {
          currentLocation = "Getting location...";
        });
      }
      
      // First, try to load saved location from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble('latitude');
      final savedLng = prefs.getDouble('longitude');
      final savedLocation = prefs.getString('location');
      
      print('📍 Saved location: $savedLocation');
      print('📍 Saved coordinates: $savedLat, $savedLng');
      
      if (savedLat != null && savedLng != null && savedLocation != null) {
        // Use saved location
        print('✅ Using saved location');
        if (mounted) {
          setState(() {
            currentLatitude = savedLat;
            currentLongitude = savedLng;
            currentLocation = savedLocation;
          });
        }
        await _fetchPrayerTimes(savedLat, savedLng);
        return;
      }
      
      // If no saved location, get current GPS location
      print('🛰️ Checking location permissions...');
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        print('⚠️ Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        print('✅ Location permission granted, getting position...');
        
        // Show getting GPS message
        if (mounted) {
          setState(() {
            currentLocation = "Getting GPS position...";
          });
        }
        
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            print('⏱️ Position timeout, using fallback');
            throw Exception('Location timeout');
          },
        );

        print('📍 Got position: ${position.latitude}, ${position.longitude}');

        if (mounted) {
          setState(() {
            currentLatitude = position.latitude;
            currentLongitude = position.longitude;
            // Show coordinates while fetching name
            currentLocation = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
          });
        }

        // Get location name BEFORE fetching prayer times
        await _getLocationNameFromGoogle(position.latitude, position.longitude);
        await _fetchPrayerTimes(position.latitude, position.longitude);
      } else {
        print('❌ Location permission denied permanently, using default');
        // Default to Kuala Lumpur if permission denied
        if (mounted) {
          setState(() {
            currentLatitude = 3.139;
            currentLongitude = 101.6869;
            currentLocation = "Kuala Lumpur, Malaysia (Default)";
          });
        }
        await _fetchPrayerTimes(3.139, 101.6869);
      }
    } catch (e) {
      print('❌ Error initializing prayer times: $e');
      if (mounted) {
        setState(() {
          currentLatitude = 3.139;
          currentLongitude = 101.6869;
          currentLocation = "Kuala Lumpur, Malaysia (Error)";
        });
      }
      await _fetchPrayerTimes(3.139, 101.6869);
    }
  }

  // ✅ FIXED: Better error handling for Google Geocoding
  Future<void> _getLocationNameFromGoogle(double lat, double lon) async {
    try {
      print('🌍 Fetching location name for: $lat, $lon');
      
      // Show fetching state with coordinates as backup
      if (mounted) {
        setState(() {
          currentLocation = 'Loading... (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)})';
        });
      }
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$googleApiKey&language=en',
      );

      print('📡 Calling Google API...');
      print('🔗 URL: ${url.toString().replaceAll(googleApiKey, 'API_KEY_HIDDEN')}');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ Google API timeout');
          throw Exception('Request timeout');
        },
      );

      print('📥 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 API Response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final results = data['results'] as List;
          
          // Try to find locality and administrative_area
          String? locality;
          String? adminArea;
          String? country;
          
          for (var result in results) {
            final components = result['address_components'] as List;
            
            for (var component in components) {
              final types = component['types'] as List;
              
              if (types.contains('locality') && locality == null) {
                locality = component['long_name'];
              }
              if (types.contains('administrative_area_level_1') && adminArea == null) {
                adminArea = component['long_name'];
              }
              if (types.contains('country') && country == null) {
                country = component['long_name'];
              }
            }
          }
          
          // Build location string
          String location = '';
          if (locality != null) {
            location = locality;
          }
          if (adminArea != null && locality != adminArea) {
            location += location.isEmpty ? adminArea : ', $adminArea';
          }
          
          if (location.isEmpty) {
            // Try to extract from formatted_address
            final formattedAddress = results[0]['formatted_address'] as String;
            final parts = formattedAddress.split(',');
            if (parts.length >= 2) {
              location = '${parts[0].trim()}, ${parts[1].trim()}';
            } else {
              location = formattedAddress;
            }
          }
          
          print('✅ Location found: $location');
          
          if (mounted) {
            setState(() {
              currentLocation = location;
            });
          }
          
          // Save to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('location', location);
          await prefs.setDouble('latitude', lat);
          await prefs.setDouble('longitude', lon);
          
          print('💾 Location saved to preferences');
        } else {
          print('⚠️ Geocoding API error: ${data['status']}');
          if (data.containsKey('error_message')) {
            print('⚠️ Error message: ${data['error_message']}');
          }
          
          // Fallback to coordinates
          final fallbackLocation = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
          if (mounted) {
            setState(() {
              currentLocation = fallbackLocation;
            });
          }
        }
      } else {
        print('⚠️ HTTP error: ${response.statusCode}');
        print('⚠️ Response body: ${response.body}');
        
        // Fallback to coordinates
        final fallbackLocation = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
        if (mounted) {
          setState(() {
            currentLocation = fallbackLocation;
          });
        }
      }
    } catch (e) {
      print('❌ Error getting location name: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
      // Fallback to coordinates
      final fallbackLocation = '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
      if (mounted) {
        setState(() {
          currentLocation = fallbackLocation;
        });
      }
    }
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        currentTime = DateFormat('hh:mm a').format(DateTime.now());
      });
    }
  }

  Future<void> _fetchHijriDate() async {
    try {
      final now = DateTime.now();
      final url = Uri.parse(
        'http://api.aladhan.com/v1/gToH/${now.day}-${now.month}-${now.year}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijri = data['data']['hijri'];

        final monthName = hijri['month']['en'];
        final day = hijri['day'];
        final year = hijri['year'];

        if (mounted) {
          setState(() {
            hijriDate = "$day $monthName, $year";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hijriDate = "23 Jumada al-Akhirah, 1446";
        });
      }
    }
  }

  Future<void> _fetchPrayerTimes(double lat, double lon) async {
    try {
      final now = DateTime.now();
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/${now.day}-${now.month}-${now.year}?latitude=$lat&longitude=$lon&method=11',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        if (mounted) {
          setState(() {
            prayerTimes = {
              'Fajr': _formatTime(timings['Fajr']),
              'Dhuhr': _formatTime(timings['Dhuhr']),
              'Asr': _formatTime(timings['Asr']),
              'Maghrib': _formatTime(timings['Maghrib']),
              'Isha': _formatTime(timings['Isha']),
            };
            isLoadingPrayers = false;
          });
        }

        _calculateNextPrayer();
        await _scheduleDailyPrayerNotifications();
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
      if (mounted) {
        setState(() {
          isLoadingPrayers = false;
        });
      }
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
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    Map<String, int> prayerMinutes = {};
    prayerTimes.forEach((prayer, time) {
      try {
        final cleanTime = time.replaceAll(' AM', '').replaceAll(' PM', '');
        final parts = cleanTime.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (time.contains('PM') && hour != 12) hour += 12;
        if (time.contains('AM') && hour == 12) hour = 0;

        prayerMinutes[prayer] = hour * 60 + minute;
      } catch (e) {}
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

    if (foundPrayer == null) {
      foundPrayer = 'Fajr';
      foundTime = prayerMinutes['Fajr']! + (24 * 60);
    }

    if (mounted) {
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
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Color(0xFF14B8A6), size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: _markAllAsRead,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Mark read',
                          style: TextStyle(
                            color: Color(0xFF14B8A6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (notifications.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        onPressed: () {
                          showDialog(
                            context: modalContext,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Clear All'),
                              content: const Text('Delete all notifications?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _clearAllNotifications();
                                    Navigator.pop(dialogContext);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: notifications.length,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteNotification(notification.id);
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Notification deleted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: _buildNotificationItem(notification),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final timeAgo = _getTimeAgo(notification.timestamp);
    
    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          _markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead 
              ? Colors.white 
              : const Color(0xFF14B8A6).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? Colors.grey.shade200
                : const Color(0xFF14B8A6).withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon,
                color: const Color(0xFF14B8A6),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead 
                                ? FontWeight.w600 
                                : FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF14B8A6),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.7,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF14B8A6).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName.isNotEmpty ? userName : 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentLocation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (currentLatitude != null && currentLongitude != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '📍 ${currentLatitude!.toStringAsFixed(4)}, ${currentLongitude!.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                _buildProfileOption(
                  Icons.person_outline,
                  'Edit Profile',
                  () {
                    Navigator.pop(modalContext);
                    _showEditProfile();
                  },
                ),
                _buildProfileOption(
                  Icons.location_on_outlined,
                  'Location Settings',
                  () {
                    Navigator.pop(modalContext);
                    _showLocationSettings();
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? const Color(0xFF14B8A6), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showEditProfile() {
    final nameController = TextEditingController(text: userName);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_name', nameController.text);
                  if (mounted) {
                    setState(() {
                      userName = nameController.text;
                    });
                  }
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error saving name: $e');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLocationSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Location Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF14B8A6)),
              title: const Text('Current Location'),
              subtitle: Text(currentLocation),
            ),
            if (currentLatitude != null && currentLongitude != null)
              ListTile(
                leading: const Icon(Icons.my_location, color: Color(0xFF14B8A6)),
                title: const Text('Coordinates'),
                subtitle: Text(
                  '${currentLatitude!.toStringAsFixed(6)}, ${currentLongitude!.toStringAsFixed(6)}',
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (mounted) {
                  setState(() {
                    isLoadingPrayers = true;
                    currentLocation = 'Updating location...';
                  });
                }
                await _initializePrayerTimes();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location updated')),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Update Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14B8A6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _initializePrayerTimes();
            await _fetchHijriDate();
            await _loadPrayerTracker();
            await _loadNotifications();
          },
          child: CustomScrollView(
            slivers: [
              // Header with greeting
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'السلام عليكم',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userName.isNotEmpty ? userName : 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentLocation,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Stack(
                                children: [
                                  InkWell(
                                    onTap: _showNotifications,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unreadCount > 9 ? '9+' : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _showProfile,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Taqwim Card
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Taqwim',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6B21A8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hijriDate,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('EEE, d MMM yyyy').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade100,
                                    Colors.amber.shade200,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getPrayerIcon(nextPrayer),
                                    color: Colors.orange.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Next',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    nextPrayer,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    nextPrayerTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Access Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Access',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAccessCard(
                              icon: Icons.explore,
                              title: 'Qibla',
                              subtitle: 'Find direction',
                              color: const Color(0xFF14B8A6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickAccessCard(
                              icon: Icons.menu_book,
                              title: 'Quran',
                              subtitle: 'Read & listen',
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAccessCard(
                              icon: Icons.circle_outlined,
                              title: 'Tasbih',
                              subtitle: 'Count dhikr',
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickAccessCard(
                              icon: Icons.mosque,
                              title: 'Mosques',
                              subtitle: 'Find nearby',
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Prayer Times Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Prayer Times',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildPrayerTimeColumn('Fajr', prayerTimes['Fajr']!, const Color(0xFF6366F1)),
                            _buildPrayerDivider(),
                            _buildPrayerTimeColumn('Dhuhr', prayerTimes['Dhuhr']!, const Color(0xFFF59E0B)),
                            _buildPrayerDivider(),
                            _buildPrayerTimeColumn('Asr', prayerTimes['Asr']!, const Color(0xFF14B8A6)),
                            _buildPrayerDivider(),
                            _buildPrayerTimeColumn('Maghrib', prayerTimes['Maghrib']!, const Color(0xFF8B5CF6)),
                            _buildPrayerDivider(),
                            _buildPrayerTimeColumn('Isha', prayerTimes['Isha']!, const Color(0xFF6366F1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Daily Words Carousel
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              if (mounted) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              }
                            },
                            itemCount: inspirationalContent.length,
                            itemBuilder: (context, index) {
                              final content = inspirationalContent[index];
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    content['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF14B8A6).withOpacity(0.8),
                                              const Color(0xFF0F766E).withOpacity(0.8),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                content['icon']!,
                                                style: const TextStyle(fontSize: 60),
                                              ),
                                              const SizedBox(height: 12),
                                              const Icon(
                                                Icons.image,
                                                size: 48,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 40,
                                    left: 24,
                                    right: 24,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          content['quote']!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          content['reference']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.9),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                inspirationalContent.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentImageIndex == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Prayer Tracker Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daily Prayer Tracker',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14B8A6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF14B8A6),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${prayerTracker.values.where((v) => v).length}/5',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF14B8A6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPrayerTrackerDot('Fajr', prayerTracker['Fajr']!),
                          _buildPrayerTrackerDot('Dhuhr', prayerTracker['Dhuhr']!),
                          _buildPrayerTrackerDot('Asr', prayerTracker['Asr']!),
                          _buildPrayerTrackerDot('Maghrib', prayerTracker['Maghrib']!),
                          _buildPrayerTrackerDot('Isha', prayerTracker['Isha']!),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTimeColumn(String name, String time, Color color) {
    final isPast = _isPrayerPast(time);
    final isNext = name == nextPrayer;

    return Flexible(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isNext 
                  ? color.withOpacity(0.15)
                  : isPast 
                      ? Colors.grey.shade100 
                      : color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getPrayerIcon(name),
                color: isPast ? Colors.grey.shade400 : color,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPast ? Colors.grey.shade400 : const Color(0xFF1F2937),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isNext 
                  ? color 
                  : isPast 
                      ? Colors.grey.shade400 
                      : Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPrayerTrackerDot(String name, bool isCompleted) {
    final color = isCompleted ? const Color(0xFF10B981) : Colors.grey.shade300;
    
    return GestureDetector(
      onTap: () => _togglePrayer(name),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: isCompleted
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 28)
                : Icon(
                    _getPrayerIcon(name),
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCompleted ? const Color(0xFF10B981) : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.cloud;
      case 'Maghrib':
        return Icons.nights_stay;
      case 'Isha':
        return Icons.nightlight_round;
      default:
        return Icons.circle;
    }
  }

  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Widget? page;
        switch (title) {
          case 'Qibla':
            page = const QiblaPage();
            break;
          case 'Quran':
            page = const QuranPage();
            break;
          case 'Tasbih':
            page = const TasbihPage();
            break;
          case 'Mosques':
            page = const MosquesPage();
            break;
        }

        if (page != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
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
}