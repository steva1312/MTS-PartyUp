import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mts_partyup/data.dart';

final formKey = GlobalKey<FormState>();

class AddObjekat extends StatefulWidget {
  const AddObjekat({super.key});

  @override
  State<AddObjekat> createState() => _AddObjekatState();
}

class _AddObjekatState extends State<AddObjekat> {
  final objektiDbRef = FirebaseDatabase.instance.ref('Objekti');

  String inputTipObjekta = objekatToString(TipObjekta.values[0]);
  String inputNaziv = '';
  String inputOkurg = '';
  String inputGrad = '';
  int inputCena = 0;

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
        'Dodaj objekat',
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
        child: Column(
          children: [
            DropdownButtonFormField(
              items: TipObjekta.values.map((o) => DropdownMenuItem(
                value: objekatToString(o),
                child: Text(objekatToString(o)),
              )).toList(),
        
              value: inputTipObjekta,
        
              onChanged: (String? newValue) {
                setState(() {
                  inputTipObjekta = newValue!;
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

            TextFormField(
              decoration: const InputDecoration(labelText: 'Grad'),
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
                  inputGrad = newValue;
                });
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
                  inputCena = int.parse(newValue);
                });
              },
            ),
                
            const SizedBox(height: 20,),
            
            ElevatedButton(
              onPressed: () async {
                if(formKey.currentState!.validate()) {
                  Objekat noviObjekat = Objekat(inputTipObjekta, inputNaziv, inputGrad, inputCena);
                  await objektiDbRef.child(inputTipObjekta).child(noviObjekat.id).set(noviObjekat.toJson().toString());
                }
              }, 
              child: const Text('Dodaj')
            )
          ],
        ),
      ),
    );
  }
}
