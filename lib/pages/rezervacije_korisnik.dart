import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mts_partyup/data.dart';
import 'package:flutter/material.dart';

class RezervacijeKorisnik extends StatefulWidget {
  const RezervacijeKorisnik({
    super.key,
  });

  @override
  _RezervacijePageState createState() => _RezervacijePageState();
}

class _RezervacijePageState extends State<RezervacijeKorisnik> {
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');
  final korisniciRef = FirebaseDatabase.instance.ref('Korisnici');
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');

  String text = 'Rezervacije';
  List<String> ime = [];
  List<String> brojTelefona = [];
  List<String> datum = [];
  List<String> vreme = [];
  List<String> opis = [];

  List<Usluga2> usluge = [];
  List<Rezervacija> rezervacije = [];
  DataSnapshot? rezervacijeSnapshot;

  @override
  void initState() {
    super.initState();
    rezervacijeRef.once().then((event) {
      setState(() {
        rezervacijeSnapshot = event.snapshot;
      });
      for (DataSnapshot rezervacijaSnapshot in rezervacijeSnapshot!.children) {
        if (FirebaseAuth.instance.currentUser!.uid !=
            rezervacijaSnapshot.child('IdKorisnika').value.toString()) continue;
        setState(() {
          rezervacije.add(Rezervacija.fromSnapshot(rezervacijaSnapshot));
        });
      }
      for (var i = 0; i < rezervacije.length; i++) {
        uslugeRef.child(rezervacije[i].idUsluge).once().then((event) {
          setState(() {
            usluge.add(
                Usluga2.fromSnapshot(event.snapshot, rezervacijeSnapshot!));
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbar(context),
      body: body(context),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Rezervacije',
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
    );
  }

  Widget body(BuildContext context) {
    return ListView(
        children: usluge.map((u) {
      int i = usluge.indexOf(u);
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (rezervacije[i].status == 1) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      title: const Text('Rezervacija'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Ime: ${u.ime}'),
                            Text('Datum: ${rezervacije[i].datum}'),
                            Text('Vreme: ${rezervacije[i].vreme}'),
                            Text('Broj telefona: ${u.brojTelefona}'),
                            Text('Opis: ${rezervacije[i].opis}'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFededed),
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          child: const Text('Ok'),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.transparent,
                                      title:
                                          const Text('Otkazivanje rezervacije'),
                                      content: const Text(
                                          'Da li ste sigurni da zelite da otkazete rezervaciju?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Ne'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            rezervacijeRef
                                                .child(rezervacije[i].id)
                                                .remove();
                                            korisniciRef
                                                .child(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .child('Rezervacije')
                                                .child(rezervacije[i].id)
                                                .remove();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Da'),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFededed),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            child: const Text('Otkazi rezervaciju')),
                      ],
                    );
                  });
            } else if (rezervacije[i].status == 2) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      title: const Text('Rezervacija'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Text('Ime: ${u.ime}'),
                            Text('Datum: ${rezervacije[i].datum}'),
                            Text('Vreme: ${rezervacije[i].vreme}'),
                            Text('Broj telefona: ${u.brojTelefona}'),
                            Text('Opis: ${rezervacije[i].opis}'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFededed),
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  });
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      title: const Text('Rezervacija'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            const Text('Vasa rezervacija je odbijena'),
                            Text('Razlog: ${rezervacije[i].opis}'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            korisniciRef
                                .child(rezervacije[i].idKorisnika)
                                .child('Rezervacije')
                                .child(rezervacije[i].id)
                                .remove();
                            rezervacijeRef.child(rezervacije[i].id).remove();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFededed),
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.fromLTRB(20, 15, 20, 15),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          child: const Text('Ok'),
                        ),
                      ],
                    );
                  });
            }
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(usluge[i].ime,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(usluge[i].brojTelefona,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList());
  }
}
