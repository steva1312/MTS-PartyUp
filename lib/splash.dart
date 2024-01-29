import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');
  final storageRef = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;

  DataSnapshot? rezervacijeSnapshot;
  List<Usluga2> usluge = [];
  Map<String, String> profilePicturesUrls = {};

  //vlasnik
  bool? isOwner;
  Usluga2? vlasnikUsluga;
  String? profilePictureUrl;
  Map<String, String> galerijaUrls = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: primaryColor,
      statusBarColor: primaryColor
    ));

    loadDataAndGoToHome();
  }

  void loadDataAndGoToHome() async {
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
        print('gas' + profilePictureUrl);

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

    
    if (auth.currentUser == null) {
      goToHome();
      return;
    }

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

          goToHome();
        });
      }
      else {
        goToHome();
      }
    });
  }

  void goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Home(
        rezervacijeSnapshot: rezervacijeSnapshot,
        usluge: usluge,
        profilePicturesUrls: profilePicturesUrls,

        isOwner: isOwner,
        vlasnikUsluga: vlasnikUsluga,
        galerijaUrls: galerijaUrls,
        profilePictureUrl: profilePictureUrl,
      ))
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: primaryColor,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(25),
              child: Image.asset('assets/icons/logo.png', width: 100,),
            ),
          ),
        ),
      ),
    );
  }
}