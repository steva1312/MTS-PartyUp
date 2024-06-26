import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mts_partyup/data.dart';

class VlasnikIzmeniProfil extends StatefulWidget {
  final Usluga2 usluga;
  String profilePictureUrl;
  final Map<String, String> galerijaSlike;

  VlasnikIzmeniProfil({
    super.key,
    required this.usluga,
    required this.profilePictureUrl,
    required this.galerijaSlike,
  });

  @override
  State<VlasnikIzmeniProfil> createState() => _VlasnikIzmeniProfilState();
}

class _VlasnikIzmeniProfilState extends State<VlasnikIzmeniProfil> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;

  File? newProfilePicture;

  final _imeController = TextEditingController();
  final _gradController = TextEditingController();
  final _opisController = TextEditingController();
  final _ytController = TextEditingController();

  Map<String, String> galerijaSlike = {};
  List<File> noveGalerijaSlike = [];

  String? selectedGalerijaImg;
  File? selectedFileImg;
  List<String> obrisaneSlike = [];

  int lastGalerijaImgId = 0;

  bool savedAndExit = false;

  @override void initState() {
    super.initState();

    setState(() {
      widget.galerijaSlike.forEach((key, value) { 
        galerijaSlike[key] = value;
      });

      if (widget.galerijaSlike.isNotEmpty) {
        lastGalerijaImgId = int.parse(widget.galerijaSlike.entries.last.key);
        print(lastGalerijaImgId);
      }
    });

    _imeController.text = widget.usluga.ime;
    _gradController.text = widget.usluga.grad;
    _opisController.text = widget.usluga.opis;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showCancelDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Izmeni profil',
            style: TextStyle(
                color: Colors.black, fontWeight: 
                FontWeight.bold, 
                fontSize: 20
              ),
          ),
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(
              Icons.close_outlined, 
              size: 33,
            ),
            onPressed: () async {
              final t = await _showCancelDialog(); 
              if (t) Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                _showSaveDialog();
              },
              icon: const Icon(
                CupertinoIcons.checkmark_alt,
                size: 33,
              ),
            ),
          ]
        ),
        body: _body(context),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      child: ListView(
        children: [
          _text('Profilna slika'),
          const SizedBox(height: 5,),

          _profilePictureWidget(),
          const SizedBox(height: 30,),

          _text('Naziv usluge'),
          const SizedBox(height: 5,),
          
          _textFormField(_imeController),
          const SizedBox(height: 30,),
          
          _text('Grad'),
          const SizedBox(height: 5,),
          
          _textFormField(_gradController),
          const SizedBox(height: 30,),

          _text('Opis'),
          const SizedBox(height: 5,),
          
          _textFormField(_opisController, expanded: true),
          const SizedBox(height: 30,),

          if (widget.usluga.tipUsluge == TipUsluge.muzika)
          ...[
              _text('Promo video'),
            const SizedBox(height: 5,),
            
            _promoVideo(),
            const SizedBox(height: 30,),
          ],

          _text('Galerija'),
          const SizedBox(height: 5,),
          
          _galerija(),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }

  Widget _text(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black, 
        fontWeight: FontWeight.bold, 
        fontSize: 16
      ),
    );
  }

  Widget _profilePictureWidget () {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),

      child: Container(
        color: const Color(0xFFededed),

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: newProfilePicture == null ? 
                  Image(
                    image:  NetworkImage(widget.profilePictureUrl),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ) :
                  Image(
                    image:  FileImage(newProfilePicture!),
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
              ),
                
              ElevatedButton.icon(
                onPressed: () async {
                  final pickedImage = await pickImageFromGalleryAndCrop();
                  
                  if (pickedImage != null) {
                    setState(() {
                      newProfilePicture = pickedImage;
                    });
                  }
                }, 

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10)
                    )
                  )
                ),
                icon: const Icon(
                  CupertinoIcons.photo,
                ),
                label: const Text('Promeni'),
              )
            ]
          ),
        ),
      ),
    );
  }

  TextFormField _textFormField(TextEditingController controller, { bool expanded = false }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 16
      ),
      maxLines: expanded ? 4 : 1,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        filled: false,
        fillColor: const Color(0xFFededed),
        suffixIcon: const Icon(Icons.edit),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color:  Color(0xFFededed),
            width: 1
          )
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.black,
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
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text('Sačuvaj promene'),
          content: const Text('Da li ste sigurni da hoćete da sačuvate promene?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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

              child: const Text('Poništi'),
            ),

            ElevatedButton(
              onPressed: () {
                _save();
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

              child: const Text('Sačuvaj'),
            )
          ],
        );
      }
    );
  }

  Future<bool> _showCancelDialog() async {
    final t = await showDialog<bool>(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text('Odbaci promene'),
          content: const Text('Da li ste sigurni da hoćete da odbacite promene?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, false);
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

              child: const Text('Poništi'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
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

              child: const Text('Odbaci'),
            )
          ],
        );
      }
    );

    return t!;
  }
  
  void _save() async {
    if (newProfilePicture != null) {
      await storageRef.child('${widget.usluga.id}.jpg').putFile(newProfilePicture!);

      String url = await storageRef.child('${widget.usluga.id}.jpg').getDownloadURL();

      setState(() {
        widget.profilePictureUrl = url;
      });
    }

    for (File img in noveGalerijaSlike) {
      String newImgId = (lastGalerijaImgId + 1).toString();
      await storageRef.child(auth.currentUser!.uid).child(newImgId).putFile(img);

      String url = await storageRef.child(auth.currentUser!.uid).child(newImgId).getDownloadURL();

      setState(() {
        widget.galerijaSlike[newImgId] = url;

        lastGalerijaImgId++;
      });
    }

    for (String idObrisaneSlike in obrisaneSlike) {
      await storageRef.child(auth.currentUser!.uid).child(idObrisaneSlike).delete();

      setState(() {
        widget.galerijaSlike.remove(idObrisaneSlike);
      });
    }

    //TODO
    DatabaseReference valsnikUslugaRef =  uslugeRef.child(widget.usluga.id);
    await valsnikUslugaRef.child('Ime').set(_imeController.text);
    await valsnikUslugaRef.child('Grad').set(_gradController.text);
    await valsnikUslugaRef.child('Opis').set(_opisController.text);

    if (widget.usluga.tipUsluge == TipUsluge.muzika) {
      valsnikUslugaRef.child('YtLink').set(_ytController.text);
    }

    setState(() {
      widget.usluga.ime = _imeController.text;
      widget.usluga.grad = _gradController.text;
      widget.usluga.opis = _opisController.text;

      savedAndExit = true;
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _promoVideo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unesite link videa sa YouTube-a.'),
        _textFormField(_ytController)
      ],
    );
  }

  Widget _galerija() {
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: [
        

        ...galerijaSlike.entries.map((slika) {
          String idSlike = slika.key;
          String url = slika.value;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedGalerijaImg = idSlike;
                selectedFileImg = null;
              });
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                  ),

                  if (selectedGalerijaImg == idSlike)
                    Container(
                      color: const Color.fromARGB(212, 163, 156, 156),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedGalerijaImg = null;
                                galerijaSlike.remove(idSlike);
                                obrisaneSlike.add(idSlike);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder()
                            ),
                            child: const Icon(
                              CupertinoIcons.trash,
                              color: Color.fromARGB(255, 179, 26, 15),
                            ),
                          ),
                        ),
                      ),
                    )
                ]
              ) 
            ),
          );
        }),

        ...noveGalerijaSlike.map((slika) => 
          GestureDetector(
            onTap: () {
              setState(() {
                selectedGalerijaImg = null;
                selectedFileImg = slika;
              });
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    slika,
                    fit: BoxFit.cover,
                  ),

                  if (selectedFileImg == slika)
                    Container(
                      color: const Color.fromARGB(212, 163, 156, 156),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFileImg = null;
                                noveGalerijaSlike.remove(slika);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder()
                            ),
                            child: const Icon(
                              CupertinoIcons.trash,
                              color: Color.fromARGB(255, 179, 26, 15),
                            ),
                          ),
                        ),
                      ),
                    )
                ]
              ) 
            ),
          )
        ),

        ElevatedButton(
          onPressed: () async {
            final pickedFile = await pickImageFromGalleryAndCrop();
        
            if (pickedFile != null) {
              setState(() {
                noveGalerijaSlike.add(pickedFile);
              });
            }
          },
          
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 238, 238, 238),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8)
            )
          ),
        
          child: const Icon(CupertinoIcons.add, size: 40),
        )
      ]
    );
  }
}
