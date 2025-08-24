class Firma {
  final int id;
  final String firmaAdi;
  final String adres;
  final String telefon;

  Firma({
    required this.id,
    required this.firmaAdi,
    required this.adres,
    required this.telefon,
  });

  factory Firma.fromJson(Map<String, dynamic> json) {
    return Firma(
      id: json['id'],
      firmaAdi: json['firma_adi'],
      adres: json['adres'],
      telefon: json['telefon'],
    );
  }
}

class Kullanici {
  final int id;
  final String kullaniciAdi;
  final String email;
  final bool aktif;
  final Firma firma;

  Kullanici({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
    required this.aktif,
    required this.firma,
  });

  factory Kullanici.fromJson(Map<String, dynamic> json) {
    return Kullanici(
      id: json['id'],
      kullaniciAdi: json['kullanici_adi'],
      email: json['email'],
      aktif: json['aktif'],
      firma: Firma.fromJson(json['firma']),
    );
  }
}
