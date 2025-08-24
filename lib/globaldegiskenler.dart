import 'dart:convert';

import 'package:hcastick/onmuhasebe/model.dart';
import 'package:http/http.dart' as http;

late Kullanici aktifKullanici;

class ApiService {
  // Singleton yapı
  ApiService._privateConstructor();
  static final ApiService instance = ApiService._privateConstructor();

  List<Kategori> kategoriler = [];
  List<AltKategori> altKategoriler = [];
  List<UrunDurumu> urunDurumlari = [];

  bool isLoading = false;

  Future<void> loadDropdownData() async {
    print("api çalışıyor");
    final responses = await Future.wait([
      http.get(Uri.parse('https://soft.hggrup.com/sabit/kategoriler')),
      http.get(Uri.parse('https://soft.hggrup.com/sabit/alt-kategoriler')),
      http.get(Uri.parse('https://soft.hggrup.com/sabit/urun-durumlari')),
    ]);

    if (responses.every((r) => r.statusCode == 200)) {
      // Kategoriler
      final kategoriJsonList = json.decode(responses[0].body) as List<dynamic>;
      kategoriler = kategoriJsonList
          .map((json) => Kategori.fromJson(json as Map<String, dynamic>))
          .toList();

      // Alt kategoriler
      final altKategoriJsonList =
          json.decode(responses[1].body) as List<dynamic>;
      altKategoriler = altKategoriJsonList
          .map((json) => AltKategori.fromJson(json as Map<String, dynamic>))
          .toList();

      // Ürün durumları
      final urunDurumuJsonList =
          json.decode(responses[2].body) as List<dynamic>;
      urunDurumlari = urunDurumuJsonList
          .map((json) => UrunDurumu.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('API yanıtı başarısız');
    }

    isLoading = false;
  }

  List<AltKategori> getAltKategorilerByKategoriId(int kategoriId) {
    return altKategoriler.where((alt) => alt.kategoriId == kategoriId).toList();
  }
}

class Kategori {
  final int id;
  final String isim;

  Kategori({required this.id, required this.isim});

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(id: json['id'] as int, isim: json['isim'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'isim': isim};
}

class AltKategori {
  final int id;
  final int kategoriId;
  final String isim;

  AltKategori({required this.id, required this.kategoriId, required this.isim});

  factory AltKategori.fromJson(Map<String, dynamic> json) {
    return AltKategori(
      id: json['id'] as int,
      kategoriId: json['kategori_id'] as int,
      isim: json['isim'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'kategori_id': kategoriId,
    'isim': isim,
  };
}

class UrunDurumu {
  final int id;
  final String ad;

  UrunDurumu({required this.id, required this.ad});

  factory UrunDurumu.fromJson(Map<String, dynamic> json) {
    return UrunDurumu(id: json['id'] as int, ad: json['ad'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'ad': ad};
}
