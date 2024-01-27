import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/usluga.dart';

class Usluge2 extends StatefulWidget {
  final TipUsluge tipUsluge;

  const Usluge2({
    super.key, 
    required this.tipUsluge
  });

  @override
  State<Usluge2> createState() => _Usluge2State();
}

class _Usluge2State extends State<Usluge2> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();
  bool? isOwner;

  String text = 'Usluge';
  List<Usluga2> usluge = [];
  Map<String, String> profilePicturesUrls = {};

  @override
  void initState() {
    super.initState();
    getDataFromDB();
    setIsOwner();
  }

  void getDataFromDB() {
    uslugeRef.once().then((event) async {

      List<Usluga2> ucitaneUsluge = [];

      for(DataSnapshot uslugaSnapshot in event.snapshot.children) {
        if (uslugaSnapshot.child('TipUsluge').value.toString() != uslugaToString(widget.tipUsluge)) continue;

        Usluga2 u = Usluga2.fromSnapshot(uslugaSnapshot);
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
      backgroundColor: Colors.white,
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text(
        uslugaToString(widget.tipUsluge),
        style: const TextStyle(
            color: Colors.black, fontWeight:
            FontWeight.bold,
            fontSize: 20
          ),
      ),
      elevation: 0.0,

      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.black,
        )
      ),
    );
  }

  Widget _body(BuildContext context) {
    return ListView(
      children: usluge.map((u) => 
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,

            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => UslugaPage(
                  usluga: u, 
                  profilePictureUrl: profilePicturesUrls[u.id]!,
                  isOwner: isOwner,
                ))
              );
            },
            
            child: Row(
              children: [
                FadeInImage.assetNetwork(
                  image: profilePicturesUrls[u.id]!,
                  placeholder: 'assets/icons/lokal.png',
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 200),
                  fadeInCurve: Curves.easeIn,
                  fadeOutCurve: Curves.easeOut,
                  width: 75,
                  height: 75,
                ),

                const SizedBox(width: 10,),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.ime,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                      )
                    ),
                    Text(
                      u.grad,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15
                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
      ).toList(),
    );
  }
}
