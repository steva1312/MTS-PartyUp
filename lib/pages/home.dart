import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/add_objekat.dart';
import 'package:mts_partyup/pages/bookmark.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/nalog.dart';
import 'package:mts_partyup/pages/rezervacije_korisnik.dart';
import 'package:mts_partyup/pages/rezervacije_vlasnik.dart';
import 'package:mts_partyup/pages/usluga.dart';
import 'package:mts_partyup/pages/usluge2.dart';
import 'package:mts_partyup/pages/vlasnik_izmeni_profil.dart';
import 'package:mts_partyup/splash.dart';

class Home extends StatefulWidget {
  final DataSnapshot? rezervacijeSnapshot;
  final List<Usluga2> usluge;
  final Map<String, String> profilePicturesUrls;

  bool? isOwner;
  final Usluga2? vlasnikUsluga;
  String? profilePictureUrl;
  final Map<String, String> galerijaUrls;

  Home(
      {super.key,
      required this.rezervacijeSnapshot,
      required this.usluge,
      required this.profilePictureUrl,
      required this.isOwner,
      required this.vlasnikUsluga,
      required this.profilePicturesUrls,
      required this.galerijaUrls});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final auth = FirebaseAuth.instance;

  List<bool> pocetakAnimacije = List.filled(6, false);

  @override
  void initState() {
    super.initState();
    print(widget.isOwner);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: Colors.white,
        statusBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark));

    _animations();
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
    double topCenter = widget.isOwner == true ? sh * 0.50 : sh * 0.33;

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
            child: Container(
              color: primaryColor,
              height: 100,
            ),
          ),
          Positioned(
            top: sh * 0.05,
            height: widget.isOwner == true ? sh * 0.55 : sh * 0.15,
            width: sw,
            child: ClipPath(
              clipper: Wave(),
              child: Container(color: Colors.white),
            ),
          ),

          if (widget.isOwner == true)
            Positioned(
              top: 5,
              width: sw,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => UslugaPage(
                                isOwner: widget.isOwner,
                                profilePictureUrl: widget.profilePictureUrl!,
                                usluga: widget.vlasnikUsluga!,
                              )));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    icon: const Icon(
                      Icons.remove_red_eye,
                      size: 18,
                    ),
                    label: const Text('Pregledaj profil',
                        style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => VlasnikIzmeniProfil(
                                usluga: widget.vlasnikUsluga!,
                                profilePictureUrl: widget.profilePictureUrl!,
                                galerijaSlike: widget.galerijaUrls,
                              )));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                    ),
                    label: const Text('Uredi profil',
                        style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        if (widget.isOwner == true) {
                          return RezervacijeVlasnik(
                              usluga: widget.vlasnikUsluga);
                        } else {
                          return const RezervacijeKorisnik();
                        }
                      }));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    icon: const Icon(
                      Icons.calendar_month,
                      size: 18,
                    ),
                    label: const Text('Rezervacije',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          if (widget.isOwner == false)
            Positioned(
                top: 5,
                width: sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          if (widget.isOwner == true) {
                            return RezervacijeVlasnik(
                                usluga: widget.vlasnikUsluga);
                          } else {
                            return const RezervacijeKorisnik();
                          }
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      icon: const Icon(
                        Icons.calendar_month,
                        size: 18,
                      ),
                      label: const Text('Rezervacije',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                )),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Usluge2(
                          tipUsluge: TipUsluge.prostori,
                          usluge: widget.usluge,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          isOwner: widget.isOwner,
                        )));
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Usluge2(
                          tipUsluge: TipUsluge.muzika,
                          usluge: widget.usluge,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          isOwner: widget.isOwner,
                        )));
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Usluge2(
                          tipUsluge: TipUsluge.fotografi,
                          usluge: widget.usluge,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          isOwner: widget.isOwner,
                        )));
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Usluge2(
                          tipUsluge: TipUsluge.torte,
                          usluge: widget.usluge,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          isOwner: widget.isOwner,
                        )));
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Usluge2(
                          tipUsluge: TipUsluge.ketering,
                          usluge: widget.usluge,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          isOwner: widget.isOwner,
                        )));
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Usluge2(
                          tipUsluge: TipUsluge.dekoracije,
                          usluge: widget.usluge,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          isOwner: widget.isOwner,
                        )));
              },
              child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: ikonicaColor),
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
          onPressed: () async {
            if (FirebaseAuth.instance.currentUser == null) {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Login()));
            } else {
              await FirebaseAuth.instance.signOut();
              setState(() {
                widget.isOwner = false;
              });
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Splash()));
            }
          },
          icon: widget.isOwner != null
              ? const Icon(
                  Icons.logout,
                  color: Colors.black,
                )
              : const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
        ),
        actions: [
          if (widget.isOwner != true)
            IconButton(
              onPressed: () {
                // if (widget.isOwner == false) {
                //   Navigator.of(context).push(
                //       MaterialPageRoute(
                //           builder: (context) => RezervacijeVlasnik(usluga: widget.vlasnikUsluga!,)
                //       )
                //   );
                // } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Bookmark(
                          isOwner: widget.isOwner,
                          profilePicturesUrls: widget.profilePicturesUrls,
                          usluge: widget.usluge,
                        )));
              },
              icon: const Icon(
                Icons.bookmark,
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
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.5 - 100,
        size.width, size.height * 0.5);
    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
