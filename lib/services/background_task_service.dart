import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/library_service.dart';
import '../services/notification_service.dart';
import '../models/book.dart';

/// Background task service for daily book expiration checks
class BackgroundTaskService {
  static const String taskName = 'dailyBookCheck';
  static const String uniqueName = 'dailyBookCheckTask';

  /// Initialize the background task service
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Schedule the daily task at 8:00 AM
    await scheduleTask();
  }

  /// Schedule the daily task
  static Future<void> scheduleTask() async {
    await Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  /// Calculate initial delay to run at 8:00 AM
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);

    // If it's already past 8:00 AM today, schedule for tomorrow
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime.difference(now);
  }

  /// Cancel the scheduled task
  static Future<void> cancelTask() async {
    await Workmanager().cancelByUniqueName(uniqueName);
  }
}

/// Background task callback - runs in isolate
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize notification service for background context
      final FlutterLocalNotificationsPlugin notifications =
          FlutterLocalNotificationsPlugin();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      );

      await notifications.initialize(initSettings);

      // Create notification channel
      const androidChannel = AndroidNotificationChannel(
        'urgent_books_channel',
        'ספרים דחופים',
        description: 'התראות עבור ספרים שצריך להחזיר בקרוב',
        importance: Importance.high,
        playSound: true,
        enableVibration: false,
      );

      await notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      // Get stored credentials
      const storage = FlutterSecureStorage();
      final username = await storage.read(key: 'username');
      final password = await storage.read(key: 'password');

      if (username == null || password == null) {
        return Future.value(true); // No credentials, but don't fail the task
      }

      // Fetch books
      final libraryService = LibraryService();
      final books = await libraryService.fetchBooks(username, password);

      // Check for urgent books (3 days or less)
      final urgentBooks = books
          .where((book) => book.status == BookStatus.urgent)
          .toList();

      if (urgentBooks.isEmpty) {
        return Future.value(true); // No urgent books
      }

      // Check if we should show notification today
      final lastNotificationDate = await storage.read(
        key: 'last_notification_date',
      );
      if (lastNotificationDate != null) {
        final lastDate = DateTime.parse(lastNotificationDate);
        final today = DateTime.now();

        // Only show notification once per day
        if (lastDate.year == today.year &&
            lastDate.month == today.month &&
            lastDate.day == today.day) {
          return Future.value(true); // Already notified today
        }
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

      await notifications.show(0, 'להחזיר ספרים', body, notificationDetails);

      // Save notification date
      await storage.write(
        key: 'last_notification_date',
        value: DateTime.now().toIso8601String(),
      );

      return Future.value(true);
    } catch (e) {
      // Log error but don't fail the task
      return Future.value(true);
    }
  });
}
