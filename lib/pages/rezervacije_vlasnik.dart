import 'package:firebase_database/firebase_database.dart';
import 'package:mts_partyup/data.dart';
import 'package:flutter/material.dart';

class RezervacijeVlasnik extends StatefulWidget {
  final Usluga2? usluga;
  const RezervacijeVlasnik({
    super.key,
    required this.usluga,
  });

  @override
  _RezervacijePageState createState() => _RezervacijePageState();
}

class _RezervacijePageState extends State<RezervacijeVlasnik> {
  List<Rezervacija> rezervacije = [];

  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');
  final korisniciRef = FirebaseDatabase.instance.ref('Korisnici');
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');

  String text = 'Rezervacije';
  List<String> ime = [];
  List<String> prezime = [];
  List<String> brojTelefona = [];
  List<String> datum = [];
  List<String> vreme = [];
  List<String> opis = [];

  final _razlogController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ime = List.filled(widget.usluga!.rezervacije.length, '');
    prezime = List.filled(widget.usluga!.rezervacije.length, '');
    brojTelefona = List.filled(widget.usluga!.rezervacije.length, '');
    getDataFromDB();
    for (var i = 0; i < widget.usluga!.rezervacije.length; i++) {
      korisniciRef
          .child(widget.usluga!.rezervacije[i].idKorisnika)
          .once()
          .then((event) {
        setState(() {
          ime[i] = (event.snapshot.child('Ime').value.toString());
          prezime[i] = (event.snapshot.child('Prezime').value.toString());
          brojTelefona[i] =
              (event.snapshot.child('BrojTelefona').value.toString());
        });
      });
    }
  }

  void getDataFromDB() {
    rezervacijeRef.once().then((event) {
      setState(() {
        for (DataSnapshot rezervacijaSnapshot in event.snapshot.children) {
          if (widget.usluga!.id !=
              rezervacijaSnapshot.child('IdUsluge').value.toString()) continue;
          rezervacije.add(Rezervacija.fromSnapshot(rezervacijaSnapshot));
        }
      });
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
      children: widget.usluga!.rezervacije.map((r) {
        int i = widget.usluga!.rezervacije.indexOf(r);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (r.status == 1) {
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
                              Text('Ime: ${ime[i]}'),
                              Text('Prezime: ${prezime[i]}'),
                              Text('Datum: ${r.datum}'),
                              Text('Vreme: ${r.vreme}'),
                              Text('Broj telefona: ${brojTelefona[i]}'),
                              Text('Opis: ${r.opis}'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFededed),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            child: const Text('Prihvati'),
                            onPressed: () {
                              r.status = 2;
                              rezervacijeRef.child(r.id).child('Status').set(2);
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFededed),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            child: const Text('Odbij'),
                            onPressed: () {
                              r.status = 3;
                              rezervacijeRef.child(r.id).child('Status').set(3);
                              Navigator.of(context).pop();
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
                                          TextFormField(
                                            controller: _razlogController,
                                            decoration: const InputDecoration(
                                                labelText: 'Razlog odbijanja'),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Unesite razlog odbijanja';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFededed),
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 15, 20, 15),
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)))),
                                        onPressed: () {
                                          uslugeRef
                                              .child(r.idUsluge)
                                              .child('Rezervacije')
                                              .child(r.id)
                                              .remove();
                                          uslugeRef
                                              .child(r.idUsluge)
                                              .child('ZauzetDatum')
                                              .child(r.datum)
                                              .remove();
                                          rezervacijeRef
                                              .child(r.id)
                                              .child('Opis')
                                              .set(_razlogController.text);
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
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
                        title: const Text('Rezervacija'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Ime: ${ime[i]}'),
                              Text('Prezime: ${prezime[i]}'),
                              Text('Datum: ${r.datum}'),
                              Text('Vreme: ${r.vreme}'),
                              Text('Broj telefona: ${brojTelefona[i]}'),
                              Text('Opis: ${r.opis}'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFededed),
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.fromLTRB(20, 15, 20, 15),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            child: const Text('Ok'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
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
                    Text('${ime[i]} ${prezime[i]}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Text(brojTelefona[i],
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
