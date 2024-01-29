import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/bookmark.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/nalog.dart';
import 'package:mts_partyup/pages/rezervacije_vlasnik.dart';
import 'package:mts_partyup/pages/usluge2.dart';
import 'package:mts_partyup/pages/vlasnik_izmeni_profil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');
  final storageRef = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;

  DataSnapshot? rezervacijeSnapshot;
  
  //promenljive ako je vlasnik logovan
  bool? isOwner;
  Usluga2? vlasnikUsluga;
  String? profilePictureUrl;
  Map<String, String> galerijaUrls = {};

  @override
  void initState() {
    super.initState();
    checkIfOwnerAndLoadUsluga();
  }

  void checkIfOwnerAndLoadUsluga() async {
    if (auth.currentUser == null) return;

    final event = await uslugeRef
        .child(auth.currentUser!.uid)
        .once(DatabaseEventType.value);
    
    setState(() {
      isOwner = event.snapshot.exists;

      if (isOwner == true) {
        loadUslugaForOwner();
      }
    });
  }

  void loadUslugaForOwner() async {

    await rezervacijeRef.once().then((event) async {
      setState(() {
        rezervacijeSnapshot = event.snapshot;
      });
    });

    await uslugeRef.child(auth.currentUser!.uid).once().then((event) async {
        String url = await storageRef.child('${auth.currentUser!.uid}.jpg').getDownloadURL();

        Map<String, String> loadedGalerijaUrls = {};

        await storageRef.child(auth.currentUser!.uid).listAll().then((value) async {
          for (var item in value.items) {
            String galerijaUrl = await item.getDownloadURL();
            loadedGalerijaUrls[item.name] = galerijaUrl;
          }
        });

        rezervacijeRef.once().then((event) {
          setState(() {
            rezervacijeSnapshot = event.snapshot;
          });
        });
        
        setState(() {
          profilePictureUrl = url;

          loadedGalerijaUrls.forEach((key, value) { 
            galerijaUrls[key] = value;
          });

          vlasnikUsluga = Usluga2.fromSnapshot(event.snapshot, rezervacijeSnapshot!);
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
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    double w = sw * 0.30;
    double topCenter = sh * 0.35;

    Color ikonicaColor = const Color.fromARGB(255, 221, 221, 221);
    EdgeInsets p = EdgeInsets.all(w * 0.2);

    // if (vlasnikUsluga != null)
    //   ElevatedButton(
    //     onPressed: () {
    //       Navigator.of(context).push(
    //         MaterialPageRoute( 
    //           builder: (context) => VlasnikIzmeniProfil(
    //             usluga: vlasnikUsluga!, 
    //             profilePictureUrl: profilePictureUrl!,
    //             galerijaSlike: galerijaUrls,
    //           )
    //         )
    //       );
    //     }, 

    //     child: const Text('Izmeni profil')
    //   )

    return Material(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            child: ElevatedButton(onPressed: () {
              Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>
                         VlasnikIzmeniProfil(usluga: vlasnikUsluga!, profilePictureUrl: profilePictureUrl!, galerijaSlike: galerijaUrls)));
            }, child: const Text('Uredi')),
          ),

          //center
          Positioned(
            top: topCenter,
            left: sw * 0.5 - w * 0.5,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                      const Usluge2(tipUsluge: TipUsluge.prostori)));
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
                child: Padding(
                  padding: p,
                  child: Image.asset(
                    'assets/icons/prostori.png',
                  ),
                ),
              ),
            ),
          ),
      
          //top left
          Positioned(
            top: topCenter - w * 0.95,
            left: sw * 0.5 - w * 0.5 - w * 0.65,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    const Usluge2(tipUsluge: TipUsluge.muzika)));
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
                child: Padding(
                  padding: p,
                  child: Image.asset(
                    'assets/icons/muzika.png',
                  ),
                ),
              ),
            ),
          ),
      
          //top right
          Positioned(
            top: topCenter - w * 0.95,
            left: sw * 0.5 - w * 0.5 + w * 0.65,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    const Usluge2(tipUsluge: TipUsluge.fotografi)));
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.17),
                  child: Image.asset(
                    'assets/icons/fotografi.png',
                  ),
                ),
              ),
            ),
          ),
      
          //left
          Positioned(
            top: topCenter + w * 0.3,
            left: sw * 0.5 - w * 0.5 - w - w * 0.1,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    const Usluge2(tipUsluge: TipUsluge.torte)));
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.17),
                  child: Image.asset(
                    'assets/icons/torte.png',
                  ),
                ),
              ),
            ),
          ),
      
          //right
          Positioned(
            top: topCenter + w * 0.3,
            left: sw * 0.5 - w * 0.5 + w + w * 0.1,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    const Usluge2(tipUsluge: TipUsluge.ketering)));
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.17),
                  child: Image.asset(
                    'assets/icons/ketering.png',
                  ),
                ),
              ),
            ),
          ),
      
          //bottom
          Positioned(
            top: topCenter + w + w * 0.1,
            left: sw * 0.5 - w * 0.5,
            width: w,
            height: w,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    const Usluge2(tipUsluge: TipUsluge.dekoracije)));
              },
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
                child: Padding(
                  padding: EdgeInsets.all(w * 0.17),
                  child: Image.asset(
                    'assets/icons/dekoracije.png',
                  ),
                ),
              ),
            ),
          )
        ],
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
              if (isOwner!) {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => RezervacijeVlasnik(usluga: vlasnikUsluga!,)
                    )
                );
              } else {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const Bookmark()
                    )
                );

              }
            },
            icon: Icon(
              isOwner == true ? Icons.format_list_bulleted : Icons.bookmark,
              color: Colors.black,
            ),
          ),
        ]);
  }
}

