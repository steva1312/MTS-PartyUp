import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/add_objekat.dart';
import 'package:mts_partyup/pages/bookmark.dart';
import 'package:mts_partyup/pages/nalog.dart';
import 'package:mts_partyup/pages/objekti.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final dbRef = FirebaseDatabase.instance.ref('ACAB');

  @override
  Widget build(BuildContext context) {
    dbRef.set('1312');

    return Scaffold(
      appBar: appBar(context),
      body: body(context),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddObjekat())
          );
        },
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'PartyUp',
        style: TextStyle(
            color: Colors.black, fontWeight: 
            FontWeight.bold, 
            fontSize: 20
          ),
      ),
      elevation: 0.0,

      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Nalog())
          );
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10)
            ),
          child: Image.asset(
            'assets/icons/user.png',
            height: 20,
          ),
        )
      ),

      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Bookmark())
            );
          },
          child: Container(
            width: 37,
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xffF7F8F8),
                borderRadius: BorderRadius.circular(10)
              ),
            child: Image.asset(
              'assets/icons/bookmark.png',
              height: 20,
            ),
          )
        )
      ],
    );
  }

  Widget body(BuildContext context) {
    return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TipUsluge.values.map((o) => baton(context, o)).toList(),
        ),
      );
  }

  ElevatedButton baton(BuildContext context, TipUsluge tipObjekta) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromWidth(150)
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Objekti(tipObjekta: tipObjekta))
        );
      }, 
      child: Text(uslugaToString(tipObjekta))
    );
  }
}
