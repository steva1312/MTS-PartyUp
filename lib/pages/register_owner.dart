import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mts_partyup/pages/home.dart';

class RegisterOwner extends StatefulWidget {
  const RegisterOwner({super.key});

  @override


  _RegisterOwnerPageState createState() => _RegisterOwnerPageState();


}

class _RegisterOwnerPageState extends State<RegisterOwner> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String inputTipUsluge = uslugaToString(TipUsluge.values[0]);
  String inputImeGrada = gradovi[0];

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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final user = FirebaseAuth.instance.currentUser;
                      final uid = user!.uid;
                      final name = _nameController.text;
                      final grad = inputImeGrada;
                      FirebaseDatabase.instance.ref('Uslugice').child(inputTipUsluge).child(uid).set({
                        'Ime': name,
                        'Grad': grad,
                      });

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
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
}