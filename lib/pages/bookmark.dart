import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/usluga.dart';

class Bookmark extends StatefulWidget {
  final bool? isOwner;
  final List<Usluga2> usluge;
  final Map<String, String> profilePicturesUrls;

  const Bookmark({
    super.key,
    required this.isOwner,
    required this.usluge,
    required this.profilePicturesUrls
  });

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  final korisniciRef = FirebaseDatabase.instance.ref('Korisnici');
  List<Usluga2> usluge = [];

 @override
  void initState() {
    super.initState();
    if (widget.isOwner == false) filterSaved();
  }

  void filterSaved() {
    korisniciRef.child(FirebaseAuth.instance.currentUser!.uid).child('Saved').once().then((event) {
      List<Usluga2> temp = [];

      for(DataSnapshot idSacuvanog in event.snapshot.children) {
          temp.add(
            widget.usluge.firstWhere((u) => u.id == idSacuvanog.key.toString())
          );
      }

      setState(() {
        for (Usluga2 u in temp) {
          usluge.add(u);
        }
      });
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
      title: const Text(
        'Sačuvano',
        style: TextStyle(
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
    if (widget.isOwner == null) {
      return Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            const Text('Ulogujte se da biste mogli da sačuvate usluge.'),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const Login()
                    )
                );
              }, 

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10)
                  )
                )
              ),

              child: const Text('Uloguj se'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ListView(
        children: TipUsluge.values.map((tipUsluge) {
          if (usluge.where((u) => u.tipUsluge == tipUsluge).isEmpty) {
            return const SizedBox(height: 0,);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tipUsluge != TipUsluge.prostori)
              const SizedBox(height: 30,),
                
              Text(uslugaToString(tipUsluge), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              const SizedBox(height: 10,),
              Column(
                children: usluge.where((u) => u.tipUsluge == tipUsluge).map((u) => 
                  Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                            
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => UslugaPage(
                              usluga: u, 
                              profilePictureUrl: widget.profilePicturesUrls[u.id]!,
                              isOwner: widget.isOwner,
                            ))
                          );
                        },
                        
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FadeInImage.assetNetwork(
                                image: widget.profilePicturesUrls[u.id]!,
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
                                  ] 
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
                                            )),
                                      ),
                  
                                      const SizedBox(
                                        width: 5,
                                      ),
                  
                                      const Icon(
                                        Icons.person,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
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
                                          fontStyle: FontStyle.italic),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ).toList(),
              )
            ],
          );}
        ).toList(),
        
      ),
    );
  }
}

