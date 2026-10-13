/// Enhanced Zone Service with comprehensive Malaysia JAKIM zone detection
class ZoneService {
  /// Get JAKIM prayer zone from coordinates
  /// Returns the most accurate zone code based on location
  static String getZone(double latitude, double longitude) {
    // Validate coordinates
    if (!_isValidCoordinates(latitude, longitude)) {
      return "WLY01"; // Default fallback
    }

    // Check each region systematically
    
    // Sabah (Northeast Borneo)
    if (_isSabah(latitude, longitude)) {
      return _getSabahZone(latitude, longitude);
    }

    // Sarawak (Northwest Borneo)
    if (_isSarawak(latitude, longitude)) {
      return _getSarawakZone(latitude, longitude);
    }

    // Perlis (Northernmost peninsular state)
    if (_isPerlis(latitude, longitude)) {
      return "PLS01";
    }

    // Kedah (Northwest peninsular)
    if (_isKedah(latitude, longitude)) {
      return _getKedahZone(latitude, longitude);
    }

    // Penang (Island state)
    if (_isPenang(latitude, longitude)) {
      return "PNG01";
    }

    // Kelantan (Northeast coast)
    if (_isKelantan(latitude, longitude)) {
      return _getKelantanZone(latitude, longitude);
    }

    // Terengganu (East coast)
    if (_isTerengganu(latitude, longitude)) {
      return _getTerengganuZone(latitude, longitude);
    }

    // Perak (West central)
    if (_isPerak(latitude, longitude)) {
      return _getPerakZone(latitude, longitude);
    }

    // Pahang (Central/East)
    if (_isPahang(latitude, longitude)) {
      return _getPahangZone(latitude, longitude);
    }

    // Selangor (West coast)
    if (_isSelangor(latitude, longitude)) {
      return _getSelangorZone(latitude, longitude);
    }

    // Kuala Lumpur (Federal Territory)
    if (_isKualaLumpur(latitude, longitude)) {
      return "WLY01";
    }

    // Putrajaya (Federal Territory)
    if (_isPutrajaya(latitude, longitude)) {
      return "WLY02";
    }

    // Negeri Sembilan (South central)
    if (_isNegeriSembilan(latitude, longitude)) {
      return _getNegeriSembilanZone(latitude, longitude);
    }

    // Melaka (Southwest coast)
    if (_isMelaka(latitude, longitude)) {
      return "MLK01";
    }

    // Johor (Southernmost state)
    if (_isJohor(latitude, longitude)) {
      return _getJohorZone(latitude, longitude);
    }

    // Default fallback - Kuala Lumpur
    return "WLY01";
  }

  // ===== REGION DETECTION METHODS =====

  static bool _isSabah(double lat, double lng) {
    return lat >= 4.0 && lat <= 7.5 && lng >= 115.0 && lng <= 119.5;
  }

  static bool _isSarawak(double lat, double lng) {
    return lat >= 0.8 && lat <= 5.0 && lng >= 109.5 && lng <= 115.5;
  }

  static bool _isPerlis(double lat, double lng) {
    return lat >= 6.4 && lat <= 6.75 && lng >= 100.0 && lng <= 100.4;
  }

  static bool _isKedah(double lat, double lng) {
    return lat >= 5.2 && lat <= 6.7 && lng >= 99.6 && lng <= 101.0;
  }

  static bool _isPenang(double lat, double lng) {
    return lat >= 5.15 && lat <= 5.55 && lng >= 100.15 && lng <= 100.55;
  }

  static bool _isKelantan(double lat, double lng) {
    return lat >= 4.5 && lat <= 6.3 && lng >= 101.5 && lng <= 102.7;
  }

  static bool _isTerengganu(double lat, double lng) {
    return lat >= 4.0 && lat <= 5.9 && lng >= 102.5 && lng <= 103.5;
  }

  static bool _isPerak(double lat, double lng) {
    return lat >= 3.7 && lat <= 5.7 && lng >= 100.4 && lng <= 101.5;
  }

  static bool _isPahang(double lat, double lng) {
    return lat >= 2.5 && lat <= 4.5 && lng >= 101.5 && lng <= 103.5;
  }

  static bool _isSelangor(double lat, double lng) {
    return lat >= 2.7 && lat <= 3.8 && lng >= 101.0 && lng <= 101.8;
  }

  static bool _isKualaLumpur(double lat, double lng) {
    return lat >= 3.05 && lat <= 3.25 && lng >= 101.6 && lng <= 101.8;
  }

  static bool _isPutrajaya(double lat, double lng) {
    return lat >= 2.85 && lat <= 3.0 && lng >= 101.65 && lng <= 101.75;
  }

  static bool _isNegeriSembilan(double lat, double lng) {
    return lat >= 2.5 && lat <= 3.2 && lng >= 101.5 && lng <= 102.5;
  }

  static bool _isMelaka(double lat, double lng) {
    return lat >= 2.0 && lat <= 2.5 && lng >= 102.0 && lng <= 102.6;
  }

  static bool _isJohor(double lat, double lng) {
    return lat >= 1.2 && lat <= 2.8 && lng >= 102.5 && lng <= 104.5;
  }

  // ===== ZONE DETECTION METHODS =====

  static String _getSabahZone(double lat, double lng) {
    if (lng >= 117.5) return "SBH01"; // Sandakan, Lahad Datu
    if (lat >= 6.0) return "SBH02"; // Ranau, Kota Marudu
    if (lng >= 116.0) return "SBH03"; // Kota Kinabalu, Tuaran
    if (lat <= 5.2) return "SBH04"; // Kuala Penyu, Beaufort
    if (lng <= 115.5) return "SBH05"; // Labuan
    if (lng >= 117.0) return "SBH08"; // Kota Kinabatangan
    if (lat >= 5.5) return "SBH09"; // Keningau, Tambunan
    return "SBH03"; // Default: Kota Kinabalu
  }

  static String _getSarawakZone(double lat, double lng) {
    if (lng <= 110.5) return "SWK01"; // Kuching, Samarahan
    if (lng >= 113.5) return "SWK05"; // Miri, Niah
    if (lat >= 3.5) return "SWK04"; // Limbang, Lawas
    if (lng >= 112.5) return "SWK03"; // Mukah, Bintulu
    if (lng >= 111.0) return "SWK02"; // Sibu, Kapit
    if (lat <= 2.0) return "SWK01"; // Kuching area
    return "SWK01"; // Default: Kuching
  }

  static String _getKedahZone(double lat, double lng) {
    if (lng <= 99.85) return "KDH06"; // Langkawi
    if (lat >= 6.1) return "KDH01"; // Kota Setar, Kubang Pasu
    if (lng >= 100.5) return "KDH02"; // Kuala Muda, Yan
    if (lat >= 5.9 && lng <= 100.5) return "KDH03"; // Padang Terap, Sik
    if (lat <= 5.5 && lng <= 100.3) return "KDH04"; // Baling
    if (lng >= 100.6) return "KDH05"; // Kulim, Bandar Baharu
    return "KDH01"; // Default: Kota Setar
  }

  static String _getKelantanZone(double lat, double lng) {
    if (lng >= 102.0) return "KTN03"; // Gua Musang, Jeli
    return "KTN01"; // Kota Bharu, Bachok, Pasir Puteh
  }

  static String _getTerengganuZone(double lat, double lng) {
    if (lat <= 4.5) return "TRG04"; // Dungun, Kemaman
    if (lat >= 5.5) return "TRG02"; // Besut, Setiu
    if (lng >= 103.0) return "TRG03"; // Hulu Terengganu
    return "TRG01"; // Kuala Terengganu, Marang
  }

  static String _getPerakZone(double lat, double lng) {
    if (lat <= 4.2) return "PRK01"; // Tapah, Slim River, Tanjung Malim
    if (lat >= 5.3) return "PRK06"; // Taiping, Bagan Serai
    if (lng >= 101.0) return "PRK02"; // Ipoh, Kuala Kangsar
    if (lat >= 5.0) return "PRK03"; // Lenggong, Pengkalan Hulu
    if (lng <= 100.8) return "PRK05"; // Teluk Intan, Bagan Datuk
    return "PRK02"; // Default: Ipoh
  }

  static String _getPahangZone(double lat, double lng) {
    if (lng <= 101.8 && lat >= 3.8) return "PHG06"; // Cameron Highlands
    if (lng <= 101.8) return "PHG05"; // Genting Highlands
    if (lat <= 3.0) return "PHG02"; // Kuantan, Pekan, Rompin
    if (lng >= 102.5) return "PHG03"; // Jerantut, Temerloh
    if (lat >= 3.5) return "PHG04"; // Bentong, Raub
    if (lng >= 104.0) return "PHG01"; // Pulau Tioman
    return "PHG02"; // Default: Kuantan
  }

  static String _getSelangorZone(double lat, double lng) {
    if (lat >= 3.5) return "SGR02"; // Kuala Selangor, Sabak Bernam
    if (lng <= 101.4) return "SGR03"; // Klang, Kuala Langat
    return "SGR01"; // Gombak, Petaling, Sepang, Hulu Langat
  }

  static String _getNegeriSembilanZone(double lat, double lng) {
    if (lat >= 2.9) return "NGS02"; // Port Dickson, Seremban, Kuala Pilah
    return "NGS01"; // Jempol, Tampin
  }

  static String _getJohorZone(double lat, double lng) {
    if (lng >= 104.0) return "JHR01"; // Pulau Aur, Pemanggil
    if (lat >= 2.0) return "JHR02"; // Johor Bahru, Kota Tinggi, Mersing
    if (lng <= 103.0) return "JHR03"; // Kluang, Pontian
    return "JHR04"; // Batu Pahat, Muar, Segamat
  }

  // ===== UTILITY METHODS =====

  /// Validate coordinates are within valid range
  static bool _isValidCoordinates(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  /// Check if coordinates are within Malaysia
  static bool isInMalaysia(double latitude, double longitude) {
    // Peninsular Malaysia
    bool isPeninsular = latitude >= 1.2 && latitude <= 6.75 &&
                        longitude >= 99.5 && longitude <= 104.5;

    // East Malaysia (Sabah & Sarawak)
    bool isEastMalaysia = latitude >= 0.8 && latitude <= 7.5 &&
                          longitude >= 109.5 && longitude <= 119.5;

    return isPeninsular || isEastMalaysia;
  }

  /// Get state name from zone code
  static String getStateName(String zoneCode) {
    if (zoneCode.startsWith('JHR')) return 'Johor';
    if (zoneCode.startsWith('KDH')) return 'Kedah';
    if (zoneCode.startsWith('KTN')) return 'Kelantan';
    if (zoneCode.startsWith('MLK')) return 'Melaka';
    if (zoneCode.startsWith('NGS')) return 'Negeri Sembilan';
    if (zoneCode.startsWith('PHG')) return 'Pahang';
    if (zoneCode.startsWith('PNG')) return 'Penang';
    if (zoneCode.startsWith('PRK')) return 'Perak';
    if (zoneCode.startsWith('PLS')) return 'Perlis';
    if (zoneCode.startsWith('SBH')) return 'Sabah';
    if (zoneCode.startsWith('SGR')) return 'Selangor';
    if (zoneCode.startsWith('SWK')) return 'Sarawak';
    if (zoneCode.startsWith('TRG')) return 'Terengganu';
    if (zoneCode == 'WLY01') return 'Kuala Lumpur';
    if (zoneCode == 'WLY02') return 'Putrajaya';
    return 'Unknown';
  }

  /// Get zone name (area description)
  static String getZoneName(String zoneCode) {
    final zoneNames = {
      // Johor
      'JHR01': 'Pulau Aur, Pemanggil',
      'JHR02': 'Johor Bahru, Kota Tinggi, Mersing',
      'JHR03': 'Kluang, Pontian',
      'JHR04': 'Batu Pahat, Muar, Segamat',
      
      // Kedah
      'KDH01': 'Kota Setar, Kubang Pasu, Pokok Sena',
      'KDH02': 'Kuala Muda, Yan, Pendang',
      'KDH03': 'Padang Terap, Sik',
      'KDH04': 'Baling',
      'KDH05': 'Bandar Baharu, Kulim',
      'KDH06': 'Langkawi',
      'KDH07': 'Gunung Jerai',
      
      // Kelantan
      'KTN01': 'Kota Bharu, Bachok, Pasir Puteh',
      'KTN03': 'Jeli, Gua Musang',
      
      // Kuala Lumpur & Putrajaya
      'WLY01': 'Kuala Lumpur',
      'WLY02': 'Putrajaya',
      
      // Melaka
      'MLK01': 'Bandar Melaka, Alor Gajah, Jasin',
      
      // Negeri Sembilan
      'NGS01': 'Jempol, Tampin',
      'NGS02': 'Port Dickson, Seremban, Kuala Pilah',
      
      // Pahang
      'PHG01': 'Pulau Tioman',
      'PHG02': 'Kuantan, Pekan, Rompin, Maran',
      'PHG03': 'Jerantut, Temerloh, Bera, Bentong',
      'PHG04': 'Bentong, Lipis, Raub',
      'PHG05': 'Genting Highlands, Janda Baik',
      'PHG06': 'Cameron Highlands, Bukit Fraser',
      
      // Penang
      'PNG01': 'Penang',
      
      // Perak
      'PRK01': 'Tapah, Slim River, Tanjung Malim',
      'PRK02': 'Kuala Kangsar, Sg. Siput, Ipoh',
      'PRK03': 'Lenggong, Pengkalan Hulu, Grik',
      'PRK04': 'Temengor, Belum',
      'PRK05': 'Kg Gajah, Teluk Intan, Bagan Datuk',
      'PRK06': 'Selama, Taiping, Bagan Serai',
      'PRK07': 'Bukit Larut',
      
      // Perlis
      'PLS01': 'Perlis',
      
      // Sabah
      'SBH01': 'Sandakan, Bdr. Bkt. Garam, Lahad Datu',
      'SBH02': 'Ranau, Kota Marudu, Kota Belud',
      'SBH03': 'Penampang, Papar, Tuaran, Kota Kinabalu',
      'SBH04': 'Kuala Penyu, Beaufort, Kudat',
      'SBH05': 'Labuan',
      'SBH06': 'Lawas, Sipitang, Tenom',
      'SBH07': 'Sarikei, Betong, Sri Aman',
      'SBH08': 'Kota Kinabatangan, Lahad Datu',
      'SBH09': 'Pensiangan, Keningau, Tambunan',
      
      // Sarawak
      'SWK01': 'Kuching, Samarahan, Simunjan',
      'SWK02': 'Betong, Saratok, Sarikei, Sibu, Kapit',
      'SWK03': 'Mukah, Dalat, Oya, Matu, Bintulu',
      'SWK04': 'Limbang, Lawas, Sundar, Trusan',
      'SWK05': 'Miri, Niah, Bekenu, Sibuti',
      'SWK06': 'Bintulu, Tatau, Sebauh',
      'SWK07': 'Bario, Miri, Limbang',
      'SWK08': 'Kapit, Song, Belaga',
      'SWK09': 'Sibu, Mukah, Dalat, Kanowit',
      
      // Selangor
      'SGR01': 'Gombak, Petaling, Sepang, Hulu Langat',
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

  /// Get full zone information
  static ZoneInfo getZoneInfo(double latitude, double longitude) {
    final zoneCode = getZone(latitude, longitude);
    final stateName = getStateName(zoneCode);
    final zoneName = getZoneName(zoneCode);
    final inMalaysia = isInMalaysia(latitude, longitude);

    return ZoneInfo(
      zoneCode: zoneCode,
      stateName: stateName,
      zoneName: zoneName,
      isInMalaysia: inMalaysia,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get all zones for a specific state
  static List<String> getStateZones(String stateName) {
    final stateZones = {
      'Johor': ['JHR01', 'JHR02', 'JHR03', 'JHR04'],
      'Kedah': ['KDH01', 'KDH02', 'KDH03', 'KDH04', 'KDH05', 'KDH06', 'KDH07'],
      'Kelantan': ['KTN01', 'KTN03'],
      'Kuala Lumpur': ['WLY01'],
      'Melaka': ['MLK01'],
      'Negeri Sembilan': ['NGS01', 'NGS02'],
      'Pahang': ['PHG01', 'PHG02', 'PHG03', 'PHG04', 'PHG05', 'PHG06'],
      'Penang': ['PNG01'],
      'Perak': ['PRK01', 'PRK02', 'PRK03', 'PRK04', 'PRK05', 'PRK06', 'PRK07'],
      'Perlis': ['PLS01'],
      'Putrajaya': ['WLY02'],
      'Sabah': ['SBH01', 'SBH02', 'SBH03', 'SBH04', 'SBH05', 'SBH06', 'SBH07', 'SBH08', 'SBH09'],
      'Sarawak': ['SWK01', 'SWK02', 'SWK03', 'SWK04', 'SWK05', 'SWK06', 'SWK07', 'SWK08', 'SWK09'],
      'Selangor': ['SGR01', 'SGR02', 'SGR03'],
      'Terengganu': ['TRG01', 'TRG02', 'TRG03', 'TRG04'],
    };

    return stateZones[stateName] ?? [];
  }

  /// Get all Malaysian states
  static List<String> getAllStates() {
    return [
      'Johor',
      'Kedah',
      'Kelantan',
      'Kuala Lumpur',
      'Melaka',
      'Negeri Sembilan',
      'Pahang',
      'Penang',
      'Perak',
      'Perlis',
      'Putrajaya',
      'Sabah',
      'Sarawak',
      'Selangor',
      'Terengganu',
    ];
  }
}

/// Zone information model
class ZoneInfo {
  final String zoneCode;
  final String stateName;
  final String zoneName;
  final bool isInMalaysia;
  final double latitude;
  final double longitude;

  ZoneInfo({
    required this.zoneCode,
    required this.stateName,
    required this.zoneName,
    required this.isInMalaysia,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'ZoneInfo(code: $zoneCode, state: $stateName, area: $zoneName, '
           'coordinates: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
  }
}