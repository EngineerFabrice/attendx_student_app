import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (will implement later)
  // await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: AttendXApp(),
    ),
  );
}