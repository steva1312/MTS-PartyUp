import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RealTimeDatabase extends StatefulWidget {
  const RealTimeDatabase({super.key});

  @override
  State<RealTimeDatabase> createState() => _RealTimeDatabaseState();
}

class _RealTimeDatabaseState extends State<RealTimeDatabase> {
  final dbRef = FirebaseDatabase.instance.ref('ACAB');

  @override
  Widget build(BuildContext context) {
    dbRef.set('1312');

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('MTS PartyUp'),
      ),
    );
  }
}
