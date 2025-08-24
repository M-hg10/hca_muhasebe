import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hcastick/globaldegiskenler.dart';
import 'package:hcastick/onmuhasebe/kullanici/musteri_hizli_satis.dart';
import 'package:hcastick/onmuhasebe/urun/fiyat_gor.dart';
import 'package:hcastick/onmuhasebe/urun/urun_resim_ekle.dart';
import 'package:hcastick/onmuhasebe/urun/urunekle.dart';
import 'package:hcastick/onmuhasebe/urun/urun_api_servis.dart';
import 'package:hcastick/onmuhasebe/urun/urun_fiyat.dart';
import 'package:http/http.dart' as http;

class UrunListeSayfasi extends StatefulWidget {
  final int firmaId;

  const UrunListeSayfasi({super.key, required this.firmaId});

  @override
  State<UrunListeSayfasi> createState() => _UrunListeSayfasiState();
}

class _UrunListeSayfasiState extends State<UrunListeSayfasi> {
  List<Urun> tumUrunler = [];

  @override
  void initState() {
    super.initState();
    fetchUrunler();
  }

  Future<void> fetchUrunler() async {
    try {
      final veriler = await getUrunler(firmaId: widget.firmaId);
      setState(() {
        tumUrunler = veriler;
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<List<Urun>> getUrunler({required int firmaId}) async {
    final url = Uri.parse('https://soft.hggrup.com/api/urunler/$firmaId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Urun.fromJson(json)).toList();
    } else {
      throw Exception('Ürünler alınamadı. Hata kodu: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmisUrunler = tumUrunler
        .where((urun) => urun.firmaId == widget.firmaId)
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final TextEditingController barcodeController =
              TextEditingController();

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Barkod Numarası Gönder'),
                content: TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barkod Numarası',
                    hintText: 'Barkod numarasını girin',
                  ),
                  keyboardType: TextInputType.number,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final barcode = barcodeController.text.trim();
                      if (barcode.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen barkod numarasını girin!'),
                          ),
                        );
                        return;
                      }

                      // Navigator.of(context).pop(); // Dialogu kapat
                      print('veri gönderildi');

                      final url = Uri.parse(
                        'https://n8n.hggrup.com/webhook/4e465e7b-baa6-458d-90d9-8d53368ae23d',
                      );

                      final response = await http.post(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({"barcode": barcode}),
                      );
                      print(response.body);

                      if (response.statusCode == 200) {
                        final data = json.decode(response.body);

                        // Yeni sayfaya yönlendirme
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductInfoPage(data: data),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: ${response.statusCode}'),
                          ),
                        );
                      }
                    },
                    child: const Text('Gönder'),
                  ),
                ],
              );
            },
          );
        },
        label: const Text('Fiyat Gör'),
        icon: const Icon(Icons.search),
        backgroundColor: const Color.fromARGB(255, 191, 240, 235),
      ),
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Urunekle(kullanici: aktifKullanici),
              ),
            ),
            child: Text("Ürün Ekle", style: TextStyle(color: Colors.white)),
          ),
        ],
        title: const Text('Firma Ürünleri'),
        backgroundColor: Colors.teal,
      ),
      body: filtrelenmisUrunler.isEmpty
          ? const Center(
              child: Text(
                "Bu firmaya ait ürün bulunamadı.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: filtrelenmisUrunler.length,
              itemBuilder: (context, index) {
                final urun = filtrelenmisUrunler[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HizliSatisSayfasi(urun: urun),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ürün Satış Sayfasına Gider "),
                          // Ürün resmi
                          urun.anaresim == null
                              ? Image.network(
                                  urun.anaresim!,
                                  width: 200, // istediğin genişlik
                                  height: 200, // istediğin yükseklik
                                  fit: BoxFit
                                      .cover, // resmi kırpar ama alanı doldurur
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                )
                              : SizedBox(),
                          const SizedBox(height: 10),
                          // Ürün ismi
                          Text(
                            urun.isim,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Açıklama
                          Text(
                            urun.kisaAciklama,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          // Etiketler
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                label: Text(urun.urunDurumu),
                                avatar: const Icon(
                                  Icons.info_outline,
                                  size: 18,
                                ),
                                backgroundColor: Colors.orange.shade100,
                              ),
                              Chip(
                                label: Text(urun.marka),
                                avatar: const Icon(
                                  Icons.branding_watermark,
                                  size: 18,
                                ),
                                backgroundColor: Colors.blue.shade100,
                              ),
                              Chip(
                                label: Text(
                                  "${urun.kategoriAdi} / ${urun.altKategoriAdi}",
                                ),
                                avatar: const Icon(Icons.category, size: 18),
                                backgroundColor: Colors.green.shade100,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FiyatEkleWidget(urun: urun),
                                    ),
                                  );
                                },
                                child: Chip(
                                  label: Text("Ürün Fiyatı Ekle"),
                                  avatar: const Icon(Icons.business, size: 18),
                                  backgroundColor: Colors.purple.shade100,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UrunResimEklemePage(urun: urun),
                                    ),
                                  );
                                },
                                child: Chip(
                                  label: Text("Ürün Resim Ekle"),
                                  avatar: const Icon(Icons.business, size: 18),
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    227,
                                    238,
                                    9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Tarih
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                urun.tarih.toLocal().toString().substring(
                                  0,
                                  16,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
