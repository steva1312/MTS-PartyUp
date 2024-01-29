import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/usluga.dart';

class Usluge2 extends StatefulWidget {
  final TipUsluge tipUsluge;
  final List<Usluga2> usluge;
  final Map<String, String> profilePicturesUrls;
  final bool? isOwner;

  const Usluge2({
    super.key, 
    required this.tipUsluge,
    required this.usluge,
    required this.profilePicturesUrls,
    required this.isOwner
  });

  @override
  State<Usluge2> createState() => _Usluge2State();
}

class _Usluge2State extends State<Usluge2> {
  bool? isOwner;

  String text = 'Usluge';

  List<Usluga2> filtriraneUsluge = [];

  @override
  void initState() {
    super.initState();
    filterUsluge();
    setIsOwner();
  }

  void filterUsluge() {
    for (Usluga2 usluga in widget.usluge) {
      if (usluga.tipUsluge == widget.tipUsluge) {
        setState(() {
          filtriraneUsluge.add(usluga);
        });
      }
    }
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
        children: filtriraneUsluge.map((u) => 
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
                        profilePictureUrl: widget.profilePicturesUrls[u.id]!,
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

                if (widget.usluge.indexOf(u) != widget.usluge.length - 1)
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
