import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/book.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _lastNotificationDateKey = 'last_notification_date';

  /// Initialize the notification service
  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'urgent_books_channel',
      'ספרים דחופים',
      description: 'התראות עבור ספרים שצריך להחזיר בקרוב',
      importance: Importance.high,
      playSound: true,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Notification tapped - app will open to the current screen
  }

  /// Request notification permission (required for Android 13+)
  Future<bool> requestPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }

    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Check if we should show notification today
  Future<bool> _shouldShowNotificationToday() async {
    final lastDateStr = await _storage.read(key: _lastNotificationDateKey);
    if (lastDateStr == null) return true;

    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now();

    // Only show notification once per day
    return lastDate.year != today.year ||
        lastDate.month != today.month ||
        lastDate.day != today.day;
  }

  /// Save the notification date to avoid spam
  Future<void> _saveNotificationDate() async {
    await _storage.write(
      key: _lastNotificationDateKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Show notification for urgent books
  Future<void> showUrgentBooksNotification(List<Book> books) async {
    // Filter only urgent books
    final urgentBooks = books
        .where((book) => book.status == BookStatus.urgent)
        .toList();

    if (urgentBooks.isEmpty) {
      return; // No urgent books, no notification
    }

    // Check if we already showed notification today
    if (!await _shouldShowNotificationToday()) {
      return; // Already notified today
    }

    // Check permission
    if (!await requestPermission()) {
      return; // Permission denied
    }

    // Prepare notification text
    final count = urgentBooks.length;
    String body;
    if (count == 1) {
      body = 'יש ספר אחד להחזרה בקרוב';
    } else {
      body = 'יש $count ספרים להחזרה בקרוב';
    }

    // Show notification
    const androidDetails = AndroidNotificationDetails(
      'urgent_books_channel',
      'ספרים דחופים',
      channelDescription: 'התראות עבור ספרים שצריך להחזיר בקרוב',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // Notification ID
      'להחזיר ספרים',
      body,
      notificationDetails,
    );

    // Save that we showed notification today
    await _saveNotificationDate();
  }

  /// Clear notification history (for testing)
  Future<void> clearNotificationHistory() async {
    await _storage.delete(key: _lastNotificationDateKey);
  }
}
