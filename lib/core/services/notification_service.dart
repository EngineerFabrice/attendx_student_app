import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

// Top-level: runs in a separate Dart isolate when the app is terminated.
// _plugin must be re-initialized here — static state is NOT shared across isolates.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  final plugin = FlutterLocalNotificationsPlugin();
  await plugin.initialize(
    settings: const InitializationSettings(android: androidSettings),
  );
  await NotificationService.showFromMessage(message, plugin: plugin);
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static String? _pendingRoute;
  static Map<String, dynamic>? _pendingPayload;

  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // iOS: don't request permissions here — FCM handles that below.
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onLocalTap,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // FCM requires google-services.json — skip entirely in mock mode.
    if (ApiClient.isMockMode) return;

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Must be registered before runApp — handled here since initialize() is
    // called before runApp() in main.dart.
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Foreground messages: FCM suppresses heads-up by default, show locally.
    FirebaseMessaging.onMessage.listen(
      (msg) => showFromMessage(msg),
    );

    // Notification tap: app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);

    // Notification tap: app was terminated
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _handleTap(initial);

    // Re-register with backend whenever Firebase rotates the token.
    FirebaseMessaging.instance.onTokenRefresh.listen(_onTokenRefresh);
  }

  /// Returns the current FCM registration token. Returns null in mock mode or on failure.
  static Future<String?> getToken() async {
    if (ApiClient.isMockMode) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Show a notification from an FCM message. Handles both notification
  /// messages and data-only messages. Accepts an optional [plugin] so the
  /// background isolate can pass its own initialized instance.
  static Future<void> showFromMessage(
    RemoteMessage message, {
    FlutterLocalNotificationsPlugin? plugin,
  }) async {
    final p = plugin ?? _plugin;
    final n = message.notification;

    final title = n?.title ?? message.data['title'] as String?;
    final body = n?.body ?? message.data['body'] as String?;

    if (title == null && body == null) return;

    await p.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  /// Consume the route set by a notification tap. Returns null if none pending.
  static ({String route, Map<String, dynamic> payload})? consumePendingRoute() {
    if (_pendingRoute == null) return null;
    final result = (route: _pendingRoute!, payload: _pendingPayload ?? {});
    _pendingRoute = null;
    _pendingPayload = null;
    return result;
  }

  // ── Internal ────────────────────────────────────────────────────────────────

  static void _handleTap(RemoteMessage message) {
    final type = message.data['type'] as String?;
    switch (type) {
      case 'session_started':
        _pendingRoute = '/checkin';
        _pendingPayload = message.data;
      case 'absence_warning':
        _pendingRoute = '/analytics';
        _pendingPayload = message.data;
      default:
        _pendingRoute = '/dashboard';
        _pendingPayload = message.data;
    }
  }

  static void _onLocalTap(NotificationResponse response) {
    _pendingRoute = '/dashboard';
    _pendingPayload = {};
  }

  // Invoked by onTokenRefresh — re-register lazily via a stored callback.
  // The auth layer sets this callback after login so token refreshes are
  // forwarded to the backend without a circular import.
  static void Function(String token)? _tokenRefreshCallback;

  static void setTokenRefreshCallback(void Function(String token) cb) {
    _tokenRefreshCallback = cb;
  }

  static void _onTokenRefresh(String newToken) {
    _tokenRefreshCallback?.call(newToken);
  }

  // ── Public show helpers ──────────────────────────────────────────────────────

  static Future<void> showSessionStarted(
      String courseName, String room) async {
    await _plugin.show(
      id: 10,
      title: 'Session Started',
      body: '$courseName in $room — tap to check in',
      notificationDetails: _details(),
    );
  }

  static Future<void> showAttendanceConfirmed(String courseName) async {
    await _plugin.show(
      id: 11,
      title: 'Attendance Confirmed',
      body: 'You have been marked present for $courseName',
      notificationDetails: _details(),
    );
  }

  static Future<void> showAbsenceWarning(
      String courseName, double rate) async {
    await _plugin.show(
      id: 12,
      title: 'Absence Warning',
      body: '$courseName attendance ${rate.toInt()}% — below 75% threshold',
      notificationDetails: _details(),
    );
  }

  static NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'attendx_main',
        'AttendX',
        channelDescription: 'Session and attendance notifications',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
