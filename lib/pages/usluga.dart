import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';

class UslugaPage extends StatefulWidget {
  final Usluga2 usluga;
  final String profilePictureUrl;
  final TipUsluge tipUsluge;

  const UslugaPage({
    super.key, 
    required this.tipUsluge,
    required this.usluga,
    required this.profilePictureUrl
  });

  @override
  State<UslugaPage> createState() => _UslugaPageState();
}

class _UslugaPageState extends State<UslugaPage> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.usluga.ime,
          style: const TextStyle(
              color: Colors.black, fontWeight: 
              FontWeight.bold, 
              fontSize: 20
            ),
        ),
        elevation: 0.0,

        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xffF7F8F8),
                borderRadius: BorderRadius.circular(10)
              ),
            child: Image.asset(
              'assets/icons/back.png',
              height: 20,
            ),
          )
        ),
      ),
    );
  }
}
