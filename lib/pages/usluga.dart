import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';

class UslugaPage extends StatefulWidget {
  final Usluga2 usluga;
  final String profilePictureUrl;
  final TipUsluge tipUsluge;
  final bool? isOwner;

  const UslugaPage({
    super.key, 
    required this.tipUsluge,
    required this.usluga,
    required this.profilePictureUrl,
    required this.isOwner
  });

  @override
  State<UslugaPage> createState() => _UslugaPageState();
}

class _UslugaPageState extends State<UslugaPage> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluga');
  final korisniciRef = FirebaseDatabase.instance.ref('Korisnici');

  bool showZvezdiceError = false;
  final _komentarController = TextEditingController();

  int ocenaKorisnika = 0;

  @override
  void initState() {
    super.initState();
    _setImePrezime();  
  }

  void _setImePrezime() async {
    for (Ocena ocena in widget.usluga.ocene) {
      await ocena.postaviImePrezime(korisniciRef);
    }

    setState(() {
      String id = FirebaseAuth.instance.currentUser!.uid;

      int index = widget.usluga.ocene.indexWhere((o) => o.idKorisnika == id);

      if (index != -1) {
        Ocena o = widget.usluga.ocene[index];
        widget.usluga.ocene.removeAt(index);
        widget.usluga.ocene.insert(0, o);
      }
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
        widget.usluga.ime,
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
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _uslugaInfo(),
                
              const SizedBox(height: 60,),
          
              _writeReview(),

              const SizedBox(height: 45,),

              _ocene(),
            ],
          ),
        ),
      ]
    );
  }

  Widget _uslugaInfo() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          
          child: FadeInImage.assetNetwork(
            image: widget.profilePictureUrl,
            placeholder: 'assets/icons/lokal.png',
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 200),
            fadeInCurve: Curves.easeIn,
            fadeOutCurve: Curves.easeOut,
            width: 150,
            height: 150,
          ),
        ),
          
        const SizedBox(height: 5,),
    
        Text(
          widget.usluga.grad,
          style: const TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 18
          ),
        ),
          
        const SizedBox(height: 20,),
    
        Text(
          widget.usluga.opis,
          style: const TextStyle(
            color: Colors.black, 
            fontSize: 16
          ),
        ),
      ],
    );
  }

  Widget _writeReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ocenite uslugu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22
          ),  
        ),

        const SizedBox(height: 10,),

        if (widget.isOwner == null) 
          const Text('Prijavite se da biste mogli da ocenite uslugu')
        else if (widget.isOwner == true)
          const Text('Nije moguće ocenjivanje ukoliko ste vlasnik neke usluge')
        else if (widget.usluga.ocene.any((o) => o.idKorisnika == FirebaseAuth.instance.currentUser!.uid))
          const Text('Veće ste ocenili ovu uslugu')
        else ...[

          _zvezdice(),

          if (showZvezdiceError)
            const Text(
              'Izaberite ocenu',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
                fontStyle: FontStyle.italic
              ),  
            ),

          const SizedBox(height: 10,),

          const Row(
            children: [
              Text(
                'Komentar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15
                ),  
              ),

              SizedBox(width: 5,),

              Text(
                '*nije obavezno',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic
                ),  
              ),
            ],
          ),

          const SizedBox(height: 5,),

          TextFormField(
            controller: _komentarController,
            style: const TextStyle(
              fontSize: 14
            ),
            maxLines: 4,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(15),
              filled: false,
              fillColor: const Color(0xFFededed),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color:  Color(0xFFededed),
                  width: 1
                )
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color:  Colors.black,
                  width: 2
                )
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color:  Color(0xFFededed),
                  width: 2
                )
              ),
            ),
          ),

          const SizedBox(height: 15,),

          ElevatedButton(
            onPressed: () async {
              if (ocenaKorisnika == 0) {
                setState(() {
                  showZvezdiceError = true;
                });

                return;
              }

              Ocena ocenaObjekat = Ocena(FirebaseAuth.instance.currentUser!.uid, ocenaKorisnika, _komentarController.text);

              await uslugeRef.child(uslugaToString(widget.tipUsluge)).child(widget.usluga.id).child('Ocene')
                .child(FirebaseAuth.instance.currentUser!.uid).set(ocenaObjekat.toJson());

              await ocenaObjekat.postaviImePrezime(korisniciRef);

              setState(() {
                widget.usluga.ocene.insert(0, ocenaObjekat);
                showZvezdiceError = false;
                ocenaKorisnika = 0;
              });
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFededed),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10)
                )
              )
            ),

            child: const Text('Objavi')
          ),
        ]
      ],
    );
  }

  Widget _zvezdice() {
    return Row(
      children: List.generate(5, (index) =>
        GestureDetector(
          onTap: () {
            setState(() {
              ocenaKorisnika = index + 1;
            });
          },

          child: Icon(
            ocenaKorisnika < index + 1 ? Icons.star_border : Icons.star,
            color: Colors.yellow[600],
            size: 40,
          ),
        )
        
      ).toList(),
    );
  }

  Widget _zvezdiceOcena(int ocena) {
    return Row(
      children: List.generate(5, (index) =>
        Icon(
          ocena < index + 1 ? Icons.star_border : Icons.star,
          color: Colors.yellow[600],
          size: 25,
        )
      ).toList(),
    );
  }

  Widget _ocene() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ocene',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22
          ),  
        ),
        
        const SizedBox(height: 15,),

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.usluga.ocene
            .where((o) => o.imePrezime != null)
            .map((o) => _ocena(o))
            .toList(),
        ),
      ],
    );
  }

  Widget _ocena(Ocena ocena) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ocena.imePrezime!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                  ),  
                ),
                
                _zvezdiceOcena(ocena.ocena),
              ],
            ),

            if (ocena.idKorisnika == FirebaseAuth.instance.currentUser!.uid)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: GestureDetector(
                  onTap: () async {
                    await uslugeRef.child(uslugaToString(widget.tipUsluge)).child(widget.usluga.id).child('Ocene')
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .remove();

                    setState(() {
                      widget.usluga.ocene.removeAt(0);
                    });
                  },
                
                  child: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 5,),

        if (ocena.komentar != '')
          Text(
            ocena.komentar,
            style: const TextStyle(
              fontSize: 14
            ),  
          ),

        const SizedBox(height: 20,),
      ],
    );
  }
}
