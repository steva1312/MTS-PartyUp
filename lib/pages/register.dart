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
  bool _isOwner = false;

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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your surname';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirm Password'),
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => Login()), // replace with your login page
                    );
                  },
                  child: const Text('Already have an account'),
                ),
                CheckboxListTile(
                  title: const Text('Are you an owner?'),
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
                    if (_formKey.currentState?.validate() ?? false) {
                      _register(_emailController.text, _passwordController.text);
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
      if(_isOwner && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RegisterOwner(), // replace with your home page
        ),
        );
      }
      else {
        FirebaseDatabase.instance.ref('Korisnici').child(
            FirebaseAuth.instance.currentUser!.uid).set({
          'Ime': _nameController.text,
          'Prezime': _surnameController.text,
          'Email': _emailController.text,

        });
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (
                context) => const Home()), // replace with your home page
          );
        }
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
