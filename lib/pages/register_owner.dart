import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mts_partyup/splash.dart';

class RegisterOwner extends StatefulWidget {
  final String email;
  final String password;
  final String brojTelefona;

  const RegisterOwner({
    super.key,
    required this.email,
    required this.password,
    required this.brojTelefona,
  });

  @override
  _RegisterOwnerPageState createState() => _RegisterOwnerPageState();
}

class _RegisterOwnerPageState extends State<RegisterOwner> {
  File? newProfilePicture;

  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();
  final auth = FirebaseAuth.instance;

  final _imeController = TextEditingController();
  final _opisController = TextEditingController();
  final _adresaController = TextEditingController();
  final _ytController = TextEditingController();

  String inputTipUsluge = uslugaToString(TipUsluge.values[0]);
  String inputImeGrada = gradovi[1];

  Map<String, String> galerijaSlike = {};
  List<File> noveGalerijaSlike = [];

  String? selectedGalerijaImg;
  File? selectedFileImg;
  List<String> obrisaneSlike = [];

  int lastGalerijaImgId = 0;
  File? pickedProfilePicture;


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
              'Registruj uslugu',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
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
            ]),
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
          const SizedBox(
            height: 5,
          ),
          _profilePictureWidget(),
          const SizedBox(
            height: 30,
          ),
          _text('Naziv usluge'),
          const SizedBox(
            height: 5,
          ),
          _textFormField(_imeController, 'Naziv usluge'),
          const SizedBox(
            height: 30,
          ),
          _text('Tip usluge'),
          const SizedBox(
            height: 5,
          ),
          DropdownButtonFormField(
              items: TipUsluge.values
                  .map((o) => DropdownMenuItem(
                        value: uslugaToString(o),
                        child: Text(uslugaToString(o)),
                      ))
                  .toList(),
              value: inputTipUsluge,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFededed), width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFededed), width: 2)),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  inputTipUsluge = newValue!;
                });
              }),
          const SizedBox(
            height: 30,
          ),
          _text('Grad'),
          const SizedBox(
            height: 5,
          ),
          DropdownButtonFormField(
              items: gradovi
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o),
                      ))
                  .toList(),
              value: inputImeGrada,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFededed), width: 1)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor, width: 2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide:
                        const BorderSide(color: Color(0xFFededed), width: 2)),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  inputImeGrada = newValue!;
                });
              }),
          const SizedBox(
            height: 30,
          ),
          _text('Adresa'),
          const SizedBox(
            height: 5,
          ),
          _textFormField(_adresaController, 'Adresa'),
          const SizedBox(
            height: 30,
          ),
          _text('Opis'),
          const SizedBox(
            height: 5,
          ),
          _textFormField(_opisController, 'Opis', expanded: true),
          const SizedBox(
            height: 30,
          ),
          if (stringToUsluga(inputTipUsluge) == TipUsluge.muzika) ...[
            _text('Promo video'),
            const SizedBox(
              height: 5,
            ),
            _promoVideo(),
            const SizedBox(
              height: 30,
            ),
          ],
          _text('Galerija'),
          const SizedBox(
            height: 5,
          ),
          _galerija(),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _text(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _profilePictureWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        color: const Color(0xFFededed),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: newProfilePicture == null
                  ? Image.asset(
                      'assets/icons/lokal.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    )
                  : Image(
                      image: FileImage(newProfilePicture!),
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
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
              icon: const Icon(
                CupertinoIcons.photo,
              ),
              label: const Text('Izaberi'),
            )
          ]),
        ),
      ),
    );
  }

  TextFormField _textFormField(TextEditingController controller, String hint,
      {bool expanded = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      maxLines: expanded ? 4 : 1,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        filled: false,
        fillColor: const Color(0xFFededed),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFededed), width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFededed), width: 2)),
      ),
    );
  }

  void _save() async {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _promoVideo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Unesite link videa sa YouTube-a.'),
        _textFormField(_ytController, 'Link videa')
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
                  child: Stack(fit: StackFit.expand, children: [
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
                                  shape: const CircleBorder()),
                              child: const Icon(
                                CupertinoIcons.trash,
                                color: Color.fromARGB(255, 179, 26, 15),
                              ),
                            ),
                          ),
                        ),
                      )
                  ])),
            );
          }),
          ...noveGalerijaSlike.map((slika) => GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGalerijaImg = null;
                    selectedFileImg = slika;
                  });
                },
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(fit: StackFit.expand, children: [
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
                                    shape: const CircleBorder()),
                                child: const Icon(
                                  CupertinoIcons.trash,
                                  color: Color.fromARGB(255, 179, 26, 15),
                                ),
                              ),
                            ),
                          ),
                        )
                    ])),
              )),
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
                    borderRadius: BorderRadius.circular(8))),
            child: const Icon(CupertinoIcons.add, size: 40),
          )
        ]);
  }

  void _showSaveDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('Registracija'),
            content:
                const Text('Napravi nalog?'),
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
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                child: const Text('Poništi'),
              ),
              ElevatedButton(
                onPressed: () {
                  _register(widget.email, widget.password);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFededed),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                child: const Text('Napravi'),
              )
            ],
          );
        });
  }

  Future<bool> _showCancelDialog() async {
    final t = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('Odbaci promene'),
            content:
                const Text('Da li ste sigurni da hoćete da odbacite promene?'),
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
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
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
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                child: const Text('Odbaci'),
              )
            ],
          );
        });

    return t!;
  }

  Future<void> _register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String id = FirebaseAuth.instance.currentUser!.uid;
      print(id);

      await storageRef.child('$id.jpg').putFile(newProfilePicture!);

      for (File img in noveGalerijaSlike) {
        String newImgId = (lastGalerijaImgId + 1).toString();
        await storageRef
            .child(auth.currentUser!.uid)
            .child(newImgId)
            .putFile(img);
        
        setState(() {
          lastGalerijaImgId++;
        });
      }

      DatabaseReference vlasnikUslugaRef = uslugeRef.child(id);



      vlasnikUslugaRef.set({
        'Ime': _imeController.text,
        'Grad': inputImeGrada,
        'Adresa': _adresaController.text,
        'Opis': _opisController.text,
        'Email': email,
        'TipUsluge': inputTipUsluge,
        'BrojTelefona': widget.brojTelefona,
      });

      if (stringToUsluga(inputTipUsluge) == TipUsluge.muzika) {
        vlasnikUslugaRef.child('YtLink').set(_ytController.text);
      }

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (
              context) => const Splash()), // replace with your home page
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
