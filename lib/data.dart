import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum TipUsluge {
  prostori,
  muzika,
  fotografi,
  torte,
  ketering,
  dekoracije
}

String uslugaToString(TipUsluge tipObjekta) {
  switch(tipObjekta) {
    case TipUsluge.prostori:
      return 'Prostori';
    case TipUsluge.muzika:
      return 'Muzika';
    case TipUsluge.fotografi:
      return 'Fotografi';
    case TipUsluge.torte:
      return 'Torte';
    case TipUsluge.ketering:
      return 'Ketering';
    case TipUsluge.dekoracije:
      return 'Dekoracije';
  }
}

TipUsluge stringToUsluga(String tipObjekta) {
  switch(tipObjekta) {
    case 'Prostori':
      return TipUsluge.prostori;
    case 'Muzika':
      return TipUsluge.muzika;
    case 'Fotografi':
      return TipUsluge.fotografi;
    case 'Torte':
      return TipUsluge.torte;
    case 'Ketering':
      return TipUsluge.ketering;
    case 'Dekoracije':
      return TipUsluge.dekoracije;
  }

  return TipUsluge.prostori; //mora difolt neki da ne javlja gresku
}

String engToSrbMonthConverter(String day) {
  switch(day) {
    case 'Jan':
      return 'Januar';
    case 'Feb':
      return 'Februar';
    case 'Mar':
      return 'Mart';
    case 'Apr':
      return 'April';
    case 'May':
      return 'Maj';
    case 'Jun':
      return 'Jun';
    case 'Jul':
      return 'Jul';
    case 'Aug':
      return 'Avgust';
    case 'Sep':
      return 'Septembar';
    case 'Oct':
      return 'Oktobar';
    case 'Nov':
      return 'Novembar';
    case 'Dec':
      return 'Decembar';
  }

  return 'Greska';
}

String engToSrbDayConverter(String day) {
  switch(day) {
    case 'Mon':
      return 'Pon';
    case 'Tue':
      return 'Uto';
    case 'Wed':
      return 'Sre';
    case 'Thu':
      return 'Čet';
    case 'Fri':
      return 'Pet';
    case 'Sat':
      return 'Sub';
    case 'Sun':
      return 'Ned';
  }

  return 'Greska';
}

class Usluga {
  String id = '';
  String tipUsluge = '';
  String naziv = '';
  String grad = '';
  String cena = '';

  Usluga(this.id, this.tipUsluge, this.naziv, this.grad, this.cena);

  Map<String, dynamic> toJson() => {
    "id": id,
    "naziv": naziv,
    "grad": grad,
    "cena": cena
  };
}

class Usluga2 {
  String id = '';
  String ime= '';
  String grad = '';
  String opis = '';

  Usluga2(DataSnapshot snapshot) {
    id = snapshot.key!;
    ime = snapshot.child('Ime').value.toString();
    grad = snapshot.child('Grad').value.toString();
    opis = snapshot.child('Description').value.toString();
  }

  Map<String, dynamic> toJson() => {
    "Ime": ime,
    "Grad": grad,
    "Description": opis,
  };
}

Future<File?> pickImageFromGallery() async {
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  if(pickedImage == null) return null;

  return File(pickedImage.path);
}

Future<File?> pickImageFromGalleryAndCrop() async {
  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

  if(pickedImage == null) return null;

  final croppedImage = await ImageCropper().cropImage(
    sourcePath: pickedImage.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    aspectRatioPresets: [CropAspectRatioPreset.square],
    compressQuality: 70,
    compressFormat: ImageCompressFormat.jpg,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Podesi sliku'
      ),
      IOSUiSettings(
        title: 'Podesi sliku',
      )
    ]
  );

  if(croppedImage == null) return null;

  return File(croppedImage.path);
}

List<String> gradovi = [
  'Beograd',
  'Bor',
  'Valjevo',
  'Vranje',
  'Vršac',
  'Zaječar',
  'Zrenjanin',
  'Jagodina',
  'Kikinda',
  'Kragujevac',
  'Kraljevo',
  'Kruševac',
  'Leskovac',
  'Loznica',
  'Niš',
  'Novi Pazar',
  'Novi Sad',
  'Pančevo',
  'Pirot',
  'Požarevac',
  'Priština',
  'Prokuplje',
  'Smederevo',
  'Sombor',
  'Sremska Mitrovica',
  'Subotica',
  'Užice',
  'Čačak',
  'Šabac',
];
