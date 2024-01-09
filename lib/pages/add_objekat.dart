import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mts_partyup/data.dart';
import 'package:uuid/uuid.dart';

final formKey = GlobalKey<FormState>();

class AddObjekat extends StatefulWidget {
  const AddObjekat({super.key});

  @override
  State<AddObjekat> createState() => _AddObjekatState();
}

class _AddObjekatState extends State<AddObjekat> {
  final objektiDbRef = FirebaseDatabase.instance.ref('Usluge');
  final storageRef = FirebaseStorage.instance.ref();

  String inputTipUsluge = uslugaToString(TipUsluge.values[0]);
  String inputNaziv = '';
  String inputOkurg = '';
  String inputGrad = '';
  String inputCena = '';

  File? pickedProfilePicture;

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
      title: const Text(
        'Dodaj uslugu',
        style: TextStyle(
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
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
        child: ListView(
          children: [Column(
            children: [
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
          
              const SizedBox(height: 20,),
          
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ime objekta'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Ovo polje je obavezno';
                  }
                  else {
                    return null;
                  }
                },
                onChanged: (newValue) {
                  setState(() {
                    inputNaziv = newValue;
                  });
                },
              ),
                  
              const SizedBox(height: 20,),

              Autocomplete(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return gradovi.where((String grad) => 
                    grad.toLowerCase().contains(textEditingValue.text.toLowerCase())
                  );
                },
              ),
                  
              const SizedBox(height: 20,),
          
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cena'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Ovo polje je obavezno';
                  }
                  else {
                    return null;
                  }
                },
                onChanged: (newValue) {
                  setState(() {
                    inputCena = newValue;
                  });
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
                  if(formKey.currentState!.validate()) {
                    String id = const Uuid().v4();

                    Usluga noviObjekat = Usluga(id, inputTipUsluge, inputNaziv, inputGrad, inputCena);
                    await objektiDbRef.child(inputTipUsluge).child(id).set(noviObjekat.toJson());

                    await storageRef.child('$id.${pickedProfilePicture!.path.split('.').last}').putFile(pickedProfilePicture!);
                  }
                }, 
                child: const Text('Dodaj')
              )
            ],
          ),]
        ),
      ),
    );
  }
}
