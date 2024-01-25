import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:mts_partyup/pages/vlasnik_izmeni_profil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluga');
  final storageRef = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;
  
  //promenljive ako je vlasnik logovan
  bool? isOwner;
  Usluga2? vlasnikUsluga;
  String? profilePictureUrl;
  List<String> galerijaUrls = [];

  TipUsluge tu = TipUsluge.prostori;

  @override
  void initState() {
    super.initState();
    checkIfOwnerAndLoadUsluga();
  }

  void checkIfOwnerAndLoadUsluga() async {
    if (auth.currentUser == null) return;

    final event = await FirebaseDatabase.instance
        .ref('Korisnici')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once(DatabaseEventType.value);
    
    setState(() {
      isOwner = !event.snapshot.exists;

      if (isOwner == true) {
        loadUslugaForOwner();
      }
    });
  }

  void loadUslugaForOwner() {
    uslugeRef.child(uslugaToString(tu)).child(auth.currentUser!.uid).once().then((event) async {
        String url = await storageRef.child('${auth.currentUser!.uid}.jpg').getDownloadURL();

        List<String> loadedGalerijaUrls = [];

        await storageRef.child(auth.currentUser!.uid).listAll().then((value) async {
          for (var item in value.items) {
            String galerijaUrl = await item.getDownloadURL();
            loadedGalerijaUrls.add(galerijaUrl);
          }
        });
        
        setState(() {
          profilePictureUrl = url;

          for (String g in loadedGalerijaUrls) {
            galerijaUrls.add(g);
          }
          
          vlasnikUsluga = Usluga2.fromSnapshot(event.snapshot);
        });
    });
  }

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
      child: Column(
        children: [
          if (vlasnikUsluga != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute( 
                    builder: (context) => VlasnikIzmeniProfil(
                      usluga: vlasnikUsluga!, 
                      profilePictureUrl: profilePictureUrl!,
                      galerijaUrls: galerijaUrls,
                    )
                  )
                );
              }, 

              child: const Text('Izmeni profil')
            ),

          Center(
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
        ],
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
