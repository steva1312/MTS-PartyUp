import 'dart:ffi';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mts_partyup/data.dart';
import 'package:flutter/material.dart';

class Rezervacije extends StatefulWidget {
  final String tipUsluge;

  const Rezervacije({super.key, required this.tipUsluge});

  @override
  _RezervacijePageState createState() => _RezervacijePageState();
}

class _RezervacijePageState extends State<Rezervacije> {
  List<Rezervacija> rezervacije = [];
  String text = 'Rezervacije';

  @override
  void initState() {
    super.initState();
    getDataFromDB();
  }
  void getDataFromDB() {
    FirebaseDatabase.instance.ref('Usluga')
        .child(widget.tipUsluge)
        .once()
        .then((event) async {
      setState(() {
        text = event.snapshot.value.toString();
      });

      List<Rezervacija> ucitaneRezervacije = [];

      for (DataSnapshot rezervacijaSnapshot in event.snapshot.children) {
        Rezervacija r = Rezervacija(rezervacijaSnapshot);
        ucitaneRezervacije.add(r);



        setState(() {
          for (Rezervacija r in ucitaneRezervacije) {
            rezervacije.add(r);
          }
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
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


  Widget _body(BuildContext context) {
    return ListView(
      children: rezervacije
          .map((r) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Rezervacija'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Ime i prezime: ${r.imePrezime}'),
                          Text('Datum: ${r.datum}'),
                          Text('Vreme: ${r.vreme}'),
                          Text('Broj telefona: ${r.brojTelefona}'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        child: const Text('Prihvati'),
                        onPressed: () {
                          r.status = 2 as Int;
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        child: const Text('Odbij'),
                        onPressed: () {
                          r.status = 3 as Int;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                }
            );
          },
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.imePrezime,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(r.brojTelefona,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 15)),
                ],
              ),
            ],
          ),
        ),
      ))
          .toList(),
    );
  }
}
