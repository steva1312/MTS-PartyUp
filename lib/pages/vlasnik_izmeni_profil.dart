import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';

class VlasnikIzmeniProfil extends StatefulWidget {
  final Usluga usluga;
  final String profilePictureUrl;

  const VlasnikIzmeniProfil({
    super.key,
    required this.usluga,
    required this.profilePictureUrl
  });

  @override
  State<VlasnikIzmeniProfil> createState() => _VlasnikIzmeniProfilState();
}

class _VlasnikIzmeniProfilState extends State<VlasnikIzmeniProfil> {
  final uslugeRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();

  File? newProfilePicture;

  final nazivController = TextEditingController();
  final gradController = TextEditingController();
  final cenaController = TextEditingController();

  @override void initState() {
    super.initState();

    nazivController.text = widget.usluga.naziv;
    gradController.text = widget.usluga.grad;
    cenaController.text = widget.usluga.cena;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          onPressed: () {
            Navigator.pop(context);
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
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
      child: ListView(
        children: [
          _text('Profilna slika'),
          const SizedBox(height: 5,),

          _profilePictureWidget(),
          const SizedBox(height: 30,),

          _text('Naziv usluge'),
          const SizedBox(height: 5,),
          
          _textFormField(nazivController),
          const SizedBox(height: 30,),
          
          _text('Grad'),
          const SizedBox(height: 5,),
          
          _textFormField(gradController),
          const SizedBox(height: 30,),

          _text('Cena'),
          const SizedBox(height: 5,),
          
          _textFormField(cenaController),
          const SizedBox(height: 30,),
        ],
      ),
    );
  }

   _text(String text) {
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

  TextFormField _textFormField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontSize: 16
      ),
      cursorColor: Colors.black,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        filled: false,
        fillColor: const Color(0xFFededed),
        suffixIcon: const Icon(
          Icons.edit
        ),
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
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Sačuvaj promene'),
          content: const Text('Da li ste sigurni da hoćete da sačuvate promene?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                
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

              child: const Text('Poništi'),
            ),

            ElevatedButton(
              onPressed: () {
                
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

              child: const Text('Sačuvaj'),
            )
          ],
        );
      }
    );
  }
  
  void _save() async {
    if (newProfilePicture != null) {
      await storageRef.child('${widget.usluga.id}.jpg').putFile(newProfilePicture!);
    }

    Usluga noviObjekat = Usluga(widget.usluga.id, widget.usluga.tipUsluge, nazivController.text, gradController.text, cenaController.text);
    await uslugeRef.child(widget.usluga.tipUsluge).child(widget.usluga.id).set(noviObjekat.toJson());
  }
}
