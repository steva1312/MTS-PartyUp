import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/add_objekat.dart';
import 'package:mts_partyup/pages/bookmark.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/nalog.dart';
import 'package:mts_partyup/pages/register.dart';
import 'package:mts_partyup/pages/usluge.dart';
import 'package:mts_partyup/pages/usluge2.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar(context),
      body: body(context),
    );
  }

  Widget body(BuildContext context) {
    Widget bigCircle = Container(
      width: 390.0,
      height: 600.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
      ),
    );
    return Material(
      color: Colors.white,
      child: Center(
        child: Stack(
          children: <Widget>[
            bigCircle,
            Positioned(
              bottom: 250.0,
              left: 145.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Usluge2(tipUsluge: TipUsluge.prostori)));
                    },
                    child: Image.asset(
                      'assets/icons/prostori.png',
                      height: 100,
                    )),
              ),
            ),
            Positioned(
              top: 152.4,
              left: 70.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Usluge2(tipUsluge: TipUsluge.muzika)));
                    },
                    child: Image.asset(
                      'assets/icons/muzika.png',
                      height: 20,
                    )),
              ),
            ),
            Positioned(
              top: 152.4,
              right: 70.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Usluge2(tipUsluge: TipUsluge.fotografi)));
                    },
                    child: Image.asset(
                      'assets/icons/fotografi.png',
                      height: 20,
                    )),
              ),
            ),
            Positioned(
              bottom: 220.0,
              left: 30.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Usluge2(tipUsluge: TipUsluge.torte)));
                    },
                    child: Image.asset(
                      'assets/icons/torte.png',
                      height: 20,
                    )),
              ),
            ),
            Positioned(
              bottom: 220.0,
              right: 10.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Usluge2(tipUsluge: TipUsluge.ketering)));
                    },
                    child: Image.asset(
                      'assets/icons/ketering.png',
                      height: 20,
                    )),
              ),
            ),
            Positioned(
              bottom: 132.0,
              left: 145.0,
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              const Usluge2(tipUsluge: TipUsluge.dekoracije)));
                    },
                    child: Image.asset(
                      'assets/icons/dekoracije.png',
                      height: 20,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

/*Widget body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TipUsluge.values.map((o) => baton(context, o)).toList(),
      ),
    );
  }*/

ElevatedButton baton(BuildContext context, TipUsluge tipUsluge) {
  return ElevatedButton(
      style: ElevatedButton.styleFrom(fixedSize: const Size.fromWidth(150)),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Usluge2(tipUsluge: tipUsluge)));
      },
      child: Text(uslugaToString(tipUsluge)));
}
