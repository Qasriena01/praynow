import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ─── Dua & Azkar Notification IDs ─────────────────────────────────────────
  static const int _morningAzkarId    = 1001;
  static const int _eveningAzkarId    = 1002;
  static const int _prayerFajrId      = 1003;
  static const int _prayerDhuhrId     = 1004;
  static const int _prayerAsrId       = 1005;
  static const int _prayerMaghribId   = 1006;
  static const int _prayerIshaId      = 1007;
  static const int _dailyDuaId        = 1008;

  // ─── Initialize ────────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    final String timezoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  // ─── Notification Detail Builder ──────────────────────────────────────────

  /// Builds [AndroidNotificationDetails] with [BigTextStyleInformation].
  /// When the user expands the notification they see:
  ///   Arabic text
  ///   Transliteration
  ///   Meaning
  ///   Benefit (optional)
  static AndroidNotificationDetails _azkarAndroidDetails({
    required String channelId,
    required String channelName,
    required String channelDesc,
    required String arabic,
    required String transliteration,
    required String meaning,
    String? benefit,
  }) {
    final expandedBody = StringBuffer()
      ..writeln(arabic)
      ..writeln(transliteration)
      ..write(meaning);
    if (benefit != null) expandedBody.write('\n$benefit');

    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      autoCancel: true,
      icon: '@mipmap/ic_launcher',
      ticker: transliteration,
      styleInformation: BigTextStyleInformation(
        expandedBody.toString(),
        htmlFormatBigText: false,
        contentTitle: channelName,
        summaryText: meaning,
      ),
    );
  }

  // ─── Schedule Helper ───────────────────────────────────────────────────────

  static tz.TZDateTime _nextDailyInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> _scheduleDailyAzkar({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required AndroidNotificationDetails androidDetails,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextDailyInstance(hour, minute),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'dua_azkar',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DUA & AZKAR NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Morning Azkar reminder — default 06:00
  static Future<void> scheduleMorningAzkar({
    int hour = 6,
    int minute = 0,
  }) async {
    await _scheduleDailyAzkar(
      id: _morningAzkarId,
      hour: hour,
      minute: minute,
      title: 'Morning Azkar',
      body: 'Start your day with the remembrance of Allah',
      androidDetails: _azkarAndroidDetails(
        channelId: 'morning_azkar_channel',
        channelName: 'Morning Azkar',
        channelDesc: 'Daily morning remembrance reminder',
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        transliteration: 'Bismillah ar-Rahman ar-Rahim',
        meaning: 'In the name of Allah, the Most Compassionate, the Most Merciful',
        benefit: 'Blessing and purification of all deeds',
      ),
    );
  }

  /// Evening Azkar reminder — default 17:30
  static Future<void> scheduleEveningAzkar({
    int hour = 17,
    int minute = 30,
  }) async {
    await _scheduleDailyAzkar(
      id: _eveningAzkarId,
      hour: hour,
      minute: minute,
      title: 'Evening Azkar',
      body: 'End your day with the remembrance of Allah',
      androidDetails: _azkarAndroidDetails(
        channelId: 'evening_azkar_channel',
        channelName: 'Evening Azkar',
        channelDesc: 'Daily evening remembrance reminder',
        arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        transliteration: 'Amsayna wa amsaal-mulk lillah',
        meaning: 'We have reached the evening and with it the dominion of Allah',
        benefit: 'Protection during the night',
      ),
    );
  }

  /// All 5 prayer dua reminders — approximate fixed times
  static Future<void> schedulePrayerDuaReminders() async {
    final prayers = [
      (id: _prayerFajrId,    hour: 5,  minute: 0,  name: 'Fajr'),
      (id: _prayerDhuhrId,   hour: 12, minute: 30, name: 'Dhuhr'),
      (id: _prayerAsrId,     hour: 15, minute: 30, name: 'Asr'),
      (id: _prayerMaghribId, hour: 18, minute: 15, name: 'Maghrib'),
      (id: _prayerIshaId,    hour: 20, minute: 0,  name: 'Isha'),
    ];

    for (final p in prayers) {
      await _scheduleDailyAzkar(
        id: p.id,
        hour: p.hour,
        minute: p.minute,
        title: '${p.name} Prayer Reminder',
        body: 'It is time for ${p.name}. Remember Allah before and after your prayer.',
        androidDetails: _azkarAndroidDetails(
          channelId: 'prayer_dua_channel',
          channelName: 'Prayer Dua',
          channelDesc: 'Reminders for dua before and after prayer',
          arabic: 'اللَّهُمَّ أَعِنِّي عَلَىٰ ذِكْرِكَ وَشُكْرِكَ',
          transliteration: "Allahumma a'inni 'ala dhikrika wa shukrika",
          meaning: 'O Allah, help me to remember You, thank You, and worship You well',
        ),
      );
    }
  }

  /// Daily dua reminder — default 08:00
  static Future<void> scheduleDailyDua({
    int hour = 8,
    int minute = 0,
  }) async {
    await _scheduleDailyAzkar(
      id: _dailyDuaId,
      hour: hour,
      minute: minute,
      title: 'Daily Dua Reminder',
      body: 'Take a moment to make dua and connect with Allah',
      androidDetails: _azkarAndroidDetails(
        channelId: 'daily_dua_channel',
        channelName: 'Daily Dua',
        channelDesc: 'Daily dua reminder',
        arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي',
        transliteration: 'Rabbi ishrah li sadri',
        meaning: 'My Lord, expand for me my breast and ease my task',
        benefit: 'Seeking clarity and ease from Allah',
      ),
    );
  }

  /// Schedule ALL Dua & Azkar notifications at once with default times
  static Future<void> scheduleAllDuaAzkar() async {
    await scheduleMorningAzkar();
    await scheduleEveningAzkar();
    await schedulePrayerDuaReminders();
    await scheduleDailyDua();
  }

  // ─── Cancel Dua & Azkar ────────────────────────────────────────────────────

  static Future<void> cancelMorningAzkar() =>
      _notifications.cancel(_morningAzkarId);

  static Future<void> cancelEveningAzkar() =>
      _notifications.cancel(_eveningAzkarId);

  static Future<void> cancelPrayerDuaReminders() async {
    for (final id in [
      _prayerFajrId,
      _prayerDhuhrId,
      _prayerAsrId,
      _prayerMaghribId,
      _prayerIshaId,
    ]) {
      await _notifications.cancel(id);
    }
  }

  static Future<void> cancelDailyDua() =>
      _notifications.cancel(_dailyDuaId);

  // ═══════════════════════════════════════════════════════════════════════════
  // ORIGINAL PRAYER TIME NOTIFICATIONS (unchanged)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Show instant notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'praynow_channel',
      'PrayNow Notifications',
      channelDescription: 'Notifications for prayer times and reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Schedule prayer time notification (exact DateTime)
  static Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_times_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('azan'),
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      'Prayer Time',
      'It\'s time for $prayerName prayer',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule reminder 5 minutes before prayer
  static Future<void> schedulePrayerReminder({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    final reminderTime = prayerTime.subtract(const Duration(minutes: 5));

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_reminders_channel',
      'Prayer Reminders',
      channelDescription: 'Reminders before prayer times',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      'Prayer Reminder',
      '$prayerName prayer in 5 minutes',
      tz.TZDateTime.from(reminderTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ─── Cancel ────────────────────────────────────────────────────────────────

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}