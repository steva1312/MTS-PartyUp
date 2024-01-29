import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mts_partyup/data.dart';
import 'package:mts_partyup/pages/home.dart';
import 'package:mts_partyup/pages/login.dart';
import 'package:mts_partyup/pages/register_owner.dart';
import 'package:mts_partyup/splash.dart';

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
        'Registruj se',
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
      actions: [
        IconButton(
            onPressed: () {
              if (_isOwner) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterOwner(
                      email: _emailController.text,
                      password: _passwordController.text,
                      brojTelefona: _brojTelefonaController.text,
                    ), // replace with your home page
                  ),
                );
              } else {
                _register(
                    _emailController.text, _passwordController.text);
              }
            },
            icon: const Icon(
              CupertinoIcons.checkmark_alt,
              color: Colors.black,
            )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: _body(context),
      // body: ListView(
      //   padding: const EdgeInsets.all(16.0),
      //   children: [
      //     Form(
      //       key: _formKey,
      //       child: Column(
      //         children: <Widget>[
      //           TextFormField(
      //             controller: _nameController,
      //             decoration: const InputDecoration(labelText: 'Ime'),
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Unesite ime';
      //               }
      //               return null;
      //             },
      //           ),
      //           TextFormField(
      //             controller: _surnameController,
      //             decoration: const InputDecoration(labelText: 'Prezime'),
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Unesite prezime';
      //               }
      //               return null;
      //             },
      //           ),
      //           TextFormField(
      //             controller: _brojTelefonaController,
      //             decoration: const InputDecoration(labelText: 'Broj telefona'),
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Unesite broj telefona';
      //               }
      //               return null;
      //             },
      //           ),
      //           TextFormField(
      //             controller: _emailController,
      //             decoration: const InputDecoration(labelText: 'Email'),
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Unesite email';
      //               }
      //               return null;
      //             },
      //           ),
      //           TextFormField(
      //             controller: _passwordController,
      //             decoration: const InputDecoration(labelText: 'Sifra'),
      //             obscureText: true,
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Unesite sifru';
      //               }
      //               if (value.length < 6) {
      //                 return 'Sifra mora imati najmanje 6 karaktera';
      //               }
      //               return null;
      //             },
      //           ),
      //           TextFormField(
      //             controller: _confirmPasswordController,
      //             decoration: const InputDecoration(labelText: 'Potvrdi sifru'),
      //             obscureText: true,
      //             validator: (value) {
      //               if (value == null || value.isEmpty) {
      //                 return 'Potvrdite sifru';
      //               }
      //               if (_passwordController.text !=
      //                   _confirmPasswordController.text) {
      //                 return 'Sifre se ne poklapaju';
      //               }
      //               return null;
      //             },
      //           ),
      //           CheckboxListTile(
      //             title: const Text('Da li ste pružalac usluga?'),
      //             value: _isOwner,
      //             onChanged: (newValue) {
      //               setState(() {
      //                 _isOwner = newValue ?? false;
      //               });
      //             },
      //             controlAffinity:
      //                 ListTileControlAffinity.leading, //  <-- leading Checkbox
      //           ),
      //           ElevatedButton(
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //               Navigator.of(context).push(
      //                 MaterialPageRoute(
      //                     builder: (context) =>
      //                         const Login()), // replace with your login page
      //               );
      //             },
      //             child: const Text('Već imaš nalog? Prijavi se!'),
      //           ),
      //           ElevatedButton(
      //             onPressed: () {
      //               if (_formKey.currentState?.validate() ?? false) {
      //                 if (_isOwner) {
      //                   Navigator.of(context).push(
      //                     MaterialPageRoute(
      //                       builder: (context) => RegisterOwner(
      //                         email: _emailController.text,
      //                         password: _passwordController.text,
      //                         brojTelefona: _brojTelefonaController.text,
      //                       ), // replace with your home page
      //                     ),
      //                   );
      //                 } else {
      //                   _register(
      //                       _emailController.text, _passwordController.text);
      //                 }
      //               }
      //             },
      //             child: const Text('Register'),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
      child: ListView(
        children: [
          _text('Email'),
          const SizedBox(height: 5),
          _textFormField(_emailController, 'Email'),
          const SizedBox(height: 30),
          _text('Sifra'),
          const SizedBox(height: 5),
          _textFormField(_passwordController, 'Password'),
          const SizedBox(height: 30),
          _text('Potvrdi sifru'),
          const SizedBox(height: 5),
          _textFormField(_confirmPasswordController, 'Potvrdi sifru'),
          const SizedBox(height: 30),
          _text('Ime'),
          const SizedBox(height: 5),
          _textFormField(_nameController, 'Ime'),
          const SizedBox(height: 30),
          _text('Prezime'),
          const SizedBox(height: 5),
          _textFormField(_surnameController, 'Prezime'),
          const SizedBox(height: 30),
          _text('Broj telefona'),
          const SizedBox(height: 5),
          _textFormField(_brojTelefonaController, 'Broj telefona'),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text(
                'Da li ste pružalac usluga?',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)
            ),
            value: _isOwner,
            onChanged: (newValue) {
              setState(() {
                _isOwner = newValue ?? false;
              });
            },
            controlAffinity:
            ListTileControlAffinity.leading, //  <-- leading Checkbox
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text(
                  'Imate nalog? Prijavite se',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16),
                ),
              ),
            ],
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

  TextFormField _textFormField(TextEditingController controller, String hint,
      {bool expanded = false}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 16),
      maxLines: expanded ? 4 : 1,
      obscureText: controller == _passwordController ||
          controller == _confirmPasswordController,
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

  Future<void> _register(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseDatabase.instance
          .ref('Korisnici')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'Ime': _nameController.text,
        'Prezime': _surnameController.text,
        'Email': _emailController.text,
        'BrojTelefona': _brojTelefonaController.text,
      });
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const Splash()), // replace with your home page
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
