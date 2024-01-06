import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';

class Objekti extends StatefulWidget {
  final TipUsluge tipObjekta;

  const Objekti({
    super.key, 
    required this.tipObjekta
  });

  @override
  State<Objekti> createState() => _ObjektiState();
}

class _ObjektiState extends State<Objekti> {
  final objekitRef = FirebaseDatabase.instance.ref('Objekti');

  String text = 'Objekti';

  @override
  void initState() {
    super.initState();
    getDataFromDB();
  }

  void getDataFromDB() {
    objekitRef.child(uslugaToString(widget.tipObjekta)).once().then((event) {
      setState(() {
        text = event.snapshot.value.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Text(text),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        uslugaToString(widget.tipObjekta),
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
    );
  }
}
