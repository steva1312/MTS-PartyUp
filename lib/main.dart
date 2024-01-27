import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/firebase_options.dart';
import 'package:mts_partyup/pages/add_objekat.dart';
import 'package:mts_partyup/pages/home.dart';
import 'package:mts_partyup/pages/homeslicke.dart';
import 'package:mts_partyup/pages/kalendar_proba.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/register.dart';
import 'package:mts_partyup/pages/register_owner.dart';
import 'package:mts_partyup/pages/vlasnik.dart';
import 'package:mts_partyup/pages/vlasnik_izmeni_profil.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const Home(),
    );
  }
}
