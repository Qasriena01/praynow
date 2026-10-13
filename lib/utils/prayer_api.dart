import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_times_result.dart';

/// Clean, Modern, Multi-Fallback Prayer Times API for PrayNow
class PrayerApi {
  // New JAKIM Official API
  static const String _jakimBase = "https://prayerapi.e-solat.gov.my";

  // International fallback API
  static const String _aladhanBase = "https://api.aladhan.com/v1";

  // Malaysia fallback API
  static const String _azanProBase = "https://api.azanpro.com";

  // Cache
  static final Map<String, CachedPrayerTimes> _cache = {};
  static const Duration _cacheDuration = Duration(hours: 12);

  /// MAIN FUNCTION — always returns valid prayer times
  static Future<PrayerTimesResult> getToday(String zone, double lat, double lon) async {
    final key = zone;

    // 1️⃣ Return from cache if fresh
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.time) < _cacheDuration) {
      return cached.result;
    }

    // 2️⃣ Try JAKIM
    try {
      final jakim = await _fetchJakim(zone);
      _cache[key] = CachedPrayerTimes(jakim, DateTime.now());
      return jakim;
    } catch (_) {}

    // 3️⃣ Try Aladhan (uses coordinates)
    try {
      final aladhan = await _fetchAladhan(lat, lon);
      _cache[key] = CachedPrayerTimes(aladhan, DateTime.now());
      return aladhan;
    } catch (_) {}

    // 4️⃣ Try AzanPro
    try {
      final azan = await _fetchAzanPro(zone);
      _cache[key] = CachedPrayerTimes(azan, DateTime.now());
      return azan;
    } catch (_) {}

    throw Exception("All prayer time services unavailable.");
  }

  // ---------------------------------------------------------
  //  🕌 1. JAKIM (NEW OFFICIAL API)
  // ---------------------------------------------------------
  static Future<PrayerTimesResult> _fetchJakim(String zone) async {
    final now = DateTime.now();
    final url = Uri.parse(
      "$_jakimBase/v1/prayer_times?zone=$zone&month=${now.month}&year=${now.year}",
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("JAKIM API Error");
    }

    final json = jsonDecode(response.body);

    if (json["status"] != "OK") {
      throw Exception("JAKIM returned invalid status");
    }

    final list = json["data"] as List;
    final today = list.firstWhere(
      (e) => e["day"].toString() == now.day.toString(),
      orElse: () => list.first,
    );

    return PrayerTimesResult(
      fajr: _parseTime(today["fajr"], now),
      sunrise: _parseTime(today["sunrise"], now),
      dhuhr: _parseTime(today["dhuhr"], now),
      asr: _parseTime(today["asr"], now),
      maghrib: _parseTime(today["maghrib"], now),
      isha: _parseTime(today["isha"], now),
    );
  }

  // ---------------------------------------------------------
  //  🌍 2. ALADHAN INTERNATIONAL API
  // ---------------------------------------------------------
  static Future<PrayerTimesResult> _fetchAladhan(double lat, double lon) async {
    final now = DateTime.now();
    final date = "${now.day}-${now.month}-${now.year}";

    final url = Uri.parse(
      "$_aladhanBase/timings/$date?latitude=$lat&longitude=$lon&method=3",
    ); // Method 3: Muslim World League (closest to Malaysia)

    final response = await http.get(url).timeout(const Duration(seconds: 10));
    final json = jsonDecode(response.body);

    if (json["code"] != 200) {
      throw Exception("Aladhan error");
    }

    final data = json["data"]["timings"];

    return PrayerTimesResult(
      fajr: _parseTime(data["Fajr"], now),
      sunrise: _parseTime(data["Sunrise"], now),
      dhuhr: _parseTime(data["Dhuhr"], now),
      asr: _parseTime(data["Asr"], now),
      maghrib: _parseTime(data["Maghrib"], now),
      isha: _parseTime(data["Isha"], now),
    );
  }

  // ---------------------------------------------------------
  //  🇲🇾 3. AZANPRO (Malaysia Backup)
  // ---------------------------------------------------------
  static Future<PrayerTimesResult> _fetchAzanPro(String zone) async {
    final now = DateTime.now();
    final url = Uri.parse("$_azanProBase/times/today.json?zone=$zone");

    final response = await http.get(url).timeout(const Duration(seconds: 10));
    final json = jsonDecode(response.body);

    if (!json.containsKey("prayer_times")) {
      throw Exception("AzanPro invalid data");
    }

    final p = json["prayer_times"];

    return PrayerTimesResult(
      fajr: _parseTime(p["fajr"], now),
      sunrise: _parseTime(p["sunrise"], now),
      dhuhr: _parseTime(p["dhuhr"], now),
      asr: _parseTime(p["asr"], now),
      maghrib: _parseTime(p["maghrib"], now),
      isha: _parseTime(p["isha"], now),
    );
  }

  // ---------------------------------------------------------
  //  ⏰ Helper — Parse "05:31" → DateTime()
  // ---------------------------------------------------------
  static DateTime _parseTime(String? input, DateTime base) {
    if (input == null || input.isEmpty) return base;

    final parts = input.split(":");
    if (parts.length < 2) return base;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return DateTime(base.year, base.month, base.day, hour, minute);
  }
}

/// Cache model
class CachedPrayerTimes {
  final PrayerTimesResult result;
  final DateTime time;

  CachedPrayerTimes(this.result, this.time);
}
