// MODELLER
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

// ALT FİRMA MODELİ
class MusteriFirma {
  final int id;
  final int anaFirmaId;
  final String firmaAdi;
  final String ticariUnvan;
  final String vergiNo;
  final String vergiDairesi;
  final String telefon;
  final String cepTelefonu;
  final String? email;
  final String? webSite;
  final String? adres;
  final String? il;
  final String? ilce;
  final String? postaKodu;
  final bool aktif;
  final DateTime kayitTarihi;
  final DateTime? guncellemeTarihi;

  MusteriFirma({
    required this.id,
    required this.anaFirmaId,
    required this.firmaAdi,
    required this.ticariUnvan,
    required this.vergiNo,
    required this.vergiDairesi,
    required this.telefon,
    required this.cepTelefonu,
    this.email,
    this.webSite,
    this.adres,
    this.il,
    this.ilce,
    this.postaKodu,
    required this.aktif,
    required this.kayitTarihi,
    this.guncellemeTarihi,
  });

  factory MusteriFirma.fromJson(Map<String, dynamic> json) {
    return MusteriFirma(
      id: json['id'],
      anaFirmaId: json['ana_firma_id'],
      firmaAdi: json['firma_adi'],
      ticariUnvan: json['ticari_unvan'],
      vergiNo: json['vergi_no'],
      vergiDairesi: json['vergi_dairesi'],
      telefon: json['telefon'],
      cepTelefonu: json['cep_telefonu'],
      email: json['email'],
      webSite: json['web_site'],
      adres: json['adres'],
      il: json['il'],
      ilce: json['ilce'],
      postaKodu: json['posta_kodu'],
      aktif: json['aktif'],
      kayitTarihi: DateTime.parse(json['kayit_tarihi']),
      guncellemeTarihi: json['guncelleme_tarihi'] != null
          ? DateTime.parse(json['guncelleme_tarihi'])
          : null,
    );
  }
}
