import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mts_partyup/pages/rezervacije_korisnik.dart';
import 'package:mts_partyup/pages/vlasnik.dart';

class Nalog extends StatefulWidget {
  const Nalog({super.key});

  @override
  _NalogPageState createState() => _NalogPageState();
}

class _NalogPageState extends State<Nalog> {
  final _formKey = GlobalKey<FormState>();
  bool? isOwner;

  @override
  void initState() {
    super.initState();
    setIsOwner();  
  }

  void setIsOwner() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    
    final event = await FirebaseDatabase.instance
        .ref('Korisnici')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once(DatabaseEventType.value);
    
    setState(() {
      isOwner = !event.snapshot.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Nalog',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16.0), children: [
        Form(
            key: _formKey,
            child: Column(
              children: [
                if(isOwner == null)
                  const Text('Ucitavanje...')
                else if (isOwner == true)
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const Vlasnik()
                            )
                        );
                      },
                      child: const Text('Uredi profil')
                  )
                else 
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const RezervacijeKorisnik()
                            )
                        );
                      },
                      child: const Text('Rezervacije')
                  )
              ],
            ))
      ]),
    );
  }
}
