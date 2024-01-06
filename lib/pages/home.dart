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
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const Nalog())
          );
        },
        icon: const Icon(
          Icons.person,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Bookmark())
            );
          },
          icon: const Icon(
            Icons.bookmark,
            color: Colors.black,
          ),
        ),
      ]
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
