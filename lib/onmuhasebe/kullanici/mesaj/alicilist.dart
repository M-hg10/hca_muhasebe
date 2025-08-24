import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/mesaj/MesajFormSayfasi.dart';
import 'package:http/http.dart' as http;

class AliciListesiSayfasi extends StatefulWidget {
  const AliciListesiSayfasi({Key? key}) : super(key: key);

  @override
  _AliciListesiSayfasiState createState() => _AliciListesiSayfasiState();
}

class _AliciListesiSayfasiState extends State<AliciListesiSayfasi> {
  List<MesajKullanici> _kullanicilar = [];

  Future<void> _kullanicilariGetir() async {
    final response = await http.get(
      Uri.parse(
        "https://n8n.hggrup.com/webhook/7754119f-d38f-49a2-b5e1-d1ef9b0ab26a?firmaid=${aktifKullanici.firma.id}",
      ),
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      List<MesajKullanici> kullaniciListesi = [];

      if (decoded is List) {
        // JSON bir liste ise
        kullaniciListesi = decoded
            .map<MesajKullanici>((json) => MesajKullanici.fromJson(json))
            .toList();
      } else if (decoded is Map<String, dynamic>) {
        // JSON tek bir obje ise
        kullaniciListesi = [MesajKullanici.fromJson(decoded)];
      } else {
        // Beklenmeyen format
        throw Exception("Beklenmeyen JSON formatı: ${decoded.runtimeType}");
      }

      setState(() {
        _kullanicilar = kullaniciListesi;
      });
    } else {
      throw Exception(
        "Kullanıcıları getiremedik. Status code: ${response.statusCode}",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _kullanicilariGetir();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Alıcı Seç")),
      body: ListView.builder(
        itemCount: _kullanicilar.length,
        itemBuilder: (context, index) {
          final kullanici = _kullanicilar[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            color: Colors.primaries[index % Colors.primaries.length].shade100,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Text(
                kullanici.kullaniciAdi,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(kullanici.email),
                  Text(kullanici.telefon),
                  Text(kullanici.adresMetni),
                ],
              ),
              trailing: Icon(
                kullanici.aktif ? Icons.check_circle : Icons.cancel,
                color: kullanici.aktif ? Colors.green : Colors.red,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MesajFormSayfasi(
                      alici: kullanici,
                      chat_type: "direct",
                      gonderenId: aktifKullanici.id,
                      aliciId: kullanici.id,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MesajFormSayfasi(
                alici: MesajKullanici(
                  id: 0,
                  kullaniciAdi: "",
                  email: "",
                  telefon: "",
                  adresMetni: "",
                  aktif: false,
                  kayitTarihi: DateTime.now(),
                  firmaId: 0,
                ),
                chat_type: "group",
                gonderenId: aktifKullanici.id,
                aliciId: aktifKullanici.id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class MesajKullanici {
  final int id;
  final String kullaniciAdi;
  final String email;
  final String telefon;
  final String adresMetni;
  final bool aktif;
  final DateTime kayitTarihi;
  final int firmaId;

  MesajKullanici({
    required this.id,
    required this.kullaniciAdi,
    required this.email,
    required this.telefon,
    required this.adresMetni,
    required this.aktif,
    required this.kayitTarihi,
    required this.firmaId,
  });

  factory MesajKullanici.fromJson(Map<String, dynamic> json) {
    return MesajKullanici(
      id: json['id'],
      kullaniciAdi: json['kullanici_adi'],
      email: json['email'],
      telefon: json['telefon'],
      adresMetni: json['adres_metni'],
      aktif: json['aktif'],
      kayitTarihi: DateTime.parse(json['kayit_tarihi']),
      firmaId: json['firma_id'],
    );
  }
}

// JSON listesini MesajKullanici listesine çeviren fonksiyon
List<MesajKullanici> kullanicilarFromJson(List<dynamic> jsonList) {
  return jsonList.map((json) => MesajKullanici.fromJson(json)).toList();
}
