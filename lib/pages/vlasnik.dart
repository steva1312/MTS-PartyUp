import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/kalendar_proba.dart';
import 'package:mts_partyup/pages/vlasnik_izmeni_profil.dart';

class Vlasnik extends StatefulWidget {
  const Vlasnik({super.key});

  @override
  State<Vlasnik> createState() => _VlasnikState();
}

//  NJESRA FAJL NE DIRAJ

class _VlasnikState extends State<Vlasnik> {
  final String id = 'b7c440bf-61ee-4624-a507-51796c8441c1';
  final String tipUsluge = 'Fotografi';

  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');

  Usluga2? usluga;
  String? profilePictureUrl;
  DataSnapshot? rezervacijeSnapshot;

  Map<String, dynamic> jsonDatumi = {};

  @override void initState() {
    super.initState();
    uslugeRef.child(tipUsluge).child(id).once().then((event) async {
      final url = await storageRef.child('$id.jpg').getDownloadURL();

      rezervacijeRef.once().then((event) {
        setState(() {
          rezervacijeSnapshot = event.snapshot;
        });
      });


      setState(() {
        usluga = Usluga2.fromSnapshot(event.snapshot, rezervacijeSnapshot!);

        profilePictureUrl = url;
        
        for (var datumSnapshot in event.snapshot.child('Zakazano').children) {
          jsonDatumi[datumSnapshot.key!] = '';
        }
      });


    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        // title: Text(
        //   usluga != null ? usluga!.naziv : '',
        //   style: const TextStyle(
        //       color: Colors.black, fontWeight: 
        //       FontWeight.bold, 
        //       fontSize: 20
        //     ),
        // ),
        elevation: 0.0,
      ),

      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => VlasnikIzmeniProfil(usluga: usluga!, profilePictureUrl: profilePictureUrl!, ))
              // );
            },
            child: const Text('Izmeni profil'),
          ),
        ]
      ),
    );
  }
}