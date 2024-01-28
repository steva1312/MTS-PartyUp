import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class UslugaPage extends StatefulWidget {
  final Usluga2 usluga;
  final String profilePictureUrl;
  final bool? isOwner;

  const UslugaPage(
      {super.key,
      required this.usluga,
      required this.profilePictureUrl,
      required this.isOwner});

  @override
  State<UslugaPage> createState() => _UslugaPageState();
}

class _UslugaPageState extends State<UslugaPage> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final korisniciRef = FirebaseDatabase.instance.ref('Korisnici');
  final storageRef = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;
  final rezervacijeRef = FirebaseDatabase.instance.ref('Rezervacije');

  final _imePrezimeController = TextEditingController();
  final _brojTelefonaController = TextEditingController();
  final _datumController = TextEditingController();
  final _vremeController = TextEditingController();
  final _opisController = TextEditingController();

  bool showZvezdiceError = false;
  final _komentarController = TextEditingController();

  int ocenaKorisnika = 0;
  bool saved = false;

  int activeIndex = 0;
  final galerijaController = CarouselController();
  List<String> urlImages = [];

  late YoutubePlayerController _ytController;

  void loadGalerija() async {
    List<String> loadedGalerijaUrls = [];

    await storageRef.child(widget.usluga.id).listAll().then((value) async {

      List<Reference> newItems = value.items.toList();
      newItems.sort((item1, item2) => int.parse(item1.name).compareTo(int.parse(item2.name)));

      for (var item in newItems) {
        String galerijaUrl = await item.getDownloadURL();
        loadedGalerijaUrls.add(galerijaUrl);
      }
    });

    setState(() {
      for (String urlSavedSlike in loadedGalerijaUrls) {
        urlImages.add(urlSavedSlike);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.usluga.tipUsluge == TipUsluge.muzika) {
      _ytController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(widget.usluga.ytLink)!,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
        )
      );
    }

    _setImePrezime();
    loadGalerija();
    CheckIfSaved();
  }

  void CheckIfSaved() {
    korisniciRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('Saved')
        .once()
        .then((event) async {
      for (DataSnapshot savedElement in event.snapshot.children) {
        print(savedElement.key);
        print(widget.usluga.id);
        if (savedElement.key == widget.usluga.id) {
          setState(() {
            saved = true;
          });
          break;
        }
      }
    });
  }

  void _setImePrezime() async {
    for (Ocena ocena in widget.usluga.ocene) {
      await ocena.postaviImePrezime(korisniciRef);
    }

    setState(() {
      if (auth.currentUser == null) return;

      String id = auth.currentUser!.uid;

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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0.0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            )),
        actions: [
          if (widget.isOwner == false)
            IconButton(
              onPressed: () async {
                if (!saved) {
                  await korisniciRef
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .child('Saved')
                      .child(widget.usluga.id)
                      .set('');
                } else {
                  await korisniciRef
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .child('Saved')
                      .child(widget.usluga.id)
                      .remove();
                }

                setState(() {
                  saved = !saved;
                });
              },
              icon: Icon(
                saved ? Icons.bookmark : Icons.bookmark_add_outlined,
                color: Colors.black,
              ),
            )
        ]);
  }

  Widget _body(BuildContext context) {
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _uslugaInfo(),

            const SizedBox(height: 60,),

            if (widget.usluga.tipUsluge == TipUsluge.muzika)
            ...[
              _ytVideo(),
              const SizedBox(height: 45,),
            ],
            

            galerijaSlajder(),

            const SizedBox(height: 45,),

            _writeReview(),
            
            const SizedBox(height: 45,),

            _ocene(),
          ],
        ),
      ),
    ]);
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
        const SizedBox(
          height: 5,
        ),
        Text(
          widget.usluga.grad,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          widget.usluga.opis,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        ElevatedButton(
            onPressed: () {
              if (FirebaseAuth.instance.currentUser == null) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Rezervacija'),
                        content: const Text(
                            'Morate biti prijavljeni da biste mogli da rezervišete uslugu'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ok'))
                        ],
                      );
                    });
                return;
              } else if (widget.isOwner == true) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Rezervacija'),
                        content: const Text(
                            'Nije moguće rezervisati uslugu ukoliko ste vlasnik neke usluge'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Ok'))
                        ],
                      );
                    });
                return;
              } else {
                if (widget.usluga.rezervacije.any((r) {
                  return r.idKorisnika ==
                          FirebaseAuth.instance.currentUser!.uid &&
                      r.idUsluge == widget.usluga.id;
                })) {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text('Rezervacija'),
                          content: const Text(
                              'Već ste rezervisali ovu uslugu. Možete je otkazati u vašem nalogu'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Ok'))
                          ],
                        );
                      });
                  return;
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Rezervacija'),
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                                child: Column(
                              children: <Widget>[
                                TextFormField(
                                  controller: _imePrezimeController,
                                  decoration: const InputDecoration(
                                      labelText: 'Ime i prezime',
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Unesite ime i prezime';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _brojTelefonaController,
                                  decoration: const InputDecoration(
                                      labelText: 'Broj telefona',
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Unesite broj telefona';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _datumController,
                                  decoration: const InputDecoration(
                                      labelText: 'Datum',
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Unesite datum';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _vremeController,
                                  decoration: const InputDecoration(
                                      labelText: 'Vreme',
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Unesite vreme';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _opisController,
                                  decoration: const InputDecoration(
                                      labelText: 'Opis',
                                      border: OutlineInputBorder()),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Unesite opis';
                                    }
                                    return null;
                                  },
                                )
                              ],
                            )),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () async {
                                  final IdRezervacije = rezervacijeRef.push();
                                  IdRezervacije.set({
                                    'IdKorisnika': auth.currentUser!.uid,
                                    'IdUsluge': widget.usluga.id,
                                    'Datum': _datumController.text,
                                    'Vreme': _vremeController.text,
                                    'Opis': _opisController.text,
                                    'Status': 1,
                                  });
                                  await uslugeRef
                                      .child(widget.usluga.id)
                                      .child('Rezervacije')
                                      .child(IdRezervacije.key!)
                                      .set(
                                        '',
                                      );
                                  await korisniciRef
                                      .child(auth.currentUser!.uid)
                                      .child('Rezervacije')
                                      .child(IdRezervacije.key!)
                                      .set(
                                        '',
                                      );
                                  Navigator.of(context).pop();
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Rezervacija'),
                                          content: const Text(
                                              'Uspešno ste rezervisali uslugu'),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Ok'))
                                          ],
                                        );
                                      });
                                },
                                child: const Text('Rezerviši'))
                          ],
                        );
                      });
                }
              }
            },
            child: const Text('Rezerviši'))
      ],
    );
  }

  Widget _ytVideo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promo video',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),

          const SizedBox(height: 5,),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: YoutubePlayer(
              controller: _ytController,
            ),
          )
        ],
      ),
    );
  }
  
  Widget galerijaSlajder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Text(
            'Galerija',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        if (urlImages.isNotEmpty)
          Column(
            children: [
              CarouselSlider.builder(
                carouselController: galerijaController,
                itemCount: urlImages.length,
                itemBuilder: (context, index, realIndex) {
                  final urlImage = urlImages[index];
                  return buildImage(urlImage, index);
                },
                options: CarouselOptions(
                  viewportFraction: 0.9,
                  height: MediaQuery.of(context).size.width * 0.9,
                  autoPlay: true,
                  enableInfiniteScroll: false,
                  autoPlayAnimationDuration: const Duration(seconds: 1),
                  onPageChanged: (index, reason) =>
                      setState(() => activeIndex = index))
              ),

              const SizedBox(height: 12),

              buildIndicator()
            ],
          )
        
        else
          const Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text('Ova usluga nema slika.'),
          )
      ],
    );
  }

  Widget buildImage(String urlImage, int index) =>
      Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: CachedNetworkImage(imageUrl: urlImage),
        ),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        onDotClicked: animateToSlide,
        effect: ExpandingDotsEffect(
          dotHeight: 13,
          dotWidth: 13, 
          activeDotColor: Colors.blue,
          dotColor: Colors.grey[300]!
        ),
        activeIndex: activeIndex,
        count: urlImages.length,
      );

  void animateToSlide(int index) => galerijaController.animateToPage(index);

  Widget _writeReview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ocenite uslugu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 10,
          ),
          if (widget.isOwner == null)
            const Text('Prijavite se da biste mogli da ocenite uslugu.')
          else if (widget.isOwner == true)
            const Text('Nije moguće ocenjivanje ukoliko ste vlasnik neke usluge.')
          else if (widget.usluga.ocene.any(
              (o) => o.idKorisnika == FirebaseAuth.instance.currentUser!.uid))
            const Text('Veće ste ocenili ovu uslugu.')
          else ...[
            _zvezdice(),
            if (showZvezdiceError)
              const Text(
                'Izaberite ocenu',
                style: TextStyle(
                    fontSize: 15, color: Colors.red, fontStyle: FontStyle.italic),
              ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Text(
                  'Komentar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  '*nije obavezno',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            TextFormField(
              controller: _komentarController,
              style: const TextStyle(fontSize: 14),
              maxLines: 4,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                filled: false,
                fillColor: const Color(0xFFededed),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFededed), width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.black, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFededed), width: 2)),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (ocenaKorisnika == 0) {
                    setState(() {
                      showZvezdiceError = true;
                    });
      
                    return;
                  }
      
                  Ocena ocenaObjekat = Ocena(auth.currentUser!.uid,
                      ocenaKorisnika, _komentarController.text);
      
                  await uslugeRef
                      .child(widget.usluga.id)
                      .child('Ocene')
                      .child(auth.currentUser!.uid)
                      .set(ocenaObjekat.toJson());
      
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
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                child: const Text('Objavi')),
          ]
        ],
      ),
    );
  }

  Widget _zvezdice() {
    return Row(
      children: List.generate(
          5,
          (index) => GestureDetector(
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
              )).toList(),
    );
  }

  Widget _zvezdiceOcena(int ocena) {
    return Row(
      children: List.generate(
          5,
          (index) => Icon(
                ocena < index + 1 ? Icons.star_border : Icons.star,
                color: Colors.yellow[600],
                size: 25,
              )).toList(),
    );
  }

  Widget _ocene() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ocene',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(
            height: 5,
          ),

          if (widget.usluga.ocene.isNotEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.usluga.ocene
                  .where((o) => o.imePrezime != null)
                  .map((o) => _ocena(o))
                  .toList(),
            )

          else 
            const Text('Ova usluga je trenutno neocenjena.')
        ],
      ),
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
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                _zvezdiceOcena(ocena.ocena),
              ],
            ),
            if (auth.currentUser != null &&
                ocena.idKorisnika == auth.currentUser!.uid)
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: GestureDetector(
                  onTap: () async {
                    await uslugeRef
                        .child(widget.usluga.id)
                        .child('Ocene')
                        .child(auth.currentUser!.uid)
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
        const SizedBox(
          height: 5,
        ),
        if (ocena.komentar != '')
          Text(
            ocena.komentar,
            style: const TextStyle(fontSize: 14),
          ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
