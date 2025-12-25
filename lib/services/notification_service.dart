import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();

    // Pastikan lokasi waktu Indonesia (Asia/Jakarta)
    // Jika error lokasi, dia akan default ke local device setting
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (e) {
      // Fallback to device timezone
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // --- FITUR BARU: JADWAL DINAMIS (MENIT PRESISI) ---
  // type: 'eyedrops' (ID 0-99) atau 'medicine' (ID 100-199)
  Future<void> scheduleCustomReminders({
    required List<int> scheduleMinutes, 
    required String type, 
    required String title,
    required String body,
  }) async {
    
    // 1. Tentukan Range ID agar tidak bentrok
    int startId = type == 'eyedrops' ? 0 : 100;
    
    // 2. Hapus dulu jadwal lama untuk tipe ini
    for (int i = 0; i < 20; i++) {
      await flutterLocalNotificationsPlugin.cancel(startId + i);
    }

    // 3. Pasang Jadwal Baru
    for (int i = 0; i < scheduleMinutes.length; i++) {
      int totalMinutes = scheduleMinutes[i];
      int hour = totalMinutes ~/ 60;
      int minute = totalMinutes % 60;
      
      await _scheduleDailyNotification(
        id: startId + i,
        title: title,
        body: "$body (Pukul ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')})",
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_jaganetra_main', // ID Channel
          'Pengingat Rutin', // Nama Channel
          channelDescription: 'Notifikasi untuk jadwal obat dan tetes mata',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          // sound: RawResourceAndroidNotificationSound('alarm_sound'), // Jika mau custom sound nanti
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Ulangi setiap hari di jam:menit yang sama
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
  
  // Fungsi batalkan semua (untuk debugging/reset)
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}