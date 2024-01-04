enum Objekat {
  prostori,
  muzika,
  fotografi,
  torte,
  ketering,
  dekoracije
}

String objekatToString(Objekat tipObjekta) {
  switch(tipObjekta) {
    case Objekat.prostori:
      return 'Prostori';
    case Objekat.muzika:
      return 'Muzika';
    case Objekat.fotografi:
      return 'Fotografi';
    case Objekat.torte:
      return 'Torte';
    case Objekat.ketering:
      return 'Ketering';
    case Objekat.dekoracije:
      return 'Dekoracije';
  }
}