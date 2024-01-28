import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');
  DataSnapshot? rezervacijeSnapshot;
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
    rezervacijeRef.once().then((event) {
      setState(() {
        rezervacijeSnapshot = event.snapshot;
      });
    });

    uslugeRef.once().then((event) async {

      List<Usluga2> ucitaneUsluge = [];

      for(DataSnapshot uslugaSnapshot in event.snapshot.children) {
        if (uslugaSnapshot.child('TipUsluge').value.toString() != uslugaToString(widget.tipUsluge)) continue;

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
            fontSize: 22
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
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView(
        children: usluge.map((u) => 
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                GestureDetector(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FadeInImage.assetNetwork(
                          image: profilePicturesUrls[u.id]!,
                          placeholder: 'assets/icons/lokal.png',
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 200),
                          fadeOutDuration: const Duration(milliseconds: 200),
                          fadeInCurve: Curves.easeIn,
                          fadeOutCurve: Curves.easeOut,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      
                      const SizedBox(width: 20,),
                      
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
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.map_pin,
                                size: 15,
                              ),
                              Text(
                                u.grad,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15
                                ),
                              ),
                            ],
                          ),
                      
                          const SizedBox(height: 7),
                      
                          if (u.prosecnaOcena != 0)
                            Row(
                              children: [
                                Row(
                                  children: List.filled(
                                    u.prosecnaOcena.round(), 
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow[600],
                                      size: 25,
                                    )
                                  ),
                                ),
                      
                                const SizedBox(width: 5,),
                      
                                const Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                      
                                const SizedBox(width: 2,),
                      
                                Text(
                                  u.ocene.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                                  'Neocenjeno',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15,),

                if (usluge.indexOf(u) != usluge.length - 1)
                  Divider(
                    color: Colors.grey[200],
                  ),

                const SizedBox(height: 15,),
              ],
            ),
          )
        ).toList(),
      ),
    );
  }
}
