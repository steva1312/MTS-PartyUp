import 'dart:io';
import 'package:mts_partyup/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mts_partyup/pages/home.dart';
import 'package:uuid/uuid.dart';


class RegisterOwner extends StatefulWidget {
  final String email;
  final String password;

  const RegisterOwner({
    super.key,
    required this.email,
    required this.password,
  });

  @override


  _RegisterOwnerPageState createState() => _RegisterOwnerPageState();


}

class _RegisterOwnerPageState extends State<RegisterOwner> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String inputTipUsluge = uslugaToString(TipUsluge.values[0]);
  String inputImeGrada = gradovi[0];
  File? pickedProfilePicture;
  final storageRef = FirebaseStorage.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                DropdownButtonFormField(
                    items: TipUsluge.values.map((o) => DropdownMenuItem(
                      value: uslugaToString(o),
                      child: Text(uslugaToString(o)),
                    )).toList(),

                    value: inputTipUsluge,

                    onChanged: (String? newValue) {
                      setState(() {
                        inputTipUsluge = newValue!;
                      });
                    }
                ),
                DropdownButtonFormField(
                    items: gradovi.map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o),
                    )).toList(),

                    value: inputImeGrada,

                    onChanged: (String? newValue) {
                      setState(() {
                        inputImeGrada = newValue!;
                      });
                    }
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Ime'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite ime';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Opis'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite opis';
                    }
                    return null;
                  },
                ),



                const SizedBox(height: 20,),

                ElevatedButton(
                    onPressed: () async {
                      final pickedImage = await pickImageFromGalleryAndCrop();

                      setState(() {
                        pickedProfilePicture = pickedImage;
                      });
                    },
                    child: const Text('Izaberi sliku')
                ),

                const SizedBox(height: 20,),

                if (pickedProfilePicture != null) Image.file(pickedProfilePicture!),

                const SizedBox(height: 20,),




                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _register(widget.email, widget.password);
                    }
                  },
                  child: const Text('Register'),
                )
              ]
            )
          )
        ]
      )
    );
  }

  Future<void> _register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String id = FirebaseAuth.instance.currentUser!.uid;

      await storageRef.child('$id.jpg').putFile(pickedProfilePicture!);

      FirebaseDatabase.instance.ref('Usluga').child(inputTipUsluge).child(
          FirebaseAuth.instance.currentUser!.uid).set({
        'Ime': _nameController.text,
        'Grad': inputImeGrada,
        'Email': email,
        'Description': _descriptionController.text,
      });

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (
              context) => const Home()), // replace with your home page
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}