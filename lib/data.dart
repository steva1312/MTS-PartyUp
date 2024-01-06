import 'package:uuid/uuid.dart';

enum TipObjekta {
  prostori,
  muzika,
  fotografi,
  torte,
  ketering,
  dekoracije
}

String objekatToString(TipObjekta tipObjekta) {
  switch(tipObjekta) {
    case TipObjekta.prostori:
      return 'Prostori';
    case TipObjekta.muzika:
      return 'Muzika';
    case TipObjekta.fotografi:
      return 'Fotografi';
    case TipObjekta.torte:
      return 'Torte';
    case TipObjekta.ketering:
      return 'Ketering';
    case TipObjekta.dekoracije:
      return 'Dekoracije';
  }
}

TipObjekta stringToObjekat(String tipObjekta) {
  switch(tipObjekta) {
    case 'Prostori':
      return TipObjekta.prostori;
    case 'Muzika':
      return TipObjekta.muzika;
    case 'Fotografi':
      return TipObjekta.fotografi;
    case 'Torte':
      return TipObjekta.torte;
    case 'Ketering':
      return TipObjekta.ketering;
    case 'Dekoracije':
      return TipObjekta.dekoracije;
  }

  return TipObjekta.prostori; //mora difolt neki da ne javlja gresku
}

class Objekat {
  String id = '';
  String tipObjekta = '';
  String naziv = '';
  String grad = '';
  int cena = 0;

  Objekat(this.tipObjekta, this.naziv, this.grad, this.cena) {
    id = const Uuid().v4();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "tipObjekta": tipObjekta,
    "naziv": naziv,
    "grad": grad,
    "cena": cena
  };
}