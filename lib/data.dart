import 'package:uuid/uuid.dart';

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

class Usluga {
  String id = '';
  String tipObjekta = '';
  String naziv = '';
  String grad = '';
  int cena = 0;

  Usluga(this.tipObjekta, this.naziv, this.grad, this.cena) {
    id = const Uuid().v4();
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "naziv": naziv,
    "grad": grad,
    "cena": cena
  };
}