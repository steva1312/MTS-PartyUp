import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';

class Nalog extends StatefulWidget {
  const Nalog({super.key});

  @override
  _NalogPageState createState() => _NalogPageState();
}

class _NalogPageState extends State<Nalog> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> isOwner() async {
    final event = await FirebaseDatabase.instance
        .ref('Korisnici')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once(DatabaseEventType.value);
    return !event.snapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Nalog',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16.0), children: [
        Form(
            key: _formKey,
            child: Column(
              children: [
                if(isOwner() is bool)
                  const Text('Usluga')
                else
                  const Text('Korisnik')
              ],
            ))
      ]),
    );
  }
}
