import 'dart:math';

/// Enhanced Qibla Calculator with comprehensive features
/// Calculates the direction to the Holy Kaaba in Mecca from any location
class QiblaCalculator {
  // Holy Kaaba coordinates (Mecca, Saudi Arabia)
  static const double kaabahLatitude = 21.4225;
  static const double kaabahLongitude = 39.8262;
  
  // Additional sacred locations
  static const double madinahLatitude = 24.4672;
  static const double madinahLongitude = 39.6111;
  
  static const double jerusalemLatitude = 31.7683;
  static const double jerusalemLongitude = 35.2137;

  /// Calculate Qibla direction from current location
  /// Returns bearing in degrees (0-360°)
  /// 0° = North, 90° = East, 180° = South, 270° = West
  static double calculate(double latitude, double longitude) {
    return calculateBearing(
      latitude,
      longitude,
      kaabahLatitude,
      kaabahLongitude,
    );
  }

  /// Calculate bearing between two coordinates
  /// Returns angle in degrees (0-360°)
  static double calculateBearing(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    // Convert to radians
    final fromLatRad = _degToRad(fromLat);
    final fromLngRad = _degToRad(fromLng);
    final toLatRad = _degToRad(toLat);
    final toLngRad = _degToRad(toLng);

    // Calculate difference in longitude
    final dLng = toLngRad - fromLngRad;

    // Calculate bearing using Haversine formula
    final y = sin(dLng) * cos(toLatRad);
    final x = cos(fromLatRad) * sin(toLatRad) - 
              sin(fromLatRad) * cos(toLatRad) * cos(dLng);

    double bearing = atan2(y, x);
    bearing = _radToDeg(bearing);

    // Normalize to 0-360 degrees
    return (bearing + 360) % 360;
  }

  /// Get distance to Kaaba in kilometers
  static double getDistanceToKaaba(double latitude, double longitude) {
    return calculateDistance(
      latitude,
      longitude,
      kaabahLatitude,
      kaabahLongitude,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371.0;

    final lat1Rad = _degToRad(lat1);
    final lat2Rad = _degToRad(lat2);
    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
              cos(lat1Rad) * cos(lat2Rad) * sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Get compass direction name from bearing
  /// Returns direction like "North", "Northeast", "East", etc.
  static String getCompassDirection(double bearing) {
    const directions = [
      'North',
      'Northeast',
      'East',
      'Southeast',
      'South',
      'Southwest',
      'West',
      'Northwest',
    ];

    // Normalize bearing
    bearing = (bearing + 360) % 360;

    // Each direction covers 45 degrees
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  /// Get detailed compass direction (16 points)
  /// Returns more precise directions like "North-Northeast", "East-Southeast", etc.
  static String getDetailedCompassDirection(double bearing) {
    const directions = [
      'North',
      'North-Northeast',
      'Northeast',
      'East-Northeast',
      'East',
      'East-Southeast',
      'Southeast',
      'South-Southeast',
      'South',
      'South-Southwest',
      'Southwest',
      'West-Southwest',
      'West',
      'West-Northwest',
      'Northwest',
      'North-Northwest',
    ];

    // Normalize bearing
    bearing = (bearing + 360) % 360;

    // Each direction covers 22.5 degrees
    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Get Arabic compass direction
  static String getArabicDirection(double bearing) {
    const arabicDirections = [
      'شمال', // North
      'شمال شرق', // Northeast
      'شرق', // East
      'جنوب شرق', // Southeast
      'جنوب', // South
      'جنوب غرب', // Southwest
      'غرب', // West
      'شمال غرب', // Northwest
    ];

    bearing = (bearing + 360) % 360;
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return arabicDirections[index];
  }

  /// Check if bearing is pointing towards Kaaba (within tolerance)
  /// tolerance: acceptable deviation in degrees (default: 5°)
  static bool isPointingToKaaba(
    double currentBearing,
    double qiblaBearing, {
    double tolerance = 5.0,
  }) {
    // Normalize bearings
    currentBearing = (currentBearing + 360) % 360;
    qiblaBearing = (qiblaBearing + 360) % 360;

    // Calculate shortest angular difference
    double difference = (qiblaBearing - currentBearing).abs();
    if (difference > 180) {
      difference = 360 - difference;
    }

    return difference <= tolerance;
  }

  /// Get relative direction instruction
  /// Returns user-friendly instruction like "Turn 45° right"
  static String getRelativeDirection(
    double currentBearing,
    double targetBearing,
  ) {
    // Normalize bearings
    currentBearing = (currentBearing + 360) % 360;
    targetBearing = (targetBearing + 360) % 360;

    // Calculate difference
    double difference = targetBearing - currentBearing;

    // Normalize to -180 to 180
    if (difference > 180) {
      difference -= 360;
    } else if (difference < -180) {
      difference += 360;
    }

    if (difference.abs() < 5) {
      return 'You are facing Qibla';
    } else if (difference > 0) {
      return 'Turn ${difference.toStringAsFixed(0)}° right';
    } else {
      return 'Turn ${difference.abs().toStringAsFixed(0)}° left';
    }
  }

  /// Format bearing for display
  /// Returns formatted string like "125.5° SE"
  static String formatBearing(double bearing, {bool includeDirection = true}) {
    final degrees = bearing.toStringAsFixed(1);
    if (includeDirection) {
      final direction = getCompassDirection(bearing);
      return '$degrees° ${_getDirectionAbbreviation(direction)}';
    }
    return '$degrees°';
  }

  /// Get direction abbreviation (N, NE, E, etc.)
  static String _getDirectionAbbreviation(String direction) {
    const abbreviations = {
      'North': 'N',
      'Northeast': 'NE',
      'East': 'E',
      'Southeast': 'SE',
      'South': 'S',
      'Southwest': 'SW',
      'West': 'W',
      'Northwest': 'NW',
    };
    return abbreviations[direction] ?? '';
  }

  /// Calculate direction to Madinah (additional feature)
  static double calculateDirectionToMadinah(double latitude, double longitude) {
    return calculateBearing(
      latitude,
      longitude,
      madinahLatitude,
      madinahLongitude,
    );
  }

  /// Calculate direction to Jerusalem (additional feature)
  static double calculateDirectionToJerusalem(double latitude, double longitude) {
    return calculateBearing(
      latitude,
      longitude,
      jerusalemLatitude,
      jerusalemLongitude,
    );
  }

  /// Get travel time to Kaaba (rough estimate by flight)
  /// Returns estimated hours, assuming average flight speed of 800 km/h
  static double getEstimatedFlightTime(double latitude, double longitude) {
    final distance = getDistanceToKaaba(latitude, longitude);
    const averageFlightSpeed = 800.0; // km/h
    return distance / averageFlightSpeed;
  }

  /// Format distance for display
  /// Returns formatted string like "8,234 km" or "234 km"
  static String formatDistance(double kilometers) {
    if (kilometers >= 1000) {
      return '${(kilometers / 1000).toStringAsFixed(1)}k km';
    } else if (kilometers >= 100) {
      return '${kilometers.toStringAsFixed(0)} km';
    } else {
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }

  /// Get Qibla info for a location
  /// Returns comprehensive information about Qibla from current location
  static QiblaInfo getQiblaInfo(double latitude, double longitude) {
    final bearing = calculate(latitude, longitude);
    final distance = getDistanceToKaaba(latitude, longitude);
    final direction = getCompassDirection(bearing);
    final detailedDirection = getDetailedCompassDirection(bearing);
    final arabicDirection = getArabicDirection(bearing);
    final flightTime = getEstimatedFlightTime(latitude, longitude);

    return QiblaInfo(
      bearing: bearing,
      distance: distance,
      direction: direction,
      detailedDirection: detailedDirection,
      arabicDirection: arabicDirection,
      estimatedFlightTime: flightTime,
    );
  }

  /// Validate coordinates
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  // Helper methods
  static double _degToRad(double degrees) => degrees * pi / 180;
  static double _radToDeg(double radians) => radians * 180 / pi;
}

/// Comprehensive Qibla information model
class QiblaInfo {
  /// Qibla bearing in degrees (0-360)
  final double bearing;
  
  /// Distance to Kaaba in kilometers
  final double distance;
  
  /// Compass direction (8-point: N, NE, E, etc.)
  final String direction;
  
  /// Detailed compass direction (16-point)
  final String detailedDirection;
  
  /// Arabic direction name
  final String arabicDirection;
  
  /// Estimated flight time in hours
  final double estimatedFlightTime;

  QiblaInfo({
    required this.bearing,
    required this.distance,
    required this.direction,
    required this.detailedDirection,
    required this.arabicDirection,
    required this.estimatedFlightTime,
  });

  /// Get formatted bearing string
  String get formattedBearing => '${bearing.toStringAsFixed(1)}°';

  /// Get formatted distance string
  String get formattedDistance => QiblaCalculator.formatDistance(distance);

  /// Get formatted flight time
  String get formattedFlightTime {
    if (estimatedFlightTime < 1) {
      return '${(estimatedFlightTime * 60).toStringAsFixed(0)} minutes';
    } else if (estimatedFlightTime < 24) {
      return '${estimatedFlightTime.toStringAsFixed(1)} hours';
    } else {
      final days = (estimatedFlightTime / 24).toStringAsFixed(1);
      return '$days days';
    }
  }

  @override
  String toString() {
    return 'QiblaInfo(bearing: $formattedBearing, distance: $formattedDistance, '
           'direction: $direction, flightTime: $formattedFlightTime)';
  }
}