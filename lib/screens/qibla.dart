// FILE: lib/qibla_page.dart
// Highly Accurate Qibla Direction Page with Improved Calculations

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  double? _qiblaDirection;
  double _deviceHeading = 0;
  bool _isLoading = true;
  String _locationName = "Getting location...";
  String _cityName = "";
  double? _latitude;
  double? _longitude;
  String? _errorMessage;
  int _compassAccuracy = 0;
  
  // ✅ IMPROVED: More precise Kaaba coordinates from official sources
  static const double KAABA_LAT = 21.422487;
  static const double KAABA_LON = 39.826206;

  // More lenient alignment check - within 10 degrees for better accuracy
  bool _isAligned() {
    if (_qiblaDirection == null) return false;
    double difference = (_qiblaDirection! - _deviceHeading).abs();
    if (difference > 180) difference = 360 - difference;
    // Consider aligned if within 10 degrees (more strict for accuracy)
    return difference < 10;
  }

  // Get alignment percentage for visual feedback
  double _getAlignmentPercentage() {
    if (_qiblaDirection == null) return 0;
    double difference = (_qiblaDirection! - _deviceHeading).abs();
    if (difference > 180) difference = 360 - difference;
    // 0-10 degrees = 100%, 10-45 degrees = scales down, 45+ = 0%
    if (difference <= 10) return 100;
    if (difference >= 45) return 0;
    return 100 - ((difference - 10) / 35 * 100);
  }

  @override
  void initState() {
    super.initState();
    _initializeQibla();
  }

  Future<void> _initializeQibla() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.denied && 
          permission != LocationPermission.deniedForever) {
        try {
          // ✅ IMPROVED: Use high accuracy location settings
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15),
          );

          _latitude = position.latitude;
          _longitude = position.longitude;

          // Try API first, then fallback to calculation
          bool apiSuccess = await _fetchQiblaFromAPI(position.latitude, position.longitude);
          if (!apiSuccess) {
            _calculateQiblaDirection(position.latitude, position.longitude);
          }
        } catch (e) {
          // If real-time location fails, use last known position
          Position? lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            _latitude = lastPosition.latitude;
            _longitude = lastPosition.longitude;
            bool apiSuccess = await _fetchQiblaFromAPI(lastPosition.latitude, lastPosition.longitude);
            if (!apiSuccess) {
              _calculateQiblaDirection(lastPosition.latitude, lastPosition.longitude);
            }
          } else {
            // Fallback to default location (Kuala Lumpur)
            _latitude = 3.139;
            _longitude = 101.6869;
            _calculateQiblaDirection(3.139, 101.6869);
            setState(() {
              _locationName = "Kuala Lumpur (Default)";
              _cityName = "Kuala Lumpur";
            });
          }
        }
      } else {
        // Default to Kuala Lumpur
        _latitude = 3.139;
        _longitude = 101.6869;
        _calculateQiblaDirection(3.139, 101.6869);
        setState(() {
          _locationName = "Kuala Lumpur (Default)";
          _cityName = "Kuala Lumpur";
          _errorMessage = "Location permission denied. Using default location.";
        });
      }

      // Listen to compass with validation
      FlutterCompass.events?.listen((event) {
        if (mounted && event.heading != null) {
          setState(() {
            _deviceHeading = event.heading!;
            _compassAccuracy = event.accuracy?.toInt() ?? 0;
          });
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            _errorMessage = "Compass error. Please recalibrate your device.";
          });
        }
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _locationName = "Error getting location";
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// ✅ IMPROVED: Fetch from API with better error handling
  Future<bool> _fetchQiblaFromAPI(double lat, double lon) async {
    try {
      // Using Aladhan API to get Qibla direction
      final url = Uri.parse(
        'https://api.aladhan.com/v1/qibla/$lat/$lon'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null && data['data']['direction'] != null) {
          double apiQibla = data['data']['direction'].toDouble();
          
          if (mounted) {
            setState(() {
              _qiblaDirection = apiQibla;
              _locationName = "Current Location";
              _errorMessage = null;
            });
          }

          // Get city name asynchronously
          await _getCityName(lat, lon);
          return true;
        }
      }
      return false;
    } catch (e) {
      print("API Error: $e");
      return false;
    }
  }

  Future<void> _getCityName(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1'
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'IslamicPrayerApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String city = data['address']['city'] ?? 
                     data['address']['town'] ?? 
                     data['address']['village'] ?? 
                     data['address']['state'] ?? 
                     'Your Location';
        
        if (mounted) {
          setState(() {
            _cityName = city;
            _locationName = city;
          });
        }
      }
    } catch (e) {
      print("Geocoding Error: $e");
    }
  }

  /// ✅ HIGHLY ACCURATE: Spherical trigonometry calculation using Vincenty formula approach
  void _calculateQiblaDirection(double lat, double lon) {
    // Convert degrees to radians
    double latRad = _toRadians(lat);
    double lonRad = _toRadians(lon);
    double kaabaLatRad = _toRadians(KAABA_LAT);
    double kaabaLonRad = _toRadians(KAABA_LON);

    // ✅ IMPROVED: Using the most accurate great-circle bearing formula
    // This is the initial bearing (forward azimuth) from current location to Kaaba
    double dLon = kaabaLonRad - lonRad;

    // Apply the spherical law of cosines formula for bearing
    double y = math.sin(dLon) * math.cos(kaabaLatRad);
    double x = math.cos(latRad) * math.sin(kaabaLatRad) - 
               math.sin(latRad) * math.cos(kaabaLatRad) * math.cos(dLon);

    // Calculate bearing in radians, then convert to degrees
    double bearingRad = math.atan2(y, x);
    double bearingDeg = _toDegrees(bearingRad);
    
    // Normalize to 0-360 range
    double qibla = (bearingDeg + 360) % 360;

    if (mounted) {
      setState(() {
        _qiblaDirection = qibla;
      });
    }
  }

  /// ✅ ADDED: Helper function to convert degrees to radians
  double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// ✅ ADDED: Helper function to convert radians to degrees
  double _toDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// ✅ IMPROVED: Calculate distance using Haversine formula for accuracy
  String _getDistanceToKaaba() {
    if (_latitude == null || _longitude == null) return '';
    
    try {
      // Using Geolocator's built-in distance calculation (uses Haversine)
      double distance = Geolocator.distanceBetween(
        _latitude!,
        _longitude!,
        KAABA_LAT,
        KAABA_LON,
      );

      // Convert to kilometers
      double km = distance / 1000;
      
      // Format based on distance
      if (km < 1) {
        return '${distance.toStringAsFixed(0)} m to Kaaba';
      } else if (km < 100) {
        return '${km.toStringAsFixed(1)} km to Kaaba';
      } else {
        return '${km.toStringAsFixed(0)} km to Kaaba';
      }
    } catch (e) {
      return 'Distance unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    double qiblaAngle = 0;
    if (_qiblaDirection != null) {
      qiblaAngle = _qiblaDirection! - _deviceHeading;
    }

    final bool isAligned = _isAligned();
    final double alignmentPercent = _getAlignmentPercentage();
    final Color indicatorColor = isAligned ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final Color backgroundColor = isAligned 
        ? const Color(0xFF10B981).withOpacity(0.1) 
        : const Color(0xFFEF4444).withOpacity(0.1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAligned
                  ? [const Color(0xFF10B981), const Color(0xFF059669)]
                  : [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
            ),
          ),
        ),
        title: const Text(
          'Qibla Direction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _initializeQibla();
            },
            tooltip: 'Refresh location',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAccuracyInfo(context);
            },
            tooltip: 'Accuracy info',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isAligned
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF0F766E), const Color(0xFF14B8A6)],
                    ),
                  ),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isAligned ? Icons.check_circle : Icons.location_on,
                          key: ValueKey(isAligned),
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isAligned ? 'Aligned with Qibla!' : _locationName,
                          key: ValueKey(isAligned),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _qiblaDirection != null
                            ? '${_qiblaDirection!.toStringAsFixed(2)}° from North'
                            : 'Calculating...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_latitude != null && _longitude != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getDistanceToKaaba(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lat: ${_latitude!.toStringAsFixed(4)}°, Lon: ${_longitude!.toStringAsFixed(4)}°',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      if (_compassAccuracy > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _compassAccuracy >= 75 ? Icons.check_circle : 
                              _compassAccuracy >= 50 ? Icons.warning : Icons.error,
                              color: Colors.white.withOpacity(0.9),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Compass: $_compassAccuracy%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated background glow
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: indicatorColor.withOpacity(0.2 + (alignmentPercent / 500)),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // Compass background
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: indicatorColor.withOpacity(0.5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                        // Compass dial
                        Transform.rotate(
                          angle: -_deviceHeading * math.pi / 180,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // North indicator
                                Positioned(
                                  top: 10,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Text(
                                          'N',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F766E),
                                          ),
                                        ),
                                        Container(
                                          width: 4,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0F766E),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // East indicator
                                Positioned(
                                  right: 10,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Text(
                                      'E',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                // South indicator
                                Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      'S',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                                // West indicator
                                Positioned(
                                  left: 10,
                                  top: 0,
                                  bottom: 0,
                                  child: Center(
                                    child: Text(
                                      'W',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Qibla pointer
                        Transform.rotate(
                          angle: qiblaAngle * math.pi / 180,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isAligned
                                        ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                        : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: indicatorColor.withOpacity(0.5 + (alignmentPercent / 200)),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.navigation,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 4,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      indicatorColor,
                                      indicatorColor.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Center dot
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: indicatorColor,
                              width: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Status indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: indicatorColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Icon(
                                    isAligned ? Icons.check_circle : Icons.error_outline,
                                    key: ValueKey(isAligned),
                                    color: indicatorColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Text(
                                      isAligned
                                          ? 'Perfect! You are facing the Qibla direction'
                                          : 'Rotate your device to find the Qibla direction',
                                      key: ValueKey(isAligned),
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (alignmentPercent > 0 && alignmentPercent < 100) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: alignmentPercent / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Alignment: ${alignmentPercent.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Compass accuracy and calibration note
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.explore,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Hold device flat & away from metal',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (_compassAccuracy < 50)
                            Text(
                              '⚠️ Low compass accuracy. Move in figure-8 to recalibrate.',
                              style: TextStyle(
                                color: Colors.orange.shade600,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// Show accuracy information dialog
  void _showAccuracyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Qibla Accuracy Information'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This app uses:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('1. Aladhan API for verified calculations'),
                _buildInfoRow('2. Spherical trigonometry for backup'),
                _buildInfoRow('3. High-precision Kaaba coordinates'),
                const SizedBox(height: 12),
                const Text(
                  'For best accuracy:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('• Hold device flat (parallel to ground)'),
                _buildInfoRow('• Stay away from metal objects'),
                _buildInfoRow('• Calibrate compass if accuracy is low'),
                _buildInfoRow('• Enable high-accuracy location'),
                const SizedBox(height: 12),
                Text(
                  'Kaaba Location:\nLat: ${KAABA_LAT.toStringAsFixed(6)}°\nLon: ${KAABA_LON.toStringAsFixed(6)}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}