import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/add_objekat.dart';
import 'package:mts_partyup/pages/bookmark.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/nalog.dart';
import 'package:mts_partyup/pages/usluge.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'PartyUp',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            if (FirebaseAuth.instance.currentUser == null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Login()));
            } else {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Nalog()));
            }
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
                  MaterialPageRoute(builder: (context) => const Bookmark()));
            },
            icon: const Icon(
              Icons.bookmark,
              color: Colors.black,
            ),
          ),
        ]);
  }

  Widget body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TipUsluge.values.map((o) => baton(context, o)).toList(),
      ),
    );
  }

  ElevatedButton baton(BuildContext context, TipUsluge tipUsluge) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(fixedSize: const Size.fromWidth(150)),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Usluge(tipUsluge: tipUsluge)));
        },
        child: Text(uslugaToString(tipUsluge)));
  }
}
