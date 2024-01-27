import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mts_partyup/data.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mts_partyup/pages/home.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/register_owner.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override


  _RegisterPageState createState() => _RegisterPageState();


}

class _RegisterPageState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _brojTelefonaController = TextEditingController();
  bool _isOwner = false;

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      title: const Text(
        'Register',
        style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
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
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Prezime'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite prezime';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Sifra'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite sifru';
                    }
                    if (value.length < 6) {
                      return 'Sifra mora imati najmanje 6 karaktera';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Potvrdi sifru'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Potvrdite sifru';
                    }
                    if (_passwordController.text != _confirmPasswordController.text) {
                      return 'Sifre se ne poklapaju';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _brojTelefonaController,
                  decoration: const InputDecoration(labelText: 'Broj telefona'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Unesite broj telefona';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  title: const Text('Da li ste pružalac usluga?'),
                  value: _isOwner,
                  onChanged: (newValue) {
                    setState(() {
                      _isOwner = newValue ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Login()), // replace with your login page
                    );
                  },
                  child: const Text('Već imaš nalog? Prijavi se!'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      if(_isOwner) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => RegisterOwner(email: _emailController.text, password: _passwordController.text,), // replace with your home page
                          ),
                        );
                      }
                      else {
                        _register(_emailController.text, _passwordController.text);
                      }
                    }
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseDatabase.instance.ref('Korisnici').child(
          FirebaseAuth.instance.currentUser!.uid).set({
          'Ime': _nameController.text,
          'Prezime': _surnameController.text,
          'Email': _emailController.text,
          'BrojTelefona': _brojTelefonaController.text,
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
