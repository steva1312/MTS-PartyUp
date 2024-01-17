import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/usluga.dart';

class Usluge extends StatefulWidget {
  final TipUsluge tipUsluge;

  const Usluge({
    super.key, 
    required this.tipUsluge
  });

  @override
  State<Usluge> createState() => _UslugeState();
}

class _UslugeState extends State<Usluge> {
  final objekitRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();

  String text = 'Usluge';
  List<Usluga> usluge = [];
  Map<String, String> profilePicturesUrls = {};  

  @override
  void initState() {
    super.initState();
    getDataFromDB();
  }

  void getDataFromDB() {
    objekitRef.child(uslugaToString(widget.tipUsluge)).once().then((event) async {
      setState(() {
        text = event.snapshot.value.toString();
      });

      List<Usluga> ucitaneUsluge = [];
      
      for(DataSnapshot uslugaSnapshot in event.snapshot.children) {
        String id = uslugaSnapshot.child('id').value.toString();
        String naziv = uslugaSnapshot.child('naziv').value.toString();
        String grad = uslugaSnapshot.child('grad').value.toString();
        String cena = uslugaSnapshot.child('cena').value.toString();
        
        Usluga u = Usluga(id, uslugaToString(widget.tipUsluge), naziv, grad, cena);
        ucitaneUsluge.add(u);

        final profilePictureUrl = await storageRef.child('$id.jpg').getDownloadURL();

        setState(() {
          profilePicturesUrls[id] = profilePictureUrl;
        });
      }

      setState(() {
        for(Usluga u in ucitaneUsluge) {
          usluge.add(u);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: body(context),
    );
  }

  AppBar appBar(BuildContext context) {
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

      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xffF7F8F8),
              borderRadius: BorderRadius.circular(10)
            ),
          child: Image.asset(
            'assets/icons/back.png',
            height: 20,
          ),
        )
      ),
    );
  }

  Widget body(BuildContext context) {
    return ListView(
      children: usluge.map((u) => 
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,

            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => UslugaPage(id: u.id, tipUsluge: widget.tipUsluge))
              );
            },
            
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          u.naziv,
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
              
                Text(
                  u.cena,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                ),
              ],
            ),
          ),
        )
      ).toList(),
    );
  }
}
