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
  
  //promenljive ako je vlasnik logovan
  bool? isOwner;
  Usluga2? vlasnikUsluga;
  String? profilePictureUrl;
  Map<String, String> galerijaUrls = {};

  List<bool> pocetakAnimacije = List.filled(6, false);

  DataSnapshot? rezervacijeSnapshot;
  List<Usluga2> usluge = [];
  Map<String, String> profilePicturesUrls = {};

  @override
  void initState() {
    super.initState();

    _animations();

    loadFromDB();
  }

  void _animations() async {
    for (int i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: 1000 + i * 200)).then((value) {
        setState(() {
          pocetakAnimacije[i] = true;
        });
      });
      
    }
  }

  void loadFromDB() async {
    await rezervacijeRef.once().then((event) async {
      setState(() {
        rezervacijeSnapshot = event.snapshot;
      });
    });

    await uslugeRef.once().then((event) async {
        List<Usluga2> ucitaneUsluge = [];

      for(DataSnapshot uslugaSnapshot in event.snapshot.children) {
        Usluga2 u = Usluga2.fromSnapshot(uslugaSnapshot, rezervacijeSnapshot!);
        ucitaneUsluge.add(u);

        final profilePictureUrl = await storageRef.child('${u.id}.jpg').getDownloadURL();

        setState(() {
          profilePicturesUrls[u.id] = profilePictureUrl;
        });
      }

      setState(() {
        for(Usluga2 u in ucitaneUsluge) {
          usluge.add(u);
        }
      });
    });

    
    if (auth.currentUser == null) return;

    final event = await uslugeRef
        .child(auth.currentUser!.uid)
        .once(DatabaseEventType.value);
    
    setState(() {
      isOwner = event.snapshot.exists;

      if (isOwner == true) {
        uslugeRef.child(auth.currentUser!.uid).once().then((event) async {
          Map<String, String> loadedGalerijaUrls = {};

          await storageRef.child(auth.currentUser!.uid).listAll().then((value) async {
            for (var item in value.items) {
              String galerijaUrl = await item.getDownloadURL();
              loadedGalerijaUrls[item.name] = galerijaUrl;
            }
          });
          
          setState(() {
            galerijaUrls = Map.fromEntries(
              loadedGalerijaUrls.entries.toList()..sort((a, b) {
                return int.parse(a.key).compareTo(int.parse(b.key));
              })
            );

            profilePictureUrl = profilePicturesUrls[auth.currentUser!.uid];

            vlasnikUsluga = usluge.where((u) => u.id == auth.currentUser!.uid).first;
          });
        });
      }
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

    Color ikonicaColor = Colors.white;
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
            top: sh * 0.06,
            height: sh,
            width: sw,
            child: Container(color: primaryColor, height: 100,),
          ),
          Positioned(
            top: sh * 0.05,
            height: sh * 0.25,
            width: sw,
            child: ClipPath(
              clipper: Wave(),
              child: Container(color: Colors.white),
            ),
          ),

          Positioned(
            top: 0,
            child: ElevatedButton(onPressed: () {
              Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>
                         VlasnikIzmeniProfil(usluga: vlasnikUsluga!, profilePictureUrl: profilePictureUrl!, galerijaSlike: galerijaUrls)));

            }, child: Text('Uredi')),
          ),

          //center
          AnimatedPositioned(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 700),
            top: topCenter,
            left: sw * 0.5 - w * 0.5,
            width: pocetakAnimacije[0] ? w : 0,
            height: pocetakAnimacije[0] ? w : 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                      Usluge2(
                        tipUsluge: TipUsluge.prostori,
                        usluge: usluge,
                        profilePicturesUrls: profilePicturesUrls,
                        isOwner: isOwner,
                      )));
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
          AnimatedPositioned(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 700),
            top: topCenter - w * 0.95,
            left: sw * 0.5 - w * 0.5 - w * 0.65,
            width: pocetakAnimacije[1] ? w : 0,
            height: pocetakAnimacije[1] ? w : 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    Usluge2(
                        tipUsluge: TipUsluge.muzika,
                        usluge: usluge,
                        profilePicturesUrls: profilePicturesUrls,
                        isOwner: isOwner,
                      )));
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
          AnimatedPositioned(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 700),
            top: topCenter - w * 0.95,
            left: sw * 0.5 - w * 0.5 + w * 0.65,
            width: pocetakAnimacije[2] ? w : 0,
            height: pocetakAnimacije[2] ? w : 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    Usluge2(
                        tipUsluge: TipUsluge.fotografi,
                        usluge: usluge,
                        profilePicturesUrls: profilePicturesUrls,
                        isOwner: isOwner,
                      )));
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
          AnimatedPositioned(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 700),
            top: topCenter + w * 0.3,
            left: sw * 0.5 - w * 0.5 - w - w * 0.1,
            width: pocetakAnimacije[5] ? w : 0,
            height: pocetakAnimacije[5] ? w : 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    Usluge2(
                        tipUsluge: TipUsluge.torte,
                        usluge: usluge,
                        profilePicturesUrls: profilePicturesUrls,
                        isOwner: isOwner,
                      )));
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
          AnimatedPositioned(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 700),
            top: topCenter + w * 0.3,
            left: sw * 0.5 - w * 0.5 + w + w * 0.1,
            width: pocetakAnimacije[3] ? w : 0,
            height: pocetakAnimacije[3] ? w : 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    Usluge2(
                        tipUsluge: TipUsluge.ketering,
                        usluge: usluge,
                        profilePicturesUrls: profilePicturesUrls,
                        isOwner: isOwner,
                      )));
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
          AnimatedPositioned(
            curve: Curves.fastEaseInToSlowEaseOut,
            duration: const Duration(milliseconds: 700),
            top: topCenter + w + w * 0.1,
            left: sw * 0.5 - w * 0.5,
            width: pocetakAnimacije[4] ? w : 0,
            height: pocetakAnimacije[4] ? w : 0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>
                    Usluge2(
                        tipUsluge: TipUsluge.dekoracije,
                        usluge: usluge,
                        profilePicturesUrls: profilePicturesUrls,
                        isOwner: isOwner,
                      )));
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
              isOwner == true ? Icons.next_plan_outlined : Icons.bookmark,
              color: Colors.black,
            ),
          ),
        ]);
  }
}




class Wave extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5 - 100, size.width, size.height * 0.5);
    path.lineTo(size.width, 0);
    
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}