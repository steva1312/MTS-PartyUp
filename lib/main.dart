import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/firebase_options.dart';
import 'package:mts_partyup/real_time_database.dart';

Future<void> main() async {
  // Connets your flutter project with firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RealTimeDatabase(),
    );
  }
}
