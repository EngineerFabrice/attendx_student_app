import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'core/network/api_client.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase requires google-services.json — skip in mock/debug mode.
  if (!ApiClient.isMockMode) {
    await Firebase.initializeApp();
  }

  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: AttendXApp(),
    ),
  );
}
