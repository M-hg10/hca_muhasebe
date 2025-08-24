import 'dart:convert';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _url =
      'https://soft.hggrup.com/api/urunler/${aktifKullanici.firma.id}';

  static Future<List<Urun>> urunleriGetir() async {
    final response = await http.get(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
    );

    print('response body : ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((e) => Urun.fromJson(e)).toList();
      } else {
        throw Exception("Beklenmeyen veri formatı");
      }
    } else {
      throw Exception('Ürünler alınamadı: ${response.statusCode}');
    }
  }
}

class Urun {
  final int id;
  final String isim;
  final String aciklama;
  final bool aktif;
  final int kategoriId;
  final String marka;
  final int urunDurumuId;
  final DateTime tarih;
  final String kisaAciklama;
  final int altKategoriId;
  final int firmaId;
  final String kategoriAdi;
  final String altKategoriAdi;
  final String urunDurumu;
  final String firmaAdi;
  final String? anaresim;

  Urun({
    required this.id,
    required this.isim,
    required this.aciklama,
    required this.aktif,
    required this.kategoriId,
    required this.marka,
    required this.urunDurumuId,
    required this.tarih,
    required this.kisaAciklama,
    required this.altKategoriId,
    required this.firmaId,
    required this.kategoriAdi,
    required this.altKategoriAdi,
    required this.urunDurumu,
    required this.firmaAdi,
    required this.anaresim,
  });

  factory Urun.fromJson(Map<String, dynamic> json) {
    return Urun(
      id: json['id'],
      isim: json['isim'],
      aciklama: json['aciklama'],
      aktif: json['aktif'],
      kategoriId: json['kategori_id'],
      marka: json['marka'],
      urunDurumuId: json['urun_durumu_id'],
      tarih: DateTime.parse(json['tarih']),
      kisaAciklama: json['kisa_aciklama'],
      altKategoriId: json['alt_kategori_id'],
      firmaId: json['firma_id'],
      kategoriAdi: json['kategori_adi'],
      altKategoriAdi: json['alt_kategori_adi'],
      urunDurumu: json['urun_durumu'],
      firmaAdi: json['firma_adi'],
      anaresim: json['ana_resim_ulr'] ?? '',
    );
  }
}
