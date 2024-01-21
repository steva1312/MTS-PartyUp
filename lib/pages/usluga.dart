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
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
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
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
      
              child: FadeInImage.assetNetwork(
                image: widget.profilePictureUrl,
                placeholder: 'assets/icons/lokal.png',
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 200),
                fadeInCurve: Curves.easeIn,
                fadeOutCurve: Curves.easeOut,
                width: 150,
                height: 150,
              ),
            ),
      
            const SizedBox(height: 5,),
        
            Text(
              widget.usluga.grad,
              style: const TextStyle(
                color: Colors.black, 
                fontWeight: FontWeight.bold, 
                fontSize: 18
              ),
            ),
      
            const SizedBox(height: 20,),
        
            Text(
              widget.usluga.opis,
              style: const TextStyle(
                color: Colors.black, 
                fontSize: 16
              ),
            ),
          ],
        ),
      ),
    );
  }
}
