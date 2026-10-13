import 'package:geolocator/geolocator.dart';

/// Enhanced Location Service with better error handling and user-friendly messages
class LocationService {
  // Singleton pattern for consistent usage
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _cachedPosition;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  /// Get current position with comprehensive error handling
  Future<Position?> getCurrentPositionSafe() async {
    try {
      // Return cached position if still valid
      if (_cachedPosition != null && _lastFetchTime != null) {
        final difference = DateTime.now().difference(_lastFetchTime!);
        if (difference < _cacheValidityDuration) {
          return _cachedPosition;
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled, return null
        return null;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions denied
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions denied forever
        return null;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Cache the position
      _cachedPosition = position;
      _lastFetchTime = DateTime.now();

      return position;
    } catch (e) {
      // Handle any errors gracefully
      return null;
    }
  }

  /// Get current position with detailed error messages for UI display
  Future<Position> getPosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled',
        LocationErrorType.serviceDisabled,
      );
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permission denied. Please enable location access in settings.',
          LocationErrorType.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission permanently denied. Please enable it in app settings.',
        LocationErrorType.permissionDeniedForever,
      );
    }

    try {
      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Cache the position
      _cachedPosition = position;
      _lastFetchTime = DateTime.now();

      return position;
    } catch (e) {
      throw LocationServiceException(
        'Failed to get location. Please check your GPS signal.',
        LocationErrorType.fetchFailed,
      );
    }
  }

  /// Get JAKIM zone based on coordinates with comprehensive Malaysia coverage
  Future<String> getJakimZone() async {
    final pos = await getPosition();
    return getZoneFromCoordinates(pos.latitude, pos.longitude);
  }

  /// Get JAKIM zone from coordinates (can be used independently)
  String getZoneFromCoordinates(double lat, double lng) {
    // ===== COMPREHENSIVE MALAYSIA ZONE MAPPING =====
    
    // Sabah (North Borneo)
    if (lat >= 4.0 && lat <= 7.5 && lng >= 115.0 && lng <= 119.5) {
      if (lng >= 117.5) return "SBH01"; // Sandakan
      if (lat >= 6.0) return "SBH02"; // Kota Marudu
      if (lng >= 116.0) return "SBH03"; // Kota Kinabalu
      if (lat <= 5.2) return "SBH04"; // Kuala Penyu
      if (lng <= 115.5) return "SBH05"; // Labuan
      return "SBH03"; // Default Sabah
    }

    // Sarawak (Northwest Borneo)
    if (lat >= 0.8 && lat <= 5.0 && lng >= 109.5 && lng <= 115.5) {
      if (lng <= 110.5) return "SWK01"; // Kuching
      if (lng >= 113.0) return "SWK03"; // Miri
      if (lat >= 3.0) return "SWK04"; // Limbang
      if (lng >= 111.5) return "SWK02"; // Sibu
      return "SWK01"; // Default Sarawak
    }

    // Perlis (Northernmost state)
    if (lat >= 6.4 && lng >= 100.0 && lng <= 100.4) {
      return "PLS01";
    }

    // Kedah (Northwest Peninsular)
    if (lat >= 5.2 && lat <= 6.7 && lng >= 99.6 && lng <= 101.0) {
      if (lng <= 99.8) return "KDH06"; // Langkawi
      if (lat >= 6.1) return "KDH01"; // Kota Setar
      if (lng >= 100.5) return "KDH02"; // Kuala Muda
      if (lat >= 5.9) return "KDH03"; // Padang Terap
      if (lng >= 100.6) return "KDH05"; // Kulim
      return "KDH01"; // Default Kedah
    }

    // Penang (Island + mainland)
    if (lat >= 5.2 && lat <= 5.6 && lng >= 100.2 && lng <= 100.5) {
      return "PNG01";
    }

    // Kelantan (Northeast coast)
    if (lat >= 4.5 && lat <= 6.3 && lng >= 101.5 && lng <= 102.7) {
      if (lng >= 102.0) return "KTN03"; // Gua Musang
      return "KTN01"; // Kota Bharu
    }

    // Terengganu (East coast)
    if (lat >= 4.0 && lat <= 5.9 && lng >= 102.5 && lng <= 103.5) {
      if (lat <= 4.5) return "TRG04"; // Dungun
      if (lat >= 5.5) return "TRG02"; // Besut
      if (lng >= 103.0) return "TRG03"; // Hulu Terengganu
      return "TRG01"; // Kuala Terengganu
    }

    // Perak (Central west)
    if (lat >= 3.7 && lat <= 5.7 && lng >= 100.4 && lng <= 101.5) {
      if (lat <= 4.2) return "PRK01"; // Tapah
      if (lat >= 5.3) return "PRK06"; // Taiping
      if (lng >= 101.0) return "PRK02"; // Ipoh
      if (lat >= 5.0) return "PRK03"; // Lenggong
      return "PRK05"; // Teluk Intan
    }

    // Pahang (Central/East interior)
    if (lat >= 2.5 && lat <= 4.5 && lng >= 101.5 && lng <= 103.5) {
      if (lng <= 101.8) return "PHG06"; // Cameron Highlands
      if (lat <= 3.0) return "PHG02"; // Kuantan
      if (lng >= 102.5) return "PHG03"; // Jerantut
      return "PHG02"; // Default Pahang
    }

    // Selangor (Central west coast)
    if (lat >= 2.7 && lat <= 3.8 && lng >= 101.0 && lng <= 101.8) {
      if (lat >= 3.5) return "SGR02"; // Kuala Selangor
      if (lng <= 101.4) return "SGR03"; // Klang
      return "SGR01"; // Gombak/Petaling
    }

    // Kuala Lumpur (Federal Territory)
    if (lat >= 3.05 && lat <= 3.25 && lng >= 101.6 && lng <= 101.8) {
      return "WLY01";
    }

    // Putrajaya (Federal Territory)
    if (lat >= 2.85 && lat <= 3.0 && lng >= 101.65 && lng <= 101.75) {
      return "WLY02";
    }

    // Negeri Sembilan (South central)
    if (lat >= 2.5 && lat <= 3.2 && lng >= 101.5 && lng <= 102.5) {
      if (lat >= 2.9) return "NGS02"; // Seremban
      return "NGS01"; // Jempol
    }

    // Melaka (Southwest coast)
    if (lat >= 2.0 && lat <= 2.5 && lng >= 102.0 && lng <= 102.6) {
      return "MLK01";
    }

    // Johor (Southernmost state)
    if (lat >= 1.2 && lat <= 2.8 && lng >= 102.5 && lng <= 104.5) {
      if (lng <= 103.0) return "JHR03"; // Kluang
      if (lat >= 2.0) return "JHR02"; // Johor Bahru
      if (lng >= 104.0) return "JHR01"; // Pulau Aur
      return "JHR04"; // Muar/Batu Pahat
    }

    // Default fallback - Kuala Lumpur
    return "WLY01";
  }

  /// Get user-friendly zone name
  String getZoneName(String zoneCode) {
    final zoneNames = {
      // Johor
      'JHR01': 'Pulau Aur, Pemanggil',
      'JHR02': 'Johor Bahru, Kota Tinggi, Mersing',
      'JHR03': 'Kluang, Pontian',
      'JHR04': 'Batu Pahat, Muar, Segamat',
      
      // Kedah
      'KDH01': 'Kota Setar, Kubang Pasu',
      'KDH02': 'Kuala Muda, Yan, Pendang',
      'KDH03': 'Padang Terap, Sik',
      'KDH04': 'Baling',
      'KDH05': 'Bandar Baharu, Kulim',
      'KDH06': 'Langkawi',
      'KDH07': 'Gunung Jerai',
      
      // Kelantan
      'KTN01': 'Kota Bharu, Bachok',
      'KTN03': 'Jeli, Gua Musang',
      
      // Kuala Lumpur
      'WLY01': 'Kuala Lumpur',
      'WLY02': 'Putrajaya',
      
      // Melaka
      'MLK01': 'Bandar Melaka',
      
      // Negeri Sembilan
      'NGS01': 'Jempol, Tampin',
      'NGS02': 'Port Dickson, Seremban',
      
      // Pahang
      'PHG01': 'Pulau Tioman',
      'PHG02': 'Kuantan, Pekan, Rompin',
      'PHG03': 'Jerantut, Temerloh',
      'PHG04': 'Bentong, Lipis, Raub',
      'PHG05': 'Genting Highlands',
      'PHG06': 'Cameron Highlands',
      
      // Penang
      'PNG01': 'Penang',
      
      // Perak
      'PRK01': 'Tapah, Slim River',
      'PRK02': 'Kuala Kangsar, Ipoh',
      'PRK03': 'Lenggong, Pengkalan Hulu',
      'PRK04': 'Temengor, Belum',
      'PRK05': 'Kg Gajah, Teluk Intan',
      'PRK06': 'Selama, Taiping',
      'PRK07': 'Bukit Larut',
      
      // Perlis
      'PLS01': 'Perlis',
      
      // Sabah
      'SBH01': 'Sandakan, Lahad Datu',
      'SBH02': 'Ranau, Kota Marudu',
      'SBH03': 'Kota Kinabalu, Tuaran',
      'SBH04': 'Kuala Penyu, Beaufort',
      'SBH05': 'Labuan',
      'SBH06': 'Lawas, Sipitang',
      'SBH07': 'Sarikei, Betong',
      'SBH08': 'Kota Kinabatangan',
      'SBH09': 'Pensiangan, Keningau',
      
      // Sarawak
      'SWK01': 'Kuching, Samarahan',
      'SWK02': 'Betong, Sibu, Kapit',
      'SWK03': 'Mukah, Bintulu',
      'SWK04': 'Limbang, Lawas',
      'SWK05': 'Miri, Niah',
      'SWK06': 'Bintulu, Tatau',
      'SWK07': 'Bario, Miri',
      'SWK08': 'Kapit, Song',
      'SWK09': 'Sibu, Mukah',
      
      // Selangor
      'SGR01': 'Gombak, Petaling, Sepang',
      'SGR02': 'Kuala Selangor, Sabak Bernam',
      'SGR03': 'Klang, Kuala Langat',
      
      // Terengganu
      'TRG01': 'Kuala Terengganu, Marang',
      'TRG02': 'Besut, Setiu',
      'TRG03': 'Hulu Terengganu',
      'TRG04': 'Dungun, Kemaman',
    };

    return zoneNames[zoneCode] ?? zoneCode;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Open app settings for user to enable location
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permission management
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Clear cached position
  void clearCache() {
    _cachedPosition = null;
    _lastFetchTime = null;
  }

  /// Get distance between two coordinates in kilometers
  double getDistanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    ) / 1000; // Convert meters to kilometers
  }
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;
  final LocationErrorType type;

  LocationServiceException(this.message, this.type);

  @override
  String toString() => message;
}

/// Types of location errors for better error handling in UI
enum LocationErrorType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  fetchFailed,
  timeout,
}
