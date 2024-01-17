import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';

class UslugaPage extends StatefulWidget {
  final String id;
  final TipUsluge tipUsluge;

  const UslugaPage({
    super.key, 
    required this.id,
    required this.tipUsluge
  });

  @override
  State<UslugaPage> createState() => _UslugaPageState();
}

class _UslugaPageState extends State<UslugaPage> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();

  Usluga? usluga;
  String? profilePictureUrl;

  @override void initState() {
    super.initState();
    uslugeRef.child(uslugaToString(widget.tipUsluge)).child(widget.id).once().then((event) async {
      String naziv = event.snapshot.child('naziv').value.toString();
      String grad = event.snapshot.child('grad').value.toString();
      String cena = event.snapshot.child('cena').value.toString();

      final url = await storageRef.child('${widget.id}.jpg').getDownloadURL();

      setState(() {
        usluga = Usluga(widget.id, uslugaToString(widget.tipUsluge), naziv, grad, cena);
        profilePictureUrl = url;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          usluga != null ? usluga!.naziv : '',
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
